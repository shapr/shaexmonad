import           System.IO
import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Util.EZConfig     (additionalKeys)
import           XMonad.Util.Run          (spawnPipe)

myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    ]

main = do
    xmproc <- spawnPipe "/home/shae/.cabal/bin/xmobar /home/shae/.xmobarrc"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
                        <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , startupHook = startup
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "slock")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        -- , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 1 +1%; pactl set-sink-volume 2 +1%")
        -- , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 1 -1%; pactl set-sink-volume 2 -1%")
        -- , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 1 toggle; pactl set-sink-mute 2 toggle")
        -- , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -steps 3 -inc 5")
        -- , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -steps 3 -dec 5")

        ]

startup :: X()
startup = do
  spawn "trayer --edge bottom --align right --SetDockType true --SetPartialStrut true --expand true --widthtype request --height 25"
  spawn "nm-applet"
    
-- shae is awesome
