-- Lua port of hyprland.conf (2026-10-14). hyprland.conf is kept only as a
-- reference: Hyprland 0.57 stops reading it.
-- API stubs for the installed version: /usr/share/hypr/stubs/hl.meta.lua

-- ===== Monitors =====
-- Run `hyprctl monitors` to find your output names. Adjust resolution/refresh/position.
hl.monitor({ output = "DP-1",     mode = "2560x1440@144", position = "0x0",    scale = "1" })
hl.monitor({ output = "DP-2",     mode = "1920x1080@100", position = "2560x0", scale = "1", transform = 3 })
-- transform: 0=normal 1=90° 2=180° 3=270°. Use 1 or 3 for vertical, depending on which side faces up.

-- ===== Environment =====
-- mongo compass needs GNOME in this list to find the libsecret backend;
-- Hyprland is listed first so it remains the primary desktop identity.
-- hl.env("XDG_CURRENT_DESKTOP", "Hyprland:GNOME")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")   -- native Wayland for Electron (VSCode, your TS apps)
hl.env("MOZ_ENABLE_WAYLAND", "1")                   -- Firefox native Wayland
hl.env("QT_QPA_PLATFORM", "wayland;xcb")            -- Qt apps prefer Wayland, fall back to xcb
hl.env("SDL_VIDEODRIVER", "wayland")                -- SDL games (some emulators)
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")          -- fix Java GUI apps
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "Adwaita-dark")
hl.env("XCURSOR_THEME", "phinger-cursors-light")

-- ===== Autostart =====
-- Runs once at login (was exec-once). hl.exec_cmd outside this block would
-- run again on every config reload.
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd("ags run -d ~/.config/ags")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("waypaper --restore")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("thunderbird")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hypridle")
    -- Refresh waybar's custom/layout module on workspace/monitor focus changes
    hl.exec_cmd([[sh -c 'socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while IFS= read -r line; do case "$line" in workspace*|focusedmon*|configreloaded*) pkill -SIGRTMIN+8 waybar 2>/dev/null ;; esac; done']])
end)
hl.bind("mouse_down", hl.dsp.exec_cmd("~/.local/bin/wheel-focus.sh"), { non_consuming = true })
hl.bind("mouse_up",   hl.dsp.exec_cmd("~/.local/bin/wheel-focus.sh"), { non_consuming = true })

-- Shift held at left release, after a drag, copies the selection to the clipboard
-- (WezTerm's own Shift+release, everywhere). ignore_mods: release binds otherwise
-- match the mods held at press time, so Shift pressed mid-drag would never fire.
local shift_copy_press
hl.bind("mouse:272", function()
    shift_copy_press = hl.get_cursor_pos()
end, { non_consuming = true, ignore_mods = true })
hl.bind("mouse:272", function()
    if not (hl.is_key_down("Shift_L") or hl.is_key_down("Shift_R")) then return end
    -- a plain Shift+click (open link in new window, extend selection) is not a copy
    local c, p = hl.get_cursor_pos(), shift_copy_press
    if p and c and math.abs(c.x - p.x) + math.abs(c.y - p.y) < 4 then return end
    -- WezTerm already does this itself
    local w = hl.get_active_window()
    if w and w.class == "org.wezfurlong.wezterm" then return end
    hl.exec_cmd("~/.local/bin/shift-copy.sh")
end, { non_consuming = true, ignore_mods = true, release = true })

-- ===== Input =====
hl.config({
    input = {
        kb_layout = "gb",
        follow_mouse = 0,     -- focus only on click; ws.sh reads cursorpos directly to keep awesome-style per-monitor workspace switching
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
        tablet = {
            output = "DP-1",
        },
    },
})

hl.device({
    name = "logitech-mx-master-2s-1",
    sensitivity = 0,
    accel_profile = "flat",
    scroll_factor = 1.0,
})

hl.device({
    name = "logitech-wireless-mouse-mx-master-2s-1",
    sensitivity = 0,
    accel_profile = "flat",
    scroll_factor = 1.0,
})

hl.config({
    cursor = {
        no_warps = true,
        inactive_timeout = 0,
        hide_on_key_press = false,
        no_hardware_cursors = true,
    },
})

-- ===== General =====
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 1,
        border_size = 1,

        col = {
            active_border = "rgba(909090ff)",
            inactive_border = "rgba(2a2a2aff)",
        },
        --layout = "dwindle",             -- dwindle (binary, like 'fair') or master (master/stack, like 'tile')
        layout = "master",
    },

    decoration = {
        rounding = 0,

        -- Dim unfocused windows (replaces picom's inactive-dim = 0.15)
        dim_inactive = true,
        dim_strength = 0.15,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },
})

