local holdDelay = 1
local overlay = nil
local showTimer = nil
local shortcutGroups = {
  apps = {
    { key = "C", name = "Chrome", bundleID = "com.google.Chrome" },
    { key = "⇧C", name = "Visitante", bundleID = "com.google.Chrome" },
    { key = "G", name = "Gmail", bundleID = "com.google.Chrome.app.fmgjjmmmlfnkbppncabfkddbjimcfncm" },
    { key = "L", name = "Localhost", bundleID = "com.google.Chrome" },
    { key = "M", name = "Meet", bundleID = "com.google.Chrome.app.kjgfgldnnfoeklkmfkjfagphfepbbdan" },
    { key = "X", name = "X", bundleID = "com.google.Chrome.app.lodlkdfmihgonocnmddehnfgiljnadcf" },
    { key = "Y", name = "YouTube", bundleID = "com.google.Chrome.app.agimnkijcaahngcdmfeangaknmldooml" },
  },
  tools = {
    { key = "F", name = "Finder", bundleID = "com.apple.finder" },
    { key = "H", name = "ChatGPT", bundleID = "com.openai.codex" },
    { key = "K", name = "Slack", bundleID = "com.tinyspeck.slackmacgap" },
    { key = "T", name = "cmux", bundleID = "com.cmuxterm.app" },
    { key = "V", name = "VS Code", bundleID = "com.microsoft.VSCode" },
  },
  media = {
    { key = "S", name = "Spotify", bundleID = "com.spotify.client" },
    { key = "W", name = "WhatsApp", bundleID = "net.whatsapp.WhatsApp" },
  },
}

local managementGroups = {
  {
    title = "LAYOUT",
    shortcuts = {
      { key = ",", name = "Accordion" },
      { key = "/", name = "Mosaico" },
      { key = "= / -", name = "Redimensionar ±50" },
      { key = "⇧= / ⇧-", name = "Redimensionar ±333" },
      { key = "R", name = "Reorganizar árvore" },
      { key = "↩", name = "Tela cheia" },
      { key = "⇧F", name = "Flutuante / mosaico" },
    },
  },
  {
    title = "JANELAS",
    shortcuts = {
      { key = "↑ ↓ ← →", name = "Focar na direção" },
      { key = "⇧ + setas", name = "Mover na direção" },
      { key = "` / ⇧`", name = "Próxima / anterior do app" },
    },
  },
  {
    title = "ESPAÇOS",
    shortcuts = {
      { key = "F1…F10", name = "Ir ao espaço" },
      { key = "CAPS F1…10", name = "Mover janela e ir" },
      { key = "Tab", name = "Alternar espaços" },
      { key = "⇧Tab", name = "Mover espaço ao monitor" },
      { key = "N", name = "Mover janela ao vazio" },
      { key = "⇧N", name = "Ir ao vazio" },
      { key = "[ / ]", name = "Anterior / próximo" },
    },
  },
}

local function hyperIsPressed(flags)
  return flags.cmd and flags.alt and flags.ctrl
end

