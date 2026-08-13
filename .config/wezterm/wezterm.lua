local wezterm = require('wezterm')
local config = wezterm.config_builder()

local act = wezterm.action

-- options
config.disable_default_key_bindings = true
config.scrollback_lines = 10000
config.window_close_confirmation = 'NeverPrompt'
config.hide_mouse_cursor_when_typing = false
-- config.term = 'xterm-256color'
config.term = 'wezterm'  -- full key/feature fidelity; needs wezterm terminfo on each machine
config.swallow_mouse_click_on_window_focus = true
config.swallow_mouse_click_on_pane_focus = true

-- gui
config.color_scheme = 'Dracula'
config.window_background_image =
  '/home/eduardo/Pictures/WallpapersDev/weylandYutani.jpg'
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.35,
}
config.tab_bar_at_bottom = true
-- config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'NONE'  -- no titlebar, no integrated buttons; resize via Super+RMB in Hyprland
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
-- font
config.font = wezterm.font_with_fallback({
  'FiraCode Nerd Font',
  'JetBrainsMono NFM',
  -- 'JetBrainsMono NFM',
  -- 'FiraCode Nerd Font',
  'Symbols Nerd Font',
  'Symbols Nerd Font Mono',
  'Noto Color Emoji',
})
-- config.font_size = 11.8
config.font_size = 13.5
config.font_rules = {
  {
    intensity = 'Bold',
    font = wezterm.font({
      family = 'JetBrainsMono NFM',
      weight = 'ExtraBold',
    }),
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font({
      family = 'JetBrainsMono NFM',
      weight = 'ExtraBold',
      style = 'Italic',
    }),
  },
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font({
      family = 'FiraCode Nerd Font',
      style = 'Italic',
    }),
  },
}

-- key Maps

local function is_vim(pane)
  -- this is set by the plugin smart-splits, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

-- wants_ctrl_hjkl reports whether the pane's program should receive CTRL+hjkl
-- itself instead of it being consumed for pane navigation.
--
-- This deliberately does NOT look at the foreground process name: a TUI
-- launched from a shell function via $(command foo) leaves the shell as the
-- leader of the tty's foreground process group, so the check would report
-- "zsh". Programs announce themselves with a user var instead, the same
-- mechanism smart-splits uses for Neovim.
local function wants_ctrl_hjkl(pane)
  if is_vim(pane) then
    return true
  end
  -- ,j2 (the fuzzy directory picker) sets this while it owns the terminal.
  return pane:get_user_vars().JUMP2_ACTIVE == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if wants_ctrl_hjkl(pane) then
        -- pass the keys through to vim/nvim (or another TUI that wants them)
        win:perform_action({
          SendKey = {
            key = key,
            mods = resize_or_move == 'resize' and 'META' or 'CTRL',
          },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action(
            { AdjustPaneSize = { direction_keys[key], 3 } },
            pane
          )
        else
          win:perform_action(
            { ActivatePaneDirection = direction_keys[key] },
            pane
          )
        end
      end
    end),
  }
end

local domains = { 'unix-1', 'unix-2', 'unix-3' }
local domainsUsed = 0
local function attachDomain()
  if domainsUsed >= 3 then
    return
  end

  local domain = domains[domainsUsed + 1]
  domainsUsed = domainsUsed + 1

  -- window:perform_action(act.AttachDomain(domain))

  act.AttachDomain(domain)