-- ===== Per-app opacity (replaces picom's opacity-rule) =====
-- Format: "ACTIVE INACTIVE" — single value applies to both.
hl.window_rule({ match = { class = [[org\.wezfurlong\.wezterm]] }, opacity = "0.90 0.80" })
hl.window_rule({ match = { class = "Alacritty" },                  opacity = "0.90 0.80" })

hl.config({ animations = { enabled = true } })
hl.curve("ease", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })
hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "ease" })

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "slave",        -- new windows go to stack, master stays
        orientation = "left",        -- uncomment for tile.bottom equivalent (master on top, stack below)
    },

    misc = {
        disable_splash_rendering = true,     -- hides "a day without Hyprland is a day wasted" at the bottom
        -- disable_hyprland_logo = true,     -- uncomment to also hide the central anime-girl logo on default background
        vrr = 0,                             -- FreeSync OFF. Tried vrr = 2 on 2026-09-14: DP-1 flickers badly in games,
                                             -- a panel trait of this AOC, not a config problem. Don't re-enable.
                                             -- Kept for reference: DP-1 (AOC Q27G2SG4) supports 48-155Hz VRR;
                                             -- DP-2 (MSI MP243X) is covered by vrr = 0 too. Panel refreshes when
                                             -- the frame is ready instead of on a fixed 143Hz schedule, so uneven
                                             -- frametimes stop turning into judder. 2 = fullscreen only (gamescope
                                             -- counts); 1 = always, which can flicker on the desktop. Set 0 to revert.
    },
})

-- ===== Keybinds (ported from your AwesomeWM config) =====
local exec = hl.dsp.exec_cmd

-- --- Apps & Launchers ---
hl.bind("SUPER + Return", exec("wezterm"))
hl.bind("SUPER + F1",     exec("wezterm start -- yazi"))                    -- file manager
hl.bind("SUPER + F2",     exec("uwsm app -- com.brave.Browser.desktop"))
hl.bind("SUPER + 0",      exec("powerdmenu"))                               -- your custom power menu
hl.bind("SUPER + space",  exec("fuzzel"))                                   -- .desktop app launcher
hl.bind("SUPER + d",      exec("launch-cmd"))                               -- any PATH binary (script in section 3.5)

-- --- WM control ---
hl.bind("SUPER + CTRL + r",      exec("hyprctl reload"))                    -- reload config (was awesome.restart)
hl.bind("SUPER + CTRL + q",      hl.dsp.exit())                             -- quit Hyprland
hl.bind("SUPER + X",             exec("hyprlock"))                          -- screen lock
hl.bind("SUPER + equal",         exec("pkill -SIGUSR1 waybar || waybar &"))
hl.bind("SUPER + grave",         exec("swaync-client --close-latest"))      -- dismiss top notification
hl.bind("SUPER + SHIFT + grave", exec("swaync-client --close-all"))         -- dismiss all notifications
hl.bind("SUPER + CTRL + grave",  exec("swaync-client -t -sw"))              -- toggle notification center

-- --- Window control (your clientkeys) ---
hl.bind("SUPER + q",              exec("close-or-minimize"))                       -- close window (minimizes thunderbird to special workspace)
hl.bind("SUPER + SHIFT + m",      hl.dsp.workspace.toggle_special("thundermail"))  -- toggle thunderbird overlay
hl.bind("SUPER + n",              exec("toggle-stash"))                            -- stash/unstash window
hl.bind("SUPER + SHIFT + n",      hl.dsp.workspace.toggle_special("stash"))        -- toggle stash overlay
hl.bind("SUPER + SHIFT + q",      exec("hyprctl kill"))                            -- xkill: click window to SIGKILL, right-click to cancel
hl.bind("SUPER + f",              hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- true fullscreen (your 'max')
hl.bind("SUPER + m",              hl.dsp.window.fullscreen({ mode = "maximized" }))  -- maximize within tiles (no border)
hl.bind("SUPER + CTRL + space",   hl.dsp.window.float())                           -- floating toggle
hl.bind("SUPER + t",              hl.dsp.window.pin())                             -- pin to all workspaces (your 'keep on top')
hl.bind("SUPER + CTRL + Return",  hl.dsp.layout("swapwithmaster"))                 -- swap focused with master

-- --- Layout switching (replaces awful.layout.inc) ---
-- hl.bind("SUPER + w",         exec([[hyprctl eval 'hl.config({ general = { layout = "dwindle" } })']]))
-- hl.bind("SUPER + SHIFT + w", exec([[hyprctl eval 'hl.config({ general = { layout = "master" } })']]))
-- Cycle orientation on focused workspace (master-only; wrapper persists state + signals waybar)
hl.bind("SUPER + w",         exec("~/.config/hypr/scripts/orient.sh cycle"))
-- Toggle master ↔ dwindle (restores per-WS orientations on dwindle→master)
hl.bind("SUPER + SHIFT + w", exec("~/.config/hypr/scripts/orient.sh toggle"))

-- --- Focus: vim directional (separated from resize per your preference) ---
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
--hl.bind("SUPER + Tab", hl.dsp.focus({ last = true }))                     -- alternate with last focused
hl.bind("SUPER + Tab", exec("window-picker.sh"))

-- --- Move window: vim directional ---
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "right" }))

