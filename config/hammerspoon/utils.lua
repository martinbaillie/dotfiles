local function getWindow()
  local window = hs.window.focusedWindow()

  if window == nil then
    return
  else
    return window
  end
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

local function toggleApplication(bundleID, path)
  return function()
    if hideAlreadyRunningApplication(bundleID) then
      return
    elseif activeRunningApplication(bundleID) then
      return
    else
      if path ~= nil then
        hs.application.launchOrFocus(path)
      else
        hs.application.launchOrFocusByBundleID(bundleID)
      end
    end
  end
end

return {
  toggleApplication = toggleApplication,
}