end

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 2000 }
config.keys = {
  { key = 'V', mods = 'CTRL', action = act.PasteFrom('Clipboard') },
  { key = 'C', mods = 'CTRL', action = act.CopyTo('Clipboard') },
  -- tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  {
    key = 'Q',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab({ confirm = true }),
  },
  --panes
  {
    key = 's',
    mods = 'LEADER',
    action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
  },
  {
    key = 'v',
    mods = 'LEADER',
    action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
  },
  { key = 'm', mods = 'LEADER', action = act.TogglePaneZoomState },
  {
    key = 'q',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- move/resize
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),

  -- simulate zoom with font size
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- navigation
  { key = ' ', mods = 'LEADER', action = wezterm.action.ShowTabNavigator },

  {
    key = 'w',
    mods = 'LEADER',
    action = act.ShowLauncherArgs({
      flags = 'FUZZY|WORKSPACES',
    }),
  },

  {
    key = 'W',
    mods = 'LEADER',
    action = act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
        end
      end),
    }),
  },

  {
    key = 't',
    mods = 'LEADER',
    -- action = act.AttachDomain('unix'),
    action = wezterm.action_callback(attachDomain),
  },

  -- remote mux: attach the tower's wezterm-mux-server over ssh (client-side; used from the laptop)
  { key = 'r', mods = 'LEADER', action = act.AttachDomain('langoliers') },

  { key = 'l', mods = 'LEADER', action = wezterm.action.ShowDebugOverlay },

  -- multiline enter (claude code)
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action({
      SendString = '\x1b\r',
    }),
  },

  -- TODO:
  -- bind S choose-tree
  -- # w does something similar
  -- unbind q
  -- bind q kill-pane
  -- unbind Q
  -- bind Q kill-session
}

-- mouse: select-to-copy. Finishing a left-drag selection copies to both the
-- system clipboard and the primary selection (Hyprland middle-click paste still
-- works). Overriding plain Left-Up disables the default link-open-on-click, so
-- Ctrl+click is rebound to open links.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        act.CompleteSelection('ClipboardAndPrimarySelection'),
        pane
      )
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        -- toast_notification() goes through the xdg-desktop-portal on Wayland,
        -- which ignores the timeout and always parks the notification in the
        -- panel/history. Call notify-send directly (org.freedesktop.Notifications)
        -- with an explicit transient hint so swaync auto-dismisses it and never
        -- adds it to history.
        wezterm.background_child_process({
          'notify-send',
          '-a', 'WezTerm',
          '-t', '1000',
          '-h', 'boolean:transient:true',
          'Copied',
          #sel .. ' chars to clipboard',
        })
      end
    end),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- MULTIPLXER
-- old loop reassigned config.unix_domains each pass, so only the last domain (unix-3) survived:
-- for _, domain in ipairs(domains) do
--   config.unix_domains = {
--     {
--       name = domain,
--     },
--   }
-- end
config.unix_domains = {}
for _, domain in ipairs(domains) do
  table.insert(config.unix_domains, { name = domain })
end

-- remote mux: connect from the laptop to the tower (langoliers).
-- harmless/unused on the tower itself. user/port(6922)/identity come from
-- the `Host langoliers` block in ~/.ssh/config.
config.ssh_domains = {
  {
    name = 'langoliers',
    remote_address = 'langoliers',
    multiplexing = 'WezTerm',  -- spawn wezterm-mux-server remotely: local render + persistence
  },
}
-- config.unix_domains = {
--   {
--     name = 'unix',
--   },
-- }
-- config.default_gui_startup_args = { 'connect', 'unix' }

-- PLUGINS
-- require('plugins/barWezterm').setup(config)
require('plugins/tablineWez').setup(config)

-- the tabline plugin's apply_to_config forces window_decorations = 'RESIZE',
-- which leaves a thin CSD strip at the top on Wayland. Override it after.
config.window_decorations = 'NONE'

-- COLORS
config.colors = {
  tab_bar = {
    background = '#282a36',
    active_tab = {
      bg_color = '#44475a',
      fg_color = '#f8f8f2',
    },
    inactive_tab = {
      bg_color = '#282a36',
      fg_color = '#6272a4',
    },
    inactive_tab_hover = {
      bg_color = '#44475a',
      fg_color = '#f8f8f2',
    },
  },

  background = '#1c1c1c',
  foreground = '#D8DEE9',

  ansi = {
    '#3B4252',
    '#e06c75',
    '#A3BE8C',
    '#EBCB8B',
    '#81A1C1',
    '#B48EAD',
    '#88C0D0',
    '#abb2bf',
  },

  brights = {
    '#5c6370',
    '#BF616A',
    '#98c379',
    '#d19a66',
    '#61afef',
    '#c678dd',
    '#56b6c2',
    '#ECEFF4',
  },
}

-- wezterm.on('gui-startup', function(window, pane)
--   window:toast_notification(
--     'My Title',
--     'This notification has a 🎉emoji!',
--     nil,
--     5000
--   )
-- end)

return config
