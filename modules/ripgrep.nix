{ ... }: {
  xdg.configFile."ripgrep/config".text = ''
    # Smart case sensitivity (case-insensitive unless uppercase used)
    --smart-case

    # Follow symlinks
    --follow

    # Search hidden files (but respect .gitignore)
    --hidden

    # Ignore common directories
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!.cache/*
    --glob=!target/*
    --glob=!_build/*
    --glob=!deps/*
    --glob=!.elixir_ls/*
    --glob=!.next/*
    --glob=!dist/*
    --glob=!build/*
    --glob=!.terraform/*
    --glob=!vendor/*

    # Max columns (prevents huge single-line files from flooding output)
    --max-columns=200
    --max-columns-preview

    # Better colors
    --colors=line:fg:yellow
    --colors=line:style:bold
    --colors=path:fg:green
    --colors=path:style:bold
    --colors=match:fg:black
    --colors=match:bg:yellow
    --colors=match:style:nobold
  '';
}