-- --- Resize active window: vim directional (works tiled and floating) ---
hl.bind("SUPER + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))
hl.bind("SUPER + CTRL + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))

-- --- Mouse drag (hold mod, click+drag) ---
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })   -- left-button drag = move
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })   -- right-button drag = resize

-- --- Workspaces (per-monitor, awesome-style: same keys, action follows cursor) ---
-- Script picks the right workspace ID based on which monitor is active:
--   DP-1     → 1..9
--   DP-2 → 11..19
for i = 1, 9 do
    hl.bind("SUPER + " .. i,         exec("~/.config/hypr/scripts/ws.sh switch " .. i))
    hl.bind("SUPER + SHIFT + " .. i, exec("~/.config/hypr/scripts/ws.sh move " .. i))
end

--hl.bind("SUPER + Escape", hl.dsp.focus({ workspace = "previous" }))     -- last workspace (your 'last tag')
hl.bind("SUPER + Escape",     hl.dsp.focus({ last = true }))              -- alternate with last focused
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))        -- mod+wheel = workspace switch
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- --- Screenshots ---
hl.bind("Print",         exec('grim -g "$(slurp)" - | swappy -f -'))      -- region → swappy editor
hl.bind("SHIFT + Print", exec("grim - | wl-copy"))                        -- full screen → clipboard

