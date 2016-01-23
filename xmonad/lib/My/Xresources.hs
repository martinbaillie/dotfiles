module My.Xresources (xdefault) where

-- Needs: cabal install X11-rm
import Graphics.X11.XRM
import Graphics.X11.Xlib

xdefault :: String -> IO (Maybe String)
xdefault xd = openDisplay "" >>= (\dpy -> getDefault dpy "*" xd)
