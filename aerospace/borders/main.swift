// A minimal focused-window border for AeroSpace.
//
import AppKit
import QuartzCore

typealias NotifyProc = @convention(c) (
    UInt32,
    UnsafeMutableRawPointer?,
    Int,
    UnsafeMutableRawPointer?
) -> Void

@_silgen_name("SLSMainConnectionID")
func SLSMainConnectionID() -> Int32

@_silgen_name("SLSRegisterNotifyProc")
func SLSRegisterNotifyProc(
    _ proc: NotifyProc,
    _ event: UInt32,
    _ context: UnsafeMutableRawPointer?
) -> CGError

@_silgen_name("SLSRequestNotificationsForWindows")
func SLSRequestNotificationsForWindows(
    _ connection: Int32,
    _ windows: UnsafePointer<UInt32>,
    _ count: Int32
) -> CGError

@_silgen_name("SLSGetEventPort")
func SLSGetEventPort(
    _ connection: Int32,
    _ port: UnsafeMutablePointer<mach_port_t>
) -> CGError

@_silgen_name("SLEventCreateNextEvent")
func SLEventCreateNextEvent(_ connection: Int32) -> Unmanaged<CGEvent>?

@_silgen_name("_CFMachPortSetOptions")
func CFMachPortSetOptions(_ port: CFMachPort, _ options: Int32)

struct ProcessSerialNumber {
    var high: UInt32 = 0
    var low: UInt32 = 0
}

@_silgen_name("_SLPSGetFrontProcess")
func SLPSGetFrontProcess(_ process: inout ProcessSerialNumber) -> OSStatus

@_silgen_name("GetProcessPID")
func GetProcessPID(
    _ process: inout ProcessSerialNumber,
    _ pid: inout pid_t
) -> OSStatus

private let eventWindowMove: UInt32 = 806
private let eventWindowResize: UInt32 = 807
private let eventWindowReorder: UInt32 = 808
private let eventWindowCreate: UInt32 = 1325
private let eventWindowDestroy: UInt32 = 1326
private let eventFrontChange: UInt32 = 1508

private let usage = """
Usage: aerospace-borders [options]

Options:
  --color HEX       Border color (#RRGGBB or #RRGGBBAA, default: #FF4500)
  --width POINTS    Border width (default: 4)
  --radius POINTS   Corner radius (default: 18)
  --gap POINTS      Offset from the window edge (default: -1)
  --help             Show this help
"""

private struct Options {
    var color = CGColor(red: 1, green: 69 / 255, blue: 0, alpha: 1)
    var width: CGFloat = 4
    var radius: CGFloat = 18
    var gap: CGFloat = -1
}

private func writeError(_ message: String) {
    FileHandle.standardError.write(Data("aerospace-borders: \(message)\n".utf8))
}

private func fail(_ message: String) -> Never {
    writeError(message)
    writeError("Run with --help for usage.")
    exit(2)
}

private func color(from value: String) -> CGColor? {
    let hex = value.hasPrefix("#") ? String(value.dropFirst()) : value
    guard hex.count == 6 || hex.count == 8,
          let parsed = UInt32(hex, radix: 16)
    else { return nil }

    let rgba = hex.count == 6 ? (parsed << 8) | 0xff : parsed
    return CGColor(
        red: CGFloat((rgba >> 24) & 0xff) / 255,
        green: CGFloat((rgba >> 16) & 0xff) / 255,
        blue: CGFloat((rgba >> 8) & 0xff) / 255,
        alpha: CGFloat(rgba & 0xff) / 255
    )
}

private func nextValue(
    after index: inout Int,
    in arguments: [String],
    for option: String
) -> String {
    index += 1
    guard index < arguments.count else { fail("missing value for \(option)") }
    return arguments[index]
}

private func finiteNumber(_ value: String, for option: String) -> CGFloat {
    guard let number = Double(value), number.isFinite else {
        fail("invalid value for \(option): \(value)")
    }
    return CGFloat(number)
}

private func parseOptions() -> Options {
    var options = Options()
    let arguments = Array(CommandLine.arguments.dropFirst())
    var index = 0

    while index < arguments.count {
        let argument = arguments[index]
        switch argument {
        case "--help", "-h":
            print(usage)
            exit(0)
        case "--color":
            let value = nextValue(after: &index, in: arguments, for: argument)
            guard let parsed = color(from: value) else {
                fail("invalid color: \(value)")
            }
            options.color = parsed
        case "--width":
            let value = nextValue(after: &index, in: arguments, for: argument)
            let width = finiteNumber(value, for: argument)
            guard width > 0 else { fail("--width must be greater than zero") }
            options.width = width
        case "--radius":
            let value = nextValue(after: &index, in: arguments, for: argument)
            let radius = finiteNumber(value, for: argument)
            guard radius >= 0 else { fail("--radius cannot be negative") }
            options.radius = radius
        case "--gap":
            let value = nextValue(after: &index, in: arguments, for: argument)
            options.gap = finiteNumber(value, for: argument)
        default:
            fail("unknown option: \(argument)")
        }
        index += 1
    }

    return options
}

