import Control.Concurrent
import Control.OldException(catchDyn,try)
import DBus
import DBus.Connection
import DBus.Message
import System.Cmd
import System.IO
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.SimpleFloat
import XMonad.Util.Run
import qualified Data.Map as M
import qualified XMonad.StackSet as W

main = withConnection Session $ \ dbus -> do
    getWellKnownName dbus
    xmonad $ gnomeConfig {
        workspaces = myWorkspaces,
        startupHook = myStartupHook,
        layoutHook = myLayout,
        manageHook = myManageHook,
        logHook = composeAll [
            dynamicLogWithPP (myPrettyPrinter dbus),
            logHook gnomeConfig
            ],
        keys = myKeys,
        modMask = mod4Mask,
        normalBorderColor = "#474642",
        focusedBorderColor = "#009900",
        borderWidth = 2
        }

myStartupHook = composeAll [
    setWMName "LG3D",
    startupHook gnomeConfig
    ]


myWorkspaces = ["1", "2", "3:im", "4", "5", "6", "7", "8:float", "9"]

myManageHook = composeAll
   [ resource =? "Do"       --> doIgnore,            -- Ignore GnomeDo
     resource =? "Pidgin"   --> doShift "3:im",      -- Shift Pidgin to im desktop
     className =? "empathy"  --> doShift "3:im",     -- Shift Empathy to im desktop
     resource =? "gimp"     --> doShift "8:float",   -- gimp on floating
     resource =? "gimp-2.6" --> doShift "8:float",   -- gimp on floating
     manageDocks,
     manageHook gnomeConfig ]

keysToAdd x = [ -- Gnome close window
                -- ,  ((modMask x, xK_F4), kill)
                -- Shift to previous workspace
                  (((modMask x .|. controlMask), xK_Left), prevWS)
                -- Shift to next workspace
                ,  (((modMask x .|. controlMask), xK_Right), nextWS)
                -- Shift window to previous workspace
                ,  (((modMask x .|. shiftMask), xK_Left), shiftToPrev)
                -- Shift window to next workspace
                ,  (((modMask x .|. shiftMask), xK_Right), shiftToNext)
              ]

myKeys x = M.union (keys gnomeConfig x) (M.fromList (keysToAdd x))

myLayout = avoidStruts $
    onWorkspace "3:im" imLayout $
    onWorkspace "8:float" simpleFloat $
    layoutHook gnomeConfig
    where
        imLayout = withIM (1/8) (Title "Contact List") (Mirror Grid)

-- code below comes from developer of gnome-xmonad-applet

myPrettyPrinter :: Connection -> PP
myPrettyPrinter dbus = defaultPP {
    ppOutput  = outputThroughDBus dbus
  , ppTitle   = pangoColor "#009900" . shorten 50 . pangoSanitize
  , ppCurrent = pangoColor "#05c000" . wrap "[" "]" . pangoSanitize
  , ppVisible = pangoColor "#007be9" . wrap "(" ")" . pangoSanitize
  , ppHidden  = wrap " " " "
  , ppUrgent  = pangoColor "red"
  }

-- This retry is really awkward, but sometimes DBus won't let us get our
-- name unless we retry a couple times.
getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn` (\ (DBus.Error _ _) ->
                                                getWellKnownName dbus)
    where
     tryGetName = do
      namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
      addArgs namereq [String "org.xmonad.Log", Word32 5]
      sendWithReplyAndBlock dbus namereq 0
      return ()

outputThroughDBus :: Connection -> String -> IO ()
outputThroughDBus dbus str = do
    let str' = "<span font=\"Terminus 9 Bold\">" ++ str ++ "</span>"
    msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" "Update"
    addArgs msg [String str']
    send dbus msg 0 `catchDyn` (\ (DBus.Error _ _ ) -> return 0)
    return ()

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
    where
        left  = "<span foreground=\"" ++ fg ++ "\">"
        right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
    where
        sanitize '>'  acc = "&gt;" ++ acc
        sanitize '<'  acc = "&lt;" ++ acc
        sanitize '\"' acc = "&quot;" ++ acc
        sanitize '&'  acc = "&amp;" ++ acc
        sanitize x    acc = x:acc
