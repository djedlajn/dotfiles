# Bottom (btm) system monitor configuration
# Docs: https://clementtsang.github.io/bottom/
{ ... }: {
  xdg.configFile."bottom/bottom.toml".text = ''
    # Catppuccin Mocha theme for bottom

    [styles]
    # Catppuccin Mocha colors
    theme = "custom"

    [styles.cpu]
    all_entry_color = "#cba6f7"      # mauve
    avg_entry_color = "#f38ba8"      # red
    cpu_core_colors = [
      "#f38ba8",  # red
      "#fab387",  # peach
      "#f9e2af",  # yellow
      "#a6e3a1",  # green
      "#94e2d5",  # teal
      "#89dceb",  # sky
      "#89b4fa",  # blue
      "#cba6f7",  # mauve
    ]

    [styles.memory]
    ram_color = "#a6e3a1"            # green
    cache_color = "#f9e2af"          # yellow
    swap_color = "#fab387"           # peach
    arc_color = "#89dceb"            # sky
    gpu_colors = ["#cba6f7", "#f5c2e7", "#89b4fa"]

    [styles.network]
    rx_color = "#a6e3a1"             # green
    tx_color = "#f38ba8"             # red
    rx_total_color = "#94e2d5"       # teal
    tx_total_color = "#fab387"       # peach

    [styles.battery]
    high_battery_color = "#a6e3a1"   # green
    medium_battery_color = "#f9e2af" # yellow
    low_battery_color = "#f38ba8"    # red

    [styles.tables]
    headers = { color = "#cba6f7" }  # mauve

    [styles.graphs]
    graph_color = "#6c7086"          # overlay0
    legend_text = { color = "#cdd6f4" } # text

    [styles.widgets]
    border_color = "#6c7086"         # overlay0
    selected_border_color = "#cba6f7" # mauve
    widget_title = { color = "#cdd6f4" } # text
    text = { color = "#cdd6f4" }     # text
    selected_text = { color = "#1e1e2e", bg_color = "#cba6f7" } # base, mauve
    disabled_text = { color = "#6c7086" } # overlay0

    # General settings
    [flags]
    dot_marker = false
    rate = "1s"
    default_widget_type = "proc"
    hide_avg_cpu = false
    hide_table_gap = true
    left_legend = false
    show_table_scroll_position = true
    tree = true
    battery = true
    enable_gpu = true
    enable_cache_memory = true
  '';
}