private struct FocusedWindow {
    let id: UInt32
    let frame: CGRect
}

private let options = parseOptions()
private let application = NSApplication.shared
private let overlay = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
    styleMask: .borderless,
    backing: .buffered,
    defer: false
)
private let contentView = NSView(frame: .zero)
private let borderLayer = CAShapeLayer()

private var lastWindowID: UInt32 = 0
private var displayedWindowID: UInt32 = 0
private var lastFrame = CGRect.zero
private var lastTickTime = CACurrentMediaTime()
private var lastFullScanTime = CACurrentMediaTime()
private var lastKickTime = CACurrentMediaTime()
private var trailingTickScheduled = false
private var subscribedWindowIDs = Set<UInt32>()

private func frontmostPID() -> pid_t? {
    var process = ProcessSerialNumber()
    var pid: pid_t = 0
    guard SLPSGetFrontProcess(&process) == noErr,
          GetProcessPID(&process, &pid) == noErr
    else { return nil }
    return pid
}

private func frame(from window: [String: Any]) -> CGRect? {
    guard let bounds = window[kCGWindowBounds as String] as? [String: Any],
          let x = bounds["X"] as? CGFloat,
          let y = bounds["Y"] as? CGFloat,
          let width = bounds["Width"] as? CGFloat,
          let height = bounds["Height"] as? CGFloat
    else { return nil }

    return CGRect(x: x, y: y, width: width, height: height)
}

private func isMostlyVisible(_ frame: CGRect) -> Bool {
    guard frame.width > 0, frame.height > 0 else { return false }

    var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
    var displayCount: UInt32 = 0
    guard CGGetActiveDisplayList(16, &displayIDs, &displayCount) == .success else {
        return true
    }

    var visibleArea: CGFloat = 0
    for index in 0..<Int(displayCount) {
        let intersection = frame.intersection(CGDisplayBounds(displayIDs[index]))
        if !intersection.isNull {
            visibleArea += intersection.width * intersection.height
        }
    }

    return visibleArea / (frame.width * frame.height) >= 0.7
}

private func validWindow(
    _ window: [String: Any],
    ownedBy pid: pid_t
) -> FocusedWindow? {
    guard (window[kCGWindowLayer as String] as? Int) == 0,
          (window[kCGWindowOwnerPID as String] as? pid_t) == pid,
          let number = window[kCGWindowNumber as String] as? Int,
          let frame = frame(from: window),
          frame.width > 60,
          frame.height > 60,
          isMostlyVisible(frame)
    else { return nil }

    return FocusedWindow(id: UInt32(number), frame: frame)
}

private func focusedWindow() -> FocusedWindow? {
    guard let pid = frontmostPID() else { return nil }

    let now = CACurrentMediaTime()
    let isEventStorm = now - lastTickTime < 0.1
    let maximumCacheAge = isEventStorm ? 0.25 : 2.0
    lastTickTime = now

    if lastWindowID != 0,
       now - lastFullScanTime < maximumCacheAge,
       let windows = CGWindowListCopyWindowInfo(
           .optionIncludingWindow,
           lastWindowID
       ) as? [[String: Any]],
       let window = windows.first,
       let focused = validWindow(window, ownedBy: pid) {
        return focused
    }

    lastFullScanTime = now
    guard let windows = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        lastWindowID = 0
        return nil
    }

    for window in windows {
        if let focused = validWindow(window, ownedBy: pid) {
            lastWindowID = focused.id
            return focused
        }
    }

    lastWindowID = 0
    return nil
}

private func isFullscreen(_ frame: CGRect) -> Bool {
    var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
    var displayCount: UInt32 = 0
    guard CGGetActiveDisplayList(16, &displayIDs, &displayCount) == .success else {
        return false
    }

    for index in 0..<Int(displayCount) {
        let display = CGDisplayBounds(displayIDs[index])
        guard display.intersects(frame) else { continue }
        if abs(frame.minX - display.minX) <= 3,
           abs(frame.minY - display.minY) <= 3,
           abs(frame.width - display.width) <= 6,
           abs(frame.height - display.height) <= 6 {
            return true
        }
    }
    return false
}

private func cocoaFrame(from frame: CGRect) -> CGRect {
    let primaryDisplayHeight = NSScreen.screens.first?.frame.height ?? 0
    return CGRect(
        x: frame.minX,
        y: primaryDisplayHeight - frame.minY - frame.height,
        width: frame.width,
        height: frame.height
    )
}

private func hideBorder() {
    if overlay.isVisible {
        overlay.orderOut(nil)
    }
    displayedWindowID = 0
    lastFrame = .zero
}

