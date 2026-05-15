-- #######################################################################################
-- HYPRLAND LUA CONFIG - FULL VERSION (v0.55.0 Official API)
-- #######################################################################################

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- hl.monitor({
--     output   = "eDP-2",
--     mode     = "2560x1600@30",
--     position = "0x0",
--     scale    = "1",
-- })

hl.monitor({
    output   = "",          -- Empty string means "any monitor"
    mode     = "preferred", -- Uses the highest resolution and refresh rate available
    position = "auto",      -- Automatically places it in the workspace layout
    scale    = "1",         -- You can set this to "auto", but "1" ensures no scaling artifacts
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal            = "kitty"
local fileManager         = "thunar"
local menu                = "rofi -show drun"
local terminalFileManager = "yazi"
local codeEditor          = "cursor"
local browser             = "brave"
local notes               = "obsidian"
local powerMenu           = "zsh ~/.config/rofi/powermenu.sh"
local themeSwitcher       = "zsh ~/.config/rofi/theme_switcher.sh"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
    -- 1. Infrastructure
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    
    -- 2. Desktop Components
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("nm-applet --indicator")
    
    -- 3. Others
    hl.exec_cmd("languagetool --http")
    hl.exec_cmd("awww-daemon")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 5,
        border_size      = 2,
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 5,
        },

        blur = {
            enabled           = true,
            size              = 15,
            passes            = 3,
            vibrancy          = 0.1,
            new_optimizations = true,
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        -- 'pseudotile' is omitted here due to schema errors; use the keybind to toggle.
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Curves (Beziers)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Animations (Mandatory 'enabled = true' on every layer)
hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",      enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

-- Core System Binds
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",         hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload && pkill waybar && hyprctl dispatch exec waybar"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("hyprshade toggle grayscale"))

-- Program Binds
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(codeEditor))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(terminal .. " -e " .. terminalFileManager))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(notes))
hl.bind(mainMod .. " + ESCAPE",    hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("hyprshot -m region --freeze --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --freeze -o ~/screenshots"))
hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd(powerMenu))

-- Window Navigation (HJKL)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Swap Windows (SHIFT + HJKL)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspaces (Scratchpads)
hl.bind(mainMod .. " + M",         hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:music" }))
hl.bind(mainMod .. " + grave",     hl.dsp.workspace.toggle_special("terminal"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:terminal" }))
hl.bind(mainMod .. " + X",         hl.dsp.workspace.toggle_special("secrets"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "special:secrets" }))

-- Multimedia Keys (Locked & Repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),  { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),             { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),             { locked = true, repeating = true })

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Maximize suppression
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Workspace 1: Browsers
hl.window_rule({
    name  = "browsers",
    match = { initial_class = "(?i)^(brave-browser|firefox|zen)$" },
    workspace = "1",
})

-- Workspace 2: Cursor (Known Working)
hl.window_rule({
    name  = "editor",
    match = { initial_class = "(?i)^(cursor)$" },
    workspace = "2 silent",
})

-- Workspace 3: DB Tools
hl.window_rule({
    name  = "db-tools",
    match = { initial_class = "(?i)^(beekeeper-studio|DBeaver)$" },
    workspace = "3",
})

-- Workspace 5: Notes/Docs
hl.window_rule({
    name  = "notes-docs",
    match = { initial_class = "(?i)^(com\\.github\\.johnfactotum\\.Foliate|libreoffice-writer|obsidian|calibre-gui)$" },
    workspace = "5",
})

-- Workspace 6: Social/Communication (Discord, etc)
hl.window_rule({
    name  = "social",
    match = { initial_class = "(?i)^(zoom|Signal|Slack|discord)$" },
    workspace = "6",
})

-- Workspace 10: Steam
hl.window_rule({
    name  = "steam",
    match = { initial_class = "(?i)^(steam)$" },
    workspace = "10",
})

-- SPECIAL: Music (Spotify)
hl.window_rule({
    name  = "spotify-special",
    match = { initial_class = "(?i)^(Spotify)$" },
    workspace = "special:music",
})

-- SPECIAL: Terminal (Kitty)
hl.window_rule({
    name  = "kitty-special",
    match = { initial_class = "(?i)^(kitty)$" },
    workspace = "special:terminal",
})

-- SPECIAL: Secrets
hl.window_rule({
    name  = "secrets-special",
    match = { initial_class = "(?i)^(AWS VPN Client|org\\.keepassxc\\.KeePassXC)$" },
    workspace = "special:secrets",
})

-- Opacity for terminals
hl.window_rule({
    name  = "terminal-opacity",
    match = { initial_class = "^(Alacritty|kitty)$" },
    opacity = "1.0 0.90",
})

-- Source external legacy .conf file
hl.exec_cmd("hyprctl keyword source ~/.config/rices/current/hypr.conf")
