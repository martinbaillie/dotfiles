local utils = require "utils"
local leader = {"ctrl", "alt"} -- tends to not conflict with anything else

hs.notify.new({title="Hammerspoon", informativeText="Loaded"}):send()

hs.logger.defaultLogLevel = 'verbose'
hs.window.animationDuration = 0

-- Standard binds
hs.hotkey.bind({"cmd", "shift"}, "r", hs.reload)

-- Run or raise Application launching
-- osascript -e 'id of app "<Application>"'
hs.hotkey.bind({"ctrl", "cmd"}, "1", utils.toggleApplication(
    "org.gnu.Emacs",
    os.getenv("HOME") .. "/Applications/Emacs.app"
))
hs.hotkey.bind({"ctrl", "cmd"}, "2", utils.toggleApplication("org.mozilla.firefox", nil))

-- Emacs edit / capture.
-- FIXME BROKEN AGAIN
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

--------------------------------------------------------------------------------
-- External spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

-- Basic window movements
--
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