local function showOverlay()
  local screenFrame = hs.mouse.getCurrentScreen():frame()
  local width = 1040
  local height = 500

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
    action = "strokeAndFill",
    fillColor = { red = 0.035, green = 0.045, blue = 0.05, alpha = 0.985 },
    strokeColor = { white = 1, alpha = 0.16 },
    strokeWidth = 1,
    roundedRectRadii = { xRadius = 14, yRadius = 14 },
  }
  overlay[2] = {
    type = "text",
    text = "Atalhos do AeroSpace",
    textColor = { white = 1 },
    textFont = ".AppleSystemUIFont",
    textSize = 20,
    frame = { x = 24, y = 18, w = 300, h = 30 },
  }
  overlay[3] = {
    type = "text",
    text = "CAPS = ⌘⌥⌃",
    textAlignment = "right",
    textColor = { white = 0.68 },
    textFont = ".AppleSystemUIFont",
    textSize = 12,
    frame = { x = width - 140 - 24, y = 24, w = 140, h = 18 },
  }

  local elementIndex = 4

  local function addElement(element)
    overlay[elementIndex] = element
    elementIndex = elementIndex + 1
  end

  local function addAppRow(title, shortcuts, titleY)
    addElement({
      type = "text",
      text = title,
      textColor = { white = 0.72 },
      textFont = ".AppleSystemUIFont",
      textSize = 10,
      frame = { x = 27, y = titleY, w = width - 54, h = 16 },
    })

    local gap = 8
    local cardWidth = (width - 48 - (gap * 6)) / 7

    for index, shortcut in ipairs(shortcuts) do
      local x = 24 + ((index - 1) * (cardWidth + gap))
      local rowY = titleY + 18
      local icon = hs.image.imageFromAppBundle(shortcut.bundleID)

      addElement({
        type = "rectangle",
        action = "strokeAndFill",
        fillColor = { white = 1, alpha = 0.045 },
        strokeColor = { white = 1, alpha = 0.07 },
        strokeWidth = 1,
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        frame = { x = x, y = rowY, w = cardWidth, h = 34 },
      })

      if icon then
        addElement({
          type = "image",
          image = icon,
          imageScaling = "scaleProportionally",
          frame = { x = x + 6, y = rowY + 4, w = 26, h = 26 },
        })
      end

      addElement({
        type = "rectangle",
        action = "fill",
        fillColor = { white = 0.96, alpha = 1 },
        roundedRectRadii = { xRadius = 5, yRadius = 5 },
        frame = { x = x + 38, y = rowY + 5, w = 32, h = 24 },
      })
      addElement({
        type = "text",
        text = shortcut.key,
        textAlignment = "center",
        textColor = { white = 0.08 },
        textFont = "Menlo-Bold",
        textSize = 14,
        frame = { x = x + 38, y = rowY + 7, w = 32, h = 20 },
      })
      addElement({
        type = "text",
        text = shortcut.name,
        textColor = { white = 0.74 },
        textFont = ".AppleSystemUIFont",
        textSize = 10,
        frame = { x = x + 77, y = rowY + 8, w = cardWidth - 82, h = 18 },
      })
    end
  end

  local utilityShortcuts = {}
  for _, shortcut in ipairs(shortcutGroups.tools) do
    table.insert(utilityShortcuts, shortcut)
  end
  for _, shortcut in ipairs(shortcutGroups.media) do
    table.insert(utilityShortcuts, shortcut)
  end

  addAppRow("CHROME E WEB APPS", shortcutGroups.apps, 58)
  addAppRow("FERRAMENTAS, MÍDIA E MENSAGENS", utilityShortcuts, 112)

  addElement({
    type = "rectangle",
    action = "fill",
    fillColor = { white = 1, alpha = 0.24 },
    frame = { x = 24, y = 170, w = width - 48, h = 1 },
  })
  addElement({
    type = "text",
    text = "GERENCIAMENTO DE JANELAS",
    textColor = { white = 0.72 },
    textFont = ".AppleSystemUIFont",
    textSize = 10,
    frame = { x = 27, y = 184, w = width - 54, h = 16 },
  })

  local groupGap = 16
  local groupWidth = (width - 48 - (groupGap * (#managementGroups - 1))) / #managementGroups

  for groupIndex, group in ipairs(managementGroups) do
    local groupX = 24 + ((groupIndex - 1) * (groupWidth + groupGap))

    addElement({
      type = "text",
      text = group.title,
      textColor = { white = 0.82 },
      textFont = ".AppleSystemUIFont",
      textSize = 11,
      frame = { x = groupX + 3, y = 210, w = groupWidth - 6, h = 18 },
    })

    if groupIndex > 1 then
      addElement({
        type = "rectangle",
        action = "fill",
        fillColor = { white = 1, alpha = 0.16 },
        frame = { x = groupX - 8, y = 210, w = 1, h = 258 },
      })
    end

    for shortcutIndex, shortcut in ipairs(group.shortcuts) do
      local rowY = 236 + ((shortcutIndex - 1) * 30)

      addElement({
        type = "rectangle",
        action = "fill",
        fillColor = { white = 0.94, alpha = 1 },
        roundedRectRadii = { xRadius = 4, yRadius = 4 },
        frame = { x = groupX, y = rowY, w = 100, h = 24 },
      })
      addElement({
        type = "text",
        text = shortcut.key,
        textAlignment = "center",
        textColor = { white = 0.08 },
        textFont = "Menlo-Bold",
        textSize = 14,
        frame = { x = groupX, y = rowY + 2, w = 100, h = 20 },
      })
      addElement({
        type = "text",
        text = shortcut.name,
        textColor = { white = 0.72 },
        textFont = ".AppleSystemUIFont",
        textSize = 12,
        frame = { x = groupX + 108, y = rowY + 3, w = groupWidth - 108, h = 18 },
      })
    end
  end

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
