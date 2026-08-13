local wezterm = require('wezterm')

local tabline =
  wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

local M = {}

-- remote-session marker --------------------------------------------------
-- shiny badge shown in the status bar whenever the active pane lives on a
-- remote mux domain (e.g. the tower 'langoliers' over the wezterm ssh mux).
-- returns '' for local/unix domains, so the badge simply vanishes at home.
local remoteBadgeBg = '#ff5555' -- Dracula red: unmissable
local remoteBadgeFg = '#1c1c1c' -- near-black text on the red
local remoteIcon = wezterm.nerdfonts.cod_remote
  or wezterm.nerdfonts.md_ssh
  or ''
local function remoteMarker(window)
  local domain = window:active_pane():get_domain_name()
  local is_remote = domain == 'langoliers' or domain:lower():find('^ssh') ~= nil
  if not is_remote then
    return ''
  end
  return ' ' .. remoteIcon .. '  REMOTE · ' .. domain .. ' '
end

M.setup = function(config)
  tabline.setup({
    options = {
      icons_enabled = true,
      -- theme = 'Catppuccin Mocha',
      theme = 'Dracula',
      tabs_enabled = true,
      theme_overrides = {},
      section_separators = '',
      component_separators = '',
      tab_separators = '',
    },
    sections = {
      -- tabline_a = { 'workspace' },
      tabline_a = {
        -- shiny remote marker: bright-red badge when on a remote mux domain,
        -- empty (so it disappears) when local. ResetAttributes restores the
        -- section styling before 'workspace' renders.
        { Background = { Color = remoteBadgeBg } },
        { Foreground = { Color = remoteBadgeFg } },
        { Attribute = { Intensity = 'Bold' } },
        remoteMarker,
        'ResetAttributes',
        'workspace',
      },
      tabline_b = { '' },
      tabline_c = { '' },
      tab_active = {
        'index',
        { 'zoomed', padding = 0 },
        { 'process', padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
        'index',
        { 'process', padding = { left = 0, right = 1 } },
      },
      tabline_x = {},
      tabline_y = { { 'ram', throttle = 5 }, { 'cpu', throttle = 5 } },
      tabline_z = { 'domain' },
    },
    extensions = {},
  })

  tabline.apply_to_config(config)
end

return M
