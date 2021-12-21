local positions = {
  maximized = hs.layout.maximized,
  centered = {x=0, y=0, w=1, h=1},

  left34 = {x=0, y=0, w=0.34, h=1},
  left50 = hs.layout.left50,
  left66 = {x=0, y=0, w=0.66, h=1},

  right34 = {x=0.66, y=0, w=0.34, h=1},
  right50 = hs.layout.right50,
  right66 = {x=0.34, y=0, w=0.66, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5}
}

local function getWindow()
  local window = hs.window.focusedWindow()

  if window == nil then
    return
  else
    return window
  end
end

local function move(units)
  local screen = hs.screen.mainScreen()
  local window = getWindow()
  local windowGeo = window:frame()

  local index = 0
  hs.fnutils.find(
    units,
    function(unit)
      index = index + 1
      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
      return windowGeo:equals(geo)
    end
  )
  if index == #units then index = 0 end

  window:moveToUnit(units[index + 1])
end

local function maximize()
  move({positions.centered, positions.maximized})
end

local function moveLeft()
  move({positions.left50, positions.left66, positions.left34})
end

local function moveRight()
  move({positions.right50, positions.right66, positions.right34})
end

local function moveTop()
  move({positions.upper50})
end

local function moveBottom()
  move({positions.lower50})
end

local function moveTopLeft()
  move({positions.upper50Left50})
end

local function moveTopRight()
  move({positions.upper50Right50})
end

local function moveBottomLeft()
  move({positions.lower50Left50})
end

local function moveBottomRight()
  move({positions.lower50Right50})
end

local function moveWindow()
  local window = getWindow()
  local screen = window:screen()

  window:move(window:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end

local function hideAlreadyRunningApplication(bundleID)
  local focus = getWindow()

  if focus and focus:application():bundleID() == bundleID then
    focus:application():hide()
    return true
  else
    return false
  end
end

local function activeRunningApplication(bundleID)
  local running = hs.application.applicationsForBundleID(bundleID)

  if #running > 0 and #running[1]:allWindows() > 0 then
    running[1]:activate()
    return true
  else
    return false
  end
end

local function launchApplication(bundleID)
  hs.application.launchOrFocusByBundleID(bundleID)
end

local function toggleApplication(bundleID)
  return function()
    if hideAlreadyRunningApplication(bundleID) then
      return
    elseif activeRunningApplication(bundleID) then
      return
    else
      launchApplication(bundleID)
    end
  end
end

return {
  maximize = maximize,
  moveLeft = moveLeft,
  moveRight = moveRight,
  moveTop = moveTop,
  moveBottom = moveBottom,
  moveTopLeft = moveTopLeft,
  moveTopRight = moveTopRight,
  moveBottomLeft = moveBottomLeft,
  moveBottomRight = moveBottomRight,
  moveWindow = moveWindow,
  toggleApplication = toggleApplication,
}
