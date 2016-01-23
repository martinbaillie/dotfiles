import My.Spacing                           (SPACING(SPACING), spacing)
import My.Xresources                        (xdefault)

import System.Environment                   (getEnv)
import System.Posix.IO                      (openFd, OpenMode(..), defaultFileFlags, fdWrite)

import Control.Monad                        (void)

import Data.Maybe                           (fromMaybe)

import XMonad

import XMonad.Util.EZConfig                 (additionalKeysP, removeKeysP)
import XMonad.Util.Run                      (spawnPipe, safeSpawn, runInTerm)
import XMonad.Util.Paste                    (pasteSelection) -- is this needed? alt-v?

import XMonad.Actions.WindowGo              (runOrRaise, raiseMaybe)

import XMonad.Layout.PerWorkspace           (onWorkspace)
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.NoBorders              (smartBorders)
import XMonad.Layout.BorderResize
import XMonad.Layout.Magnifier

import XMonad.Hooks.DynamicLog              (dynamicLogWithPP, PP(..))
import XMonad.Hooks.EwmhDesktops            (ewmh)
import XMonad.Hooks.ManageDocks             (avoidStruts, manageDocks)
import XMonad.Hooks.ManageHelpers           (doFullFloat)
import XMonad.Hooks.SetWMName

import qualified XMonad.StackSet as W       (swapMaster, focusDown, focusUp)

terminal' :: String
terminal' = "urxvtc"

focusFollowsMouse' :: Bool
focusFollowsMouse' = True

modMask' = mod4Mask

additionalKeys =
    [
      ("M-<Return>",              spawn terminal')
    , ("M-C-<Return>",            spawn "st -f 'Tewi-9'")

    , ("M-S-<Return>",            runOrRaise "chromium" (className =? "chromium"))
    , ("M-M1-<Return>",           runOrRaise "firefox"  (className =? "Iceweasel" <||>
                                                         className =? "Firefox"))

    , ("M-v",                     raiseMaybe (runInTerm "" "vim") (title =? "vim"))
    , ("M-n",                     raiseMaybe (runInTerm "" "ncmpcpp") (title =? "^ncmpcpp"))

    , ("M-e",                     spawn "pcmanfm")
    , ("M-S-l",                   spawn "slimlock")
    , ("M-S-q",                   spawn "pkill lemonbar; xmonad --recompile && xmonad --restart")

    , ("M-w",                     kill)

    , ("M-m",                     windows W.swapMaster)
    , ("M1-<Tab>",                windows W.focusDown)
    , ("M1-S-<Tab>",              windows W.focusUp)

    , ("M1-<Space>",              spawn "~/Code/bin/spawn_dmenu")

    , ("<Print>",                 spawn "scrot -e 'mv $f ~/Pictures/ 2>/dev/null'")
    , ("M-<Print>",               spawn "scrot -u -e 'mv $f ~/Pictures/ 2>/dev/null'")

    , ("<XF86Sleep>",             spawn "systemctl suspend")

    , ("<XF86MonBrightnessUp>",   spawn "xbacklight +5")
    , ("<XF86MonBrightnessDown>", spawn "xbacklight -5")

    , ("M-M1-<Page_Up>",          spawn "xbacklight +5")
    , ("M-M1-<Page_Down>",        spawn "xbacklight -5")

    , ("<XF86AudioRaiseVolume>",  spawn "amixer -q sset Master '3%+' unmute")
    , ("<XF86AudioLowerVolume>",  spawn "amixer -q sset Master '3%-' unmute")
    , ("<XF86AudioMute>",         spawn "amixer -q sset Master toggle")

    , ("M-M1-<Up>",               spawn "amixer -q sset Master '3%+' unmute")
    , ("M-M1-<Down>",             spawn "amixer -q sset Master '3%-' unmute")
    , ("M-M1-<End>",              spawn "amixer -q sset Master toggle")

    , ("<XF86AudioPlay>",         spawn "mpc toggle")
    , ("<XF86AudioNext>",         spawn "mpc next")
    , ("<XF86AudioPrev>",         spawn "mpc prev")

    , ("M-M1-<Left>",             spawn "mpc prev")
    , ("M-M1-<Right>",            spawn "mpc next")
    , ("M-M1-<Home>",             spawn "mpc toggle")

    , ("M-h",                     sendMessage $ ExpandTowards L)
    , ("M-j",                     sendMessage $ ExpandTowards D)
    , ("M-k",                     sendMessage $ ExpandTowards U)
    , ("M-l",                     sendMessage $ ExpandTowards R)
    , ("M-s",                     sendMessage $ Swap)
    , ("M-r",                     sendMessage $ Rotate)
    , ("M-b",                     sendMessage $ Balance)
    , ("M-<Page_Up>",             sendMessage $ SPACING 5)
    , ("M-<Page_Down>",           sendMessage $ SPACING (negate 5))
    ]

removeKeys =
    [
    "M-p"
    , "M-S-p"
    , "M-c"
    ]

layoutHook' = smartBorders
    $ borderResize
    $ spacing 20
    $ avoidStruts
    $ emptyBSP
    |||
    onWorkspace "1" (magnifiercz 1.5 emptyBSP) (magnifiercz 1.1 emptyBSP)

manageHook' :: ManageHook
manageHook' = manageDocks <+>
    composeAll
        [ className =? "Transgui"       --> doFloat
        , className =? "Gimp"           --> doFloat
        , className =? "chromium"       --> doShift "2"
        , className =? "Firefox"        --> doShift "2"
        , className =? "Iceweasel"      --> doShift "2"
        , className =? "Slack"          --> doShift "3"
        , className =? "Nixnote2"       --> doShift "4"
        , className =? "VirtualBox"     --> doShift "6"
        , className =? "VirtualBox"     --> doFloat
        , className =? "Wfica_Seamless" --> doShift "5"
        , className =? "Wfica_Seamless" --> doFullFloat
        , className =? "Wfica"          --> doShift "5"
        , className =? "Wfica"          --> doFullFloat ]

logHook' fd = dynamicLogWithPP def
    { ppCurrent         = const "a"
    , ppVisible         = const "o"
    , ppHidden          = const "o"
    , ppHiddenNoWindows = const "i"
    , ppUrgent          = const "u"
    , ppOrder           = \(ws:_:t:_) -> ["W" ++ ws, t]
    , ppOutput          = \s -> void $ fdWrite fd (s ++ "\n")
    }

main :: IO ()
main = do
    fifo                        <- getEnv "PANEL_FIFO"
    pipe                        <- openFd fifo WriteOnly Nothing defaultFileFlags
    normalBorderColor'          <- xdefault "color1"
    focusedBorderColor'         <- xdefault "color4"
    xmonad
        $ ewmh
        $ defaultConfig
        { modMask               = modMask'
        , terminal              = terminal'
        , focusFollowsMouse     = focusFollowsMouse'
        , layoutHook            = layoutHook'
        , manageHook            = manageHook'
        , logHook               = logHook' pipe 
        , startupHook           = setWMName "LG3D" {- JVM window parenting hack -}
        , normalBorderColor     = fromMaybe "gray" normalBorderColor'
        , focusedBorderColor    = fromMaybe "green" focusedBorderColor'
        } `additionalKeysP` additionalKeys `removeKeysP` removeKeys