-- --- Clipboard history ---
hl.bind("SUPER + V", exec("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- --- Media keys ---
hl.bind("XF86AudioPlay",         exec("playerctl play-pause"),        { locked = true })
hl.bind("XF86AudioNext",         exec("playerctl next"),              { locked = true })
hl.bind("XF86AudioPrev",         exec("playerctl previous"),          { locked = true })
hl.bind("XF86AudioRaiseVolume",  exec("pamixer -i 5"),                { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  exec("pamixer -d 5"),                { locked = true, repeating = true })
hl.bind("XF86AudioMute",         exec("pamixer -t"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   exec("brightnessctl set +5%"),       { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"),       { locked = true, repeating = true })

-- ===== Workspace pinning =====
-- 9 persistent workspaces per monitor: 1-9 on DP-1, 11-19 on DP-2.
-- persistent keeps them in waybar even when empty.
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i),      monitor = "DP-1",     persistent = true, default = (i == 1), layout_opts = { orientation = "left" } })
    hl.workspace_rule({ workspace = tostring(10 + i), monitor = "DP-2", persistent = true, default = (i == 1), layout_opts = { orientation = "top" } })
end

-- ===== App placement rules (ported from Awesome) =====

-- --- Floating ---
hl.window_rule({ match = { class = "(?i)^(arandr|blueman-manager|gpick|kruler|messagewin|sxiv|wpa_gui|veromix|xtightvncviewer|qalculate-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^(Tor Browser)$" },             float = true })
hl.window_rule({ match = { class = "(?i)(pinentry|copyq|dta)" },    float = true })
hl.window_rule({ match = { class = "com.gabm.satty" },              float = true })
hl.window_rule({ match = { title = "^(Event Tester|Qalculate!)$" }, float = true })
-- GTK file picker (portal runs under XWayland, see xdg-desktop-portal-gtk.service.d/x11.conf)
-- Its tooltips are windows of the same class titled "xdg-desktop-portal-gtk"; the negative title keeps them out
hl.window_rule({ match = { class = "(?i)xdg-desktop-portal-gtk", initial_title = "negative:(?i)xdg-desktop-portal-gtk" }, float = true, size = "monitor_w*0.6 monitor_h*0.6", center = true })

-- --- Teams / Slack / Skype → ws 19 (DP-2), no switch ---
hl.window_rule({ match = { class = ".*teams_for_linux.*" },                     opacity = "0.85" })
hl.window_rule({ match = { class = ".*teams_for_linux.*" },                     workspace = "19 silent" })
hl.window_rule({ match = { class = "(?i).*microsoft.teams.*" },                 workspace = "19 silent" })
hl.window_rule({ match = { class = "(?i).*slack.*" },                           workspace = "19 silent" })
hl.window_rule({ match = { class = "(?i).*skype.*" },                           workspace = "19 silent" })
hl.window_rule({ match = { class = ".*crx_cifhbcnohmdccbgoicgdjpfamggdegmo.*" }, workspace = "19 silent" })
hl.window_rule({ match = { title = "^(Microsoft Teams.*|Skype.*)$" },           workspace = "19 silent" })
hl.window_rule({ match = { class = "(?i).*teams[-_]for[-_]linux.*" },           tile = true })
hl.window_rule({ match = { class = "(?i).*(microsoft.teams|slack|skype).*" },   tile = true })

-- --- Telegram / WhatsApp → ws 18 (DP-2), no switch ---
hl.window_rule({ match = { class = "(?i)(telegram[.-]?desktop)" },   workspace = "18 silent" })
hl.window_rule({ match = { title = "^(WhatsApp Web|Telegram)$" },     workspace = "18 silent" })
hl.window_rule({ match = { class = "(?i)(telegram[.-]?desktop)" },   tile = true })

-- --- Spotify → ws 17 (DP-2), no switch ---
hl.window_rule({ match = { class = "(?i)^spotify$" }, workspace = "17 silent" })
hl.window_rule({ match = { class = "(?i)^spotify$" }, tile = true })

-- --- Thunderbird → special:thundermail, no switch ---
hl.window_rule({ match = { class = "(?i).*(thunderbird|mail).*" }, workspace = "special:thundermail silent" })
hl.window_rule({ match = { class = "(?i).*(thunderbird|mail).*" }, tile = true })

-- --- Electron dev apps → reopen on the workspace they were hidden/closed on ---
-- Why: on every HMR save the app recreates windows or show()s hidden ones, and Hyprland
-- treats each as a brand-new window on the focused monitor, so a window hidden on DP-2
-- popped back up on DP-1. Wayland clients can't place their own windows, and the fix had
-- to stay out of the Electron project, so the compositor does it here.
-- How: hide() reaches Hyprland as window.close, so remember the workspace per class+title
-- there and move the window back on window.open_early. Kept in RAM; a config reload forgets
-- it. Add another Electron project's class to restore_classes to cover it too.
-- pid: only restore within the same app process; a fresh app start opens where you are.
-- no_initial_focus: a moved window would otherwise grab focus on map and pull it to its
-- monitor, away from the editor (the move dispatcher has no "silent" focus handling).
local restore_classes = { ["Ultima Workstation"] = true }
local restore_ws = {}
for class in pairs(restore_classes) do
    hl.window_rule({ match = { class = "^" .. class .. "$" }, no_initial_focus = true })
end
hl.on("window.close", function(w)
    if restore_classes[w.class] and w.workspace then
        restore_ws[w.class .. "|" .. w.title] = { ws = w.workspace.name, pid = w.pid }
    end
end)
hl.on("window.open_early", function(w)
    local saved = restore_classes[w.class] and restore_ws[w.class .. "|" .. w.title]
    if saved and saved.pid == w.pid then
        hl.dispatch(hl.dsp.window.move({ workspace = saved.ws, follow = false, window = w }))
    end
end)

-- ===== Intentionally dropped from your Awesome config =====
-- - Mod+c (quickconfig)             — no longer used
-- - Mod+/ (help popup)              — no native equivalent; can add a fuzzel cheatsheet later
-- - Mod+u (jump to urgent)          — Hyprland fires urgent events but no built-in dispatcher
-- - Mod+n (minimize)                — Hyprland has no minimize concept
-- - Mod+Ctrl+1..9 (multi-tag join)  — Hyprland workspaces are single-select
-- - Mod+Ctrl+Shift+1..9 (sticky)    — closest is Mod+t (pin to all workspaces)
-- - Mod+Ctrl+m / Mod+Shift+m (V/H maximize) — not directly available
-- - Mod+Ctrl+h/l (column count)     — dwindle/master are not multi-column
-- - Mod+Shift+h/l (master count)    — replaced by directional move; use `hyprctl dispatch 'hl.dsp.layout("addmaster")'` if missed
