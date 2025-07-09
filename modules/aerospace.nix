# AeroSpace tiling window manager configuration
{ config, ... }: {
  home.file.".aerospace.toml".text = ''
    # AeroSpace config - i3-like tiling for macOS
    # Docs: https://nikitabobko.github.io/AeroSpace/guide

    config-version = 2
    start-at-login = true

    # Mouse follows focus
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    # Normalizations
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Layout
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'
    accordion-padding = 30

    # Gaps (inner = between windows, outer = screen edges)
    [gaps]
    inner.horizontal = 0
    inner.vertical = 0
    outer.left = 0
    outer.bottom = 0
    outer.top = 0
    outer.right = 0

    # Main keybindings (alt = option key)
    [mode.main.binding]

    # Focus navigation (vim-style)
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move windows
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Resize
    alt-minus = 'resize smart -50'
    alt-equal = 'resize smart +50'

    # Layout toggles
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-f = 'fullscreen'
    alt-shift-space = 'layout floating tiling'

    # Workspaces (alt + number)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Workspace navigation
    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # Service mode (for less common operations)
    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']

    # Join with adjacent windows
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']

    # App-specific rules
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.finder'
    if.window-title-regex-substring = 'Copy|Move|Delete|Connecting'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.1password.1password'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.raycast.macos'
    run = 'layout floating'
  '';
}