private func updateBorder() {
    guard let focused = focusedWindow(), !isFullscreen(focused.frame) else {
        hideBorder()
        return
    }

    if focused.frame == lastFrame, overlay.isVisible { return }

    if overlay.isVisible, focused.id != displayedWindowID {
        overlay.orderOut(nil)
    }

    lastWindowID = focused.id
    displayedWindowID = focused.id
    lastFrame = focused.frame

    let padding = options.width + options.gap
    let outerFrame = cocoaFrame(from: focused.frame.insetBy(dx: -padding, dy: -padding))
    let bounds = CGRect(origin: .zero, size: outerFrame.size)
    let pathBounds = bounds.insetBy(dx: options.width / 2, dy: options.width / 2)

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    overlay.setFrame(outerFrame, display: false)
    borderLayer.frame = bounds
    borderLayer.path = CGPath(
        roundedRect: pathBounds,
        cornerWidth: options.radius,
        cornerHeight: options.radius,
        transform: nil
    )
    CATransaction.commit()

    if !overlay.isVisible {
        overlay.orderFrontRegardless()
    }
}

private func scheduleUpdate() {
    let now = CACurrentMediaTime()
    if now - lastKickTime >= 0.004 {
        lastKickTime = now
        updateBorder()
        return
    }

    guard !trailingTickScheduled else { return }
    trailingTickScheduled = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.008) {
        trailingTickScheduled = false
        lastKickTime = CACurrentMediaTime()
        updateBorder()
    }
}

private let connection = SLSMainConnectionID()

private func rebuildSubscriptions() {
    guard let windows = CGWindowListCopyWindowInfo(
        .optionAll,
        kCGNullWindowID
    ) as? [[String: Any]] else { return }

    let windowIDs = windows.compactMap { window -> UInt32? in
        guard (window[kCGWindowLayer as String] as? Int) == 0,
              let number = window[kCGWindowNumber as String] as? Int
        else { return nil }
        return UInt32(number)
    }

    let newWindowIDs = Set(windowIDs)
    guard !windowIDs.isEmpty, newWindowIDs != subscribedWindowIDs else { return }

    subscribedWindowIDs = newWindowIDs
    _ = windowIDs.withUnsafeBufferPointer { buffer in
        SLSRequestNotificationsForWindows(
            connection,
            buffer.baseAddress!,
            Int32(buffer.count)
        )
    }
}

private let notificationCallback: NotifyProc = { event, _, _, _ in
    if event == eventFrontChange
        || event == eventWindowReorder
        || event == eventWindowCreate
        || event == eventWindowDestroy {
        lastWindowID = 0
        lastFullScanTime = 0
    }

    if event == eventWindowCreate || event == eventWindowDestroy {
        rebuildSubscriptions()
    }
    scheduleUpdate()
}

application.setActivationPolicy(.prohibited)

overlay.isOpaque = false
overlay.backgroundColor = .clear
overlay.ignoresMouseEvents = true
overlay.hasShadow = false
overlay.level = .floating
overlay.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
overlay.animationBehavior = .none

contentView.wantsLayer = true
borderLayer.fillColor = nil
borderLayer.strokeColor = options.color
borderLayer.lineWidth = options.width
contentView.layer?.addSublayer(borderLayer)
overlay.contentView = contentView

for event in [
    eventWindowMove,
    eventWindowResize,
    eventWindowReorder,
    eventWindowCreate,
    eventWindowDestroy,
    eventFrontChange,
] {
    _ = SLSRegisterNotifyProc(notificationCallback, event, nil)
}

rebuildSubscriptions()

private let eventPortCallback: CFMachPortCallBack = { _, _, _, _ in
    while let event = SLEventCreateNextEvent(SLSMainConnectionID()) {
        event.release()
    }
}

private var eventPort: mach_port_t = 0
if SLSGetEventPort(connection, &eventPort) == .success,
   let machPort = CFMachPortCreateWithPort(
       nil,
       eventPort,
       eventPortCallback,
       nil,
       nil
   ) {
    CFMachPortSetOptions(machPort, 0x40)
    let source = CFMachPortCreateRunLoopSource(nil, machPort, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
} else {
    writeError("SkyLight event port unavailable; using heartbeat fallback")
}

private let heartbeat = Timer(timeInterval: 0.5, repeats: true) { _ in
    updateBorder()
}
RunLoop.current.add(heartbeat, forMode: .common)

private let subscriptionHeartbeat = Timer(timeInterval: 5, repeats: true) { _ in
    rebuildSubscriptions()
}
RunLoop.current.add(subscriptionHeartbeat, forMode: .common)

private let screenObserver = NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification,
    object: nil,
    queue: .main
) { _ in
    lastFrame = .zero
    updateBorder()
}

updateBorder()
application.run()
