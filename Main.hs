import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
  ( doCenterFloat,
    isDialog,
    isInProperty,
  )
import XMonad.Hooks.Place (placeHook, simpleSmart)
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Fullscreen
  ( fullscreenManageHook,
  )
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedWindows
import XMonad.Util.Run

myManageHook :: ManageHook
myManageHook =
  composeAll
    [ fullscreenManageHook,
      isDialog --> doCenterFloat,
      className =? "Pavucontrol" --> doCenterFloat,
      className =? "pinentry" --> doCenterFloat, -- matches for pinentry-qt
      resource =? "pinentry" --> doCenterFloat, -- matches for pinentry-gtk (wtf?)
      className =? "Nm-connection-editor" --> doFloat,
      title =? "PlayOnLinux" --> doFloat,
      title =? "Steam Keyboard" --> doIgnore,
      stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog" --> (doCenterFloat <+> doF W.swapMaster),
      isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH" --> doIgnore,
      isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_NOTIFICATION" --> doIgnore,
      className =? "Gimp" --> doFloat,
      className =? "Vncviewer" --> doFloat,
      placeHook simpleSmart
    ]

main :: IO ()
main = do
  -- xmproc <- spawnPipe "/home/shae/.cabal/bin/xmobar /home/shae/.xmobarrc"
  xmonad $
    ewmhFullscreen . ewmh $
      def
        { manageHook =
            manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
              <+> manageHook def,
          layoutHook = avoidStruts $ layoutHook def,
          -- , logHook = dynamicLogWithPP xmobarPP
          --                 { ppOutput = hPutStrLn xmproc
          --                 , ppTitle = xmobarColor "green" "" . shorten 50
          --                 }
          modMask = mod4Mask, -- Rebind Mod to the Windows key
          startupHook = startup
        }
        `additionalKeys` [ ((mod4Mask .|. shiftMask, xK_z), spawn "slock"),
                           ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s"),
                           ((0, xK_Print), spawn "scrot")
                           -- , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 1 +1%; pactl set-sink-volume 2 +1%")
                           -- , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 1 -1%; pactl set-sink-volume 2 -1%")
                           -- , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 1 toggle; pactl set-sink-mute 2 toggle")
                           -- , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -steps 3 -inc 5")
                           -- , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -steps 3 -dec 5")
                         ]
          `removeKeys` [(mod4Mask, xK_l)]

startup :: X ()
startup = do
  spawn "trayer --edge bottom --align right --SetDockType true --SetPartialStrut true --expand true --widthtype request --height 25"
  spawn "nm-applet"

-- from https://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name <- getName w
    Just idx <- (W.findTag w) <$> gets windowset

    safeSpawn "notify-send" [show name, "workspace " ++ idx]
