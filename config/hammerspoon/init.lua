local utils = require "utils"
local leader = {"ctrl", "alt"} -- tends to not conflict with anything else

hs.logger.defaultLogLevel = 'verbose'
hs.window.animationDuration = 0

-- Run or raise Application launching
-- osascript -e 'id of app "<Application>"'
hs.hotkey.bind({"ctrl", "cmd"}, "1", utils.toggleApplication(
    "org.gnu.Emacs",
    os.getenv("HOME") .. "/Applications/Nix Apps/Emacs.app"
    -- "/Applications/Emacs"
))
hs.hotkey.bind({"ctrl", "cmd"}, "2", utils.toggleApplication("org.mozilla.firefox", nil))

-- Emacs edit / capture.
require("hs.ipc")
hs.hotkey.bindSpec({leader, "\\"},
  function ()
    hs.task.new("/bin/sh", nil, {
                  "-l",
                  "-c",
                  "XDG_RUNTIME_DIR=" .. os.getenv("HOME") .. "/.local/share" .. " " ..
                    "/run/current-system/sw/bin/emacsclient --eval '(emacs-everywhere)'"

    }):start()
  end
)

-- Bring all Finder windows to the the front.
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
      if (appName == "Finder") then
          -- Bring all Finder windows forward when one gets activated
          appObject:selectMenuItem({"Window", "Bring All to Front"})
      end
  end
end
finderWatcher = hs.application.watcher.new(applicationWatcher)
finderWatcher:start()

--------------------------------------------------------------------------------
-- External spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

-- https://www.hammerspoon.org/Spoons/ReloadConfiguration.html
Install:andUse('ReloadConfiguration', {start=true})
hs.notify.new({title="Hammerspoon", informativeText="Loaded"}):send()

-- Basic window movements
local almost_max = { x = 0.02, y = 0.02, w = 0.96, h = 0.95 }
hs.hotkey.bind(leader, 'c', function() hs.window.focusedWindow():move(almost_max,  nil, true) end)

-- http://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
Install:andUse(
  "WindowHalfsAndThirds", {
    config = {
      use_frame_correctness = true
    },
    hotkeys =
      {
        left_half   = { leader, "Left" },
        right_half  = { leader, "Right" },
        top_half    = { leader, "Up" },
        bottom_half = { leader, "Down" },
        max_toggle  = { leader, "Return" },
        larger      = { leader, "=" },
        smaller     = { leader, "-" },
      }
})

Install:andUse("WinWin", {})
if spoon.WinWin then
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function() spoon.WinWin:moveToScreen("left") end )
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function() spoon.WinWin:moveToScreen("right") end )
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Up", function() spoon.WinWin:moveToScreen("up") end )
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Down", function() spoon.WinWin:moveToScreen("down") end )
end

--------------------------------
-- START VIM CONFIG - https://github.com/dbalatero/VimMode.spoon
--------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

vim
  :disableForApp('Emacs')
  -- :disableForApp('Firefox')
  :disableForApp('Terminal')
  :disableForApp('zoom.us')
  :enterWithSequence('jk')
  -- :bindHotKeys({ enter = { {}, 'escape'} })
  :shouldDimScreenInNormalMode(false)
  :shouldShowAlertInNormalMode(true)
  :setAlertFont("Courier New")
  :enableBetaFeature('block_cursor_overlay')
