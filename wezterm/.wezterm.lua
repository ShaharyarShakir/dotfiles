local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- =========================================================
-- Helpers
-- =========================================================

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- ssh options that consume a value (-p 22, -i key, -o Foo=bar, ...)
local SSH_OPTS_WITH_ARG = {}
for c in ('bBcDEeFIiJLlmOopQRSWw'):gmatch('.') do
  SSH_OPTS_WITH_ARG[c] = true
end

-- Split an ssh argv into (options, destination). Returns nil if the
-- command has a remote command (e.g. `ssh hub htop`) or no destination.
local function parse_ssh(argv)
  local opts = {}
  local i = 2
  while i <= #argv do
    local a = argv[i]
    if a:sub(1, 1) ~= '-' then
      if i < #argv then
        return nil
      end
      return opts, a
    end
    table.insert(opts, a)
    for k = 2, #a do
      if SSH_OPTS_WITH_ARG[a:sub(k, k)] then
        if k == #a then -- value is the next argument
          i = i + 1
          if argv[i] then
            table.insert(opts, argv[i])
          end
        end
        break
      end
    end
    i = i + 1
  end
  return nil
end

-- If this local pane is currently running an interactive `ssh <host>`,
-- return { opts = {...}, dest = 'host' }.
local function ssh_target(pane)
  local info = pane:get_foreground_process_info()
  if not info or not info.argv or #info.argv == 0 then
    return nil
  end
  if info.argv[1]:match('([^/]+)$') ~= 'ssh' then
    return nil
  end
  local opts, dest = parse_ssh(info.argv)
  if not dest then
    return nil
  end
  return { opts = opts, dest = dest }
end

-- Directory the *remote* shell reported via OSC 7. Returns nil if the
-- remote shell isn't reporting it (we ignore the local fallback path).
local function remote_cwd(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return nil
  end
  local host, path
  if type(cwd) == 'string' then
    host, path = cwd:match('^file://([^/]*)(/.*)$')
  else
    host, path = cwd.host, cwd.file_path
  end
  if not path or path == '' then
    return nil
  end
  if not host or host == '' or host:lower() == wezterm.hostname():lower() then
    return nil
  end
  return path
end

-- New tab / split that FOLLOWS you into the active remote domain (VM/SSH),
-- and still works when the pane is already inside a VM rather than a local
-- `ssh` process.
local function current_remote_domain(pane)
  local domain = pane:get_domain_name()
  if domain and domain ~= '' and domain ~= 'local' and domain ~= 'DefaultDomain' then
    return domain
  end
  return nil
end

local function smart_spawn(window, pane, kind) -- kind: 'tab' | 'right' | 'down'
  local remote_domain = current_remote_domain(pane)
  local target = ssh_target(pane)
  local action

  if remote_domain then
    if kind == 'tab' then
      action = act.SpawnTab { DomainName = remote_domain }
    elseif kind == 'right' then
      action = act.SplitHorizontal { domain = remote_domain }
    else
      action = act.SplitVertical { domain = remote_domain }
    end
  elseif target then
    local args = { 'ssh', '-t' }
    for _, o in ipairs(target.opts) do
      table.insert(args, o)
    end
    table.insert(args, target.dest)
    local cwd = remote_cwd(pane)
    if cwd then
      table.insert(args, 'cd ' .. shell_quote(cwd) .. '; exec "$SHELL" -l')
    end

    if kind == 'tab' then
      action = act.SpawnCommandInNewTab { args = args }
    elseif kind == 'right' then
      action = act.SplitPane { direction = 'Right', command = { args = args } }
    else
      action = act.SplitPane { direction = 'Down', command = { args = args } }
    end
  else
    if kind == 'tab' then
      action = act.SpawnTab 'CurrentPaneDomain'
    elseif kind == 'right' then
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    else
      action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    end
  end

  window:perform_action(action, pane)
end

local function spawn(kind)
  return wezterm.action_callback(function(window, pane)
    smart_spawn(window, pane, kind)
  end)
end

-- One key to hop between the local tab and the most relevant remote VM/domain.
-- This keeps the existing `hub` preference, but no longer assumes only `hub` exists.
local function toggle_remote_local(window, pane)
  local current_domain = pane:get_domain_name()
  local on_remote = current_domain and current_domain ~= '' and current_domain ~= 'local' and current_domain ~= 'DefaultDomain'

  if on_remote then
    for _, tab in ipairs(window:mux_window():tabs()) do
      if tab:active_pane():get_domain_name() == 'local' then
        tab:activate()
        return
      end
    end
    window:perform_action(act.SpawnTab 'DefaultDomain', pane)
    return
  end

  local preferred_domain = nil
  for _, tab in ipairs(window:mux_window():tabs()) do
    local domain_name = tab:active_pane():get_domain_name()
    if domain_name and domain_name ~= '' and domain_name ~= 'local' and domain_name ~= 'DefaultDomain' then
      if domain_name == 'hub' then
        preferred_domain = 'hub'
        break
      end
      preferred_domain = domain_name
    end
  end

  if preferred_domain then
    for _, tab in ipairs(window:mux_window():tabs()) do
      if tab:active_pane():get_domain_name() == preferred_domain then
        tab:activate()
        return
      end
    end
  end

  if preferred_domain == 'hub' then
    window:perform_action(act.SpawnTab { DomainName = 'hub' }, pane)
  else
    window:perform_action(act.SpawnTab 'DefaultDomain', pane)
  end
end

-- tmux "popup" stand-in: a big split at the bottom that closes when the
-- command exits. Runs in the current pane's domain (so on hub when on hub).
local function popup(args, percent)
  return act.SplitPane {
    direction = 'Down',
    size = { Percent = percent or 80 },
    command = { args = args },
  }
end

-- vim-tmux-navigator: Ctrl+h/j/k/l moves between panes, but is passed
-- through to nvim when nvim is the foreground program. Ctrl+L is reserved
-- for the shell's clear-screen behavior and should not be intercepted.
local function is_vim(pane)
  if pane:get_user_vars().IS_NVIM == 'true' then
    return true
  end
  local name = pane:get_foreground_process_name() or ''
  return name:find('n?vim') ~= nil
end

local function navigate(key, direction)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if key == 'l' then
        window:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
        return
      end

      if is_vim(pane) then
        window:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
      else
        window:perform_action(act.ActivatePaneDirection(direction), pane)
      end
    end),
  }
