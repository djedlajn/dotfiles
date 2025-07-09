# macOS System Defaults
# Declarative macOS system preferences via nix-darwin
# Changes require logout/restart to take full effect
{ ... }: {

  # ═══════════════════════════════════════════════════════════════════
  # Security
  # ═══════════════════════════════════════════════════════════════════
  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # ═══════════════════════════════════════════════════════════════════
  # Keyboard
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.NSGlobalDomain = {
    # Key repeat speed (lower = faster)
    KeyRepeat = 2;              # Fast repeat (default: 6)
    InitialKeyRepeat = 15;      # Short delay before repeat (default: 25)

    # Disable press-and-hold for special characters (enables key repeat)
    ApplePressAndHoldEnabled = false;

    # Full keyboard access (Tab through all UI controls)
    AppleKeyboardUIMode = 3;

    # Disable auto-correct annoyances
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Enable subpixel font rendering on non-Apple LCDs
    AppleFontSmoothing = 1;

    # Expand save panel by default
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;

    # Expand print panel by default
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;

    # Save to disk (not iCloud) by default
    NSDocumentSaveNewDocumentsToCloud = false;

    # Disable "natural" scrolling (optional - comment out if you prefer natural)
    # "com.apple.swipescrolldirection" = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Dock
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.dock = {
    # Auto-hide dock
    autohide = true;
    autohide-delay = 0.0;         # No delay before showing
    autohide-time-modifier = 0.4; # Animation speed

    # Dock size and magnification
    tilesize = 38;
    magnification = false;
    largesize = 48;

    # Position
    orientation = "bottom";       # bottom, left, right

    # Minimize effect
    mineffect = "scale";          # genie, scale, suck

    # Don't show recent apps
    show-recents = false;

    # Don't rearrange spaces based on recent use
    mru-spaces = false;

    # Speed up Mission Control animations
    expose-animation-duration = 0.15;

    # Don't automatically rearrange Spaces
    # mru-spaces = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Finder
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.finder = {
    # Show all file extensions
    AppleShowAllExtensions = true;

    # Show hidden files
    AppleShowAllFiles = true;

    # Show path bar at bottom
    ShowPathbar = true;

    # Show status bar
    ShowStatusBar = true;

    # Default view style (icnv, Nlsv, clmv, Flwv)
    FXPreferredViewStyle = "clmv";  # Column view

    # Search current folder by default
    FXDefaultSearchScope = "SCcf";

    # Disable warning when changing file extension
    FXEnableExtensionChangeWarning = false;

    # Allow quitting Finder via Cmd+Q
    QuitMenuItem = true;

    # Show full POSIX path in title bar
    _FXShowPosixPathInTitle = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Trackpad
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.trackpad = {
    # Enable tap to click
    Clicking = true;

    # Enable two-finger right click
    TrackpadRightClick = true;

    # Disable three-finger drag to enable swipe gestures
    TrackpadThreeFingerDrag = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Menu Bar & Control Center
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowSeconds = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Screenshots
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.screencapture = {
    location = "~/Pictures/Screenshots";
    type = "png";
    disable-shadow = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Spaces & Mission Control
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.spaces = {
    # Displays have separate Spaces
    spans-displays = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Window Management
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.WindowManager = {
    # Click wallpaper to reveal desktop
    EnableStandardClickToShowDesktop = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Login Window
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.loginwindow = {
    # Show username/password fields instead of user list
    SHOWFULLNAME = false;

    # Disable guest account
    GuestEnabled = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Custom User Defaults (via defaults write)
  # ═══════════════════════════════════════════════════════════════════
  system.defaults.CustomUserPreferences = {
    # Three-finger gestures for Spaces & Mission Control
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 2;  # Swipe between Spaces
      TrackpadThreeFingerVertSwipeGesture = 2;   # Mission Control (up) / App Exposé (down)
    };

    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture" = {
      disableHotPlug = true;
    };

    # Disable disk image verification
    "com.apple.frameworks.diskimages" = {
      skip-verify = true;
      skip-verify-locked = true;
      skip-verify-remote = true;
    };

    # Avoid creating .DS_Store files on network or USB volumes
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Power Management (pmset via activation script)
  # ═══════════════════════════════════════════════════════════════════
  # system.activationScripts.postActivation.text = ''
  #   # Disable machine sleep while charging
  #   sudo pmset -c sleep 0
  #   # Set display sleep to 10 minutes on battery
  #   sudo pmset -b displaysleep 10
  # '';
}
