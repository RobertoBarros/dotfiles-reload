local holdDelay = 1
local overlay = nil
local showTimer = nil
local appShortcuts = {
  { "C", "Google Chrome" },
  { "⇧C", "Chrome (convidado)" },
  { "F", "Finder" },
  { "G", "Gmail" },
  { "H", "ChatGPT" },
  { "K", "Slack" },
  { "L", "Localhost" },
  { "M", "Google Meet" },
  { "S", "Spotify" },
  { "T", "cmux" },
  { "V", "Visual Studio Code" },
  { "W", "WhatsApp" },
  { "X", "X" },
  { "Y", "YouTube" },
}

local function shortcutColumn(firstIndex, lastIndex)
  local lines = {}

  for index = firstIndex, lastIndex do
    local shortcut = appShortcuts[index]
    table.insert(lines, string.format("CAPS %-2s  %s", shortcut[1], shortcut[2]))
  end

  return table.concat(lines, "\n")
end

local function hyperIsPressed(flags)
  return flags.cmd and flags.alt and flags.ctrl
end

local function showOverlay()
  local screenFrame = hs.mouse.getCurrentScreen():frame()
  local width = 620
  local height = 280

  overlay = hs.canvas.new({
    x = screenFrame.x + (screenFrame.w - width) / 2,
    y = screenFrame.y + (screenFrame.h - height) / 2,
    w = width,
    h = height,
  })

  overlay:level(hs.canvas.windowLevels.overlay)
  overlay:behavior({ "canJoinAllSpaces", "stationary", "fullScreenAuxiliary" })
  overlay[1] = {
    type = "rectangle",
    action = "fill",
    fillColor = { white = 0.08, alpha = 0.92 },
    roundedRectRadii = { xRadius = 18, yRadius = 18 },
  }
  overlay[2] = {
    type = "text",
    text = "Atalhos de aplicativos",
    textAlignment = "center",
    textColor = { white = 1 },
    textFont = ".AppleSystemUIFont",
    textSize = 24,
    frame = { x = 0, y = 24, w = width, h = 34 },
  }
  overlay[3] = {
    type = "text",
    text = shortcutColumn(1, 7),
    textColor = { white = 0.92 },
    textFont = "Menlo",
    textSize = 16,
    frame = { x = 34, y = 72, w = 270, h = 180 },
  }
  overlay[4] = {
    type = "text",
    text = shortcutColumn(8, 14),
    textColor = { white = 0.92 },
    textFont = "Menlo",
    textSize = 16,
    frame = { x = 318, y = 72, w = 270, h = 180 },
  }
  overlay:show()
end

local function hideOverlay()
  if showTimer then
    showTimer:stop()
    showTimer = nil
  end

  if overlay then
    overlay:delete()
    overlay = nil
  end
end

local function scheduleOverlay()
  if overlay or showTimer then
    return
  end

  showTimer = hs.timer.doAfter(holdDelay, function()
    showTimer = nil

    if hyperIsPressed(hs.eventtap.checkKeyboardModifiers()) then
      showOverlay()
    end
  end)
end

capsOverlayWatcher = hs.timer.doEvery(0.25, function()
  if hyperIsPressed(hs.eventtap.checkKeyboardModifiers()) then
    scheduleOverlay()
  else
    hideOverlay()
  end
end)