end

-- tmux `bind -r` (repeatable resize): after the first press, keep tapping
-- h/j/k/l without the leader.
local function resize(direction)
  return act.Multiple {
    act.AdjustPaneSize { direction, 5 },
    act.ActivateKeyTable {
      name = 'resize_panes',
      one_shot = false,
      timeout_milliseconds = 1000,
      replace_current = true,
    },
  }
end

-- =========================================================
-- Tab bar = tmux status bar
-- (top, ` #I #W `, active = #474745 bg + white bold text)
-- =========================================================

wezterm.on('format-tab-title', function(tab)
  local p = tab.active_pane
  local name = (p.foreground_process_name or ''):match('([^/]+)$')
  if not name or name == '' then
    name = p.title
  end
  if tab.tab_title and #tab.tab_title > 0 then
    name = tab.tab_title
  end

  local text = ' ' .. (tab.tab_index + 1) .. ' ' .. name .. ' '

  if tab.is_active then
    return {
      { Background = { Color = '#474745' } },
      { Foreground = { Color = '#ffffff' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = text },
    }
  end
  return {
    { Background = { Color = '#1e1e2e' } },
    { Foreground = { Color = '#a6adc8' } },
    { Text = text },
  }
end)

-- =========================================================
-- Rendering
-- =========================================================

config.front_end = 'OpenGL'
config.max_fps = 120
config.animation_fps = 60
config.cursor_blink_rate = 0
config.enable_kitty_graphics = true -- yazi image previews

-- =========================================================
-- Appearance
-- =========================================================

config.font = wezterm.font('JetBrains Mono', { weight = 'Regular' })
config.font_size = 18.0

config.window_background_opacity = 0.88
config.text_background_opacity = 0.92
config.color_scheme = 'Catppuccin Mocha'

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false -- tmux's bar is always visible
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false -- status-position top
config.tab_max_width = 24
config.show_new_tab_button_in_tab_bar = false
config.colors = {
  tab_bar = { background = '#1e1e2e' },
}

config.initial_rows = 36
config.initial_cols = 120

config.window_padding = { left = 14, right = 14, top = 4, bottom = 4 }

-- =========================================================
-- SSH domains
-- =========================================================
-- Plain shell `ssh host` panes are NOT Wezterm domains. If we want
-- new tabs/splits to stay on the remote machine, Wezterm must know
-- about the host as an SSH domain (or a unix_domain like `hub`).
-- =========================================================

config.ssh_domains = {
  { name = 'fedora-dev', remote_address = 'fedora-dev' },
  { name = 'rust-vm', remote_address = 'rust-vm' },
  { name = 'nsl-debian', remote_address = 'nsl-debian' },
}

config.unix_domains = {
  {
    name = 'hub',
    proxy_command = { 'ssh', '-T', 'hub', 'wezterm', 'cli', 'proxy' },
  },
}

-- =========================================================
-- Keybindings
-- LEADER = tmux prefix (Ctrl+b)
-- =========================================================

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- ---------- your original shortcuts (now ssh-aware) ----------
  { key = 't', mods = 'CTRL|SHIFT', action = spawn('tab') },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = spawn('down') },
  { key = 'Enter', mods = 'CTRL|ALT', action = spawn('right') },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action_callback(toggle_remote_local) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnTab 'DefaultDomain' },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- ---------- tmux: prefix + ... ----------
  -- send a literal Ctrl+b (prefix prefix)
  { key = 'b', mods = 'LEADER|CTRL', action = act.SendKey { key = 'b', mods = 'CTRL' } },

  -- reload config
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.ReloadConfiguration, pane)
      window:toast_notification('wezterm', 'Config reloaded!', nil, 1500)
    end),
  },

  -- splits:  |  and  -   (keep cwd, follow ssh)
  { key = '|', mods = 'LEADER|SHIFT', action = spawn('right') },
  { key = '-', mods = 'LEADER', action = spawn('down') },

  -- windows (= tabs)
  { key = 'c', mods = 'LEADER', action = spawn('tab') },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'w', mods = 'LEADER', action = act.ShowTabNavigator },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Alt+Shift+H / Alt+Shift+L: previous / next window
  { key = 'H', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'L', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(1) },

  -- zoom, copy mode, pane arrows
  { key = 'm', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },

  -- resize (repeatable)
  { key = 'h', mods = 'LEADER', action = resize 'Left' },
  { key = 'j', mods = 'LEADER', action = resize 'Down' },
  { key = 'k', mods = 'LEADER', action = resize 'Up' },
  { key = 'l', mods = 'LEADER', action = resize 'Right' },

  -- vim-tmux-navigator
  navigate('h', 'Left'),
  navigate('j', 'Down'),
  navigate('k', 'Up'),
  navigate('l', 'Right'),

  -- sessions (= workspaces): sessionx `o`, C-j switcher, C-n new
  { key = 'o', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'j', mods = 'LEADER|CTRL', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = 'n',
    mods = 'LEADER|CTRL',
    action = act.PromptInputLine {
      description = 'Session name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },

  -- ---------- popups (prefix + Ctrl+key) ----------
  { key = 'y', mods = 'LEADER|CTRL', action = popup({ 'lazygit' }, 80) },
  { key = 'u', mods = 'LEADER|CTRL', action = popup({ 'yazi' }, 90) },
  { key = 'f', mods = 'LEADER|CTRL', action = popup({ 'rmpc' }, 80) },
  { key = 'p', mods = 'LEADER|CTRL', action = popup({ 'ipython' }, 60) },
  { key = 't', mods = 'LEADER|CTRL', action = popup({ 'zsh' }, 75) },
  { key = 'z', mods = 'LEADER|CTRL', action = popup({ 'bash', '-lc', 'nvim ~/.bashrc' }, 80) },
  {
    key = 'g',
    mods = 'LEADER|CTRL',
    action = popup({ 'bash', '-i', wezterm.home_dir .. '/.tmux/scripts/chat-popup.sh' }, 60),
  },
  {
    key = 'h',
    mods = 'LEADER|CTRL',
    action = popup({
      'bash', '-lc',
      [[compgen -c | grep -E '^[a-zA-Z0-9_.-]+$' | sort -u | fzf --preview 'man {} 2>/dev/null | col -bx | head -100' --preview-window=right:70% | xargs -r man]],
    }, 80),
  },

  -- dotfiles menu (prefix d)
  {
    key = 'd',
    mods = 'LEADER',
    action = act.InputSelector {
      title = 'Dotfiles',
      choices = {
        { label = '.bashrc', id = '~/.bashrc' },
        { label = '.wezterm.lua', id = '~/.wezterm.lua' },
      },
      action = wezterm.action_callback(function(window, pane, id)
        if id then
          window:perform_action(popup({ 'bash', '-lc', 'nvim ' .. id }, 80), pane)
        end
      end),
    },
  },
}

-- prefix + 1..9 -> window N
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end

config.key_tables = {
  resize_panes = {
    { key = 'h', action = resize 'Left' },
    { key = 'j', action = resize 'Down' },
    { key = 'k', action = resize 'Up' },
    { key = 'l', action = resize 'Right' },
    { key = 'Escape', action = act.PopKeyTable },
    { key = 'Enter', action = act.PopKeyTable },
  },
}

return config
