{-# LANGUAGE DeriveDataTypeable, NoMonomorphismRestriction, MultiParamTypeClasses, ImplicitParams #-}
-------------------------------------------------------------------------------
-- | Allows dynamic modification of window spacing
-- ----------------------------------------------------------------------------
module My.Spacing (
               Spacing(..)
               , SPACING(..)
               , spacing
               ) where

import Graphics.X11 (Rectangle(..))
import Control.Arrow (second)
import XMonad.Util.Font (fi)

import XMonad.Layout.LayoutModifier
import XMonad.Core
import XMonad.StackSet (integrate', stack, Stack(..) )



data Spacing a = Spacing Int deriving (Show, Read)
data SPACING = SPACING Int  deriving (Read, Show, Eq, Typeable)

spacing :: Int -> l a -> ModifiedLayout Spacing l a
spacing p = ModifiedLayout (Spacing p)

instance Message SPACING

instance LayoutModifier Spacing a where

  modifyLayout eqsp workspace screen =
          runLayout workspace $ shrinkScreen eqsp ((length $ integrate' $ stack workspace) - 1) screen
  pureModifier eqsp _ stck windows =
           (map (second $ shrinkWindow eqsp ((length $ integrate' stck) - 1)) windows, Nothing)

  pureMess (Spacing x) m = case fromMessage m of
      Just (SPACING n) -> if x+n >= 0
                         then Just $ Spacing (x+n)
                         else Just $ Spacing x
      Nothing -> Nothing

  modifierDescription (Spacing p) = "Spacing " ++ show p

shrinkRect :: Int -> Rectangle -> Rectangle
shrinkRect p (Rectangle x y w h) = Rectangle (x+fi p) (y+fi p) (w-2*fi p) (h-2*fi p)

shrinkScreen :: Spacing a -> Int -> Rectangle -> Rectangle
shrinkScreen (Spacing sp) num (Rectangle x y w h) =
    Rectangle x y (w-fi sp) (h-fi sp)

shrinkWindow :: Spacing a -> Int -> Rectangle -> Rectangle
shrinkWindow (Spacing sp) num (Rectangle x y w h) =
    Rectangle (x+fi sp) (y+fi sp) (w-fi sp) (h-fi sp)
