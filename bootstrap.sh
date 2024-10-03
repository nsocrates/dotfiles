#!/bin/bash

set -e

# Backups and copies files
bk_cp() {
    local src=$1
    local dest=$2

    if [ -f "$dest" ]; then
        cp "$dest" "$dest.bak"
        echo "Backup of $dest created."
    fi
    cp "$src" "$dest"
    echo "$src copied to $dest."
}

# Executes a command and check if it was successful
cmd() {
    if [ $status -ne 0 ]; then
        echo "Error executing: $*"
        exit 1
    fi
}

# Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
else
    echo "Xcode Command Line Tools are already installed."
fi

# Accept xcode license
echo "This script requires sudo privileges to accept the Xcode license."
sudo -v
sudo xcodebuild -license accept

# Install Homebrew
if ! brew -v &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "Homebrew installation failed."
        exit 1
    }
else
    echo "Homebrew is already installed."
fi

# Install packages from Brewfile
echo "Installing packages from Brewfile..."
brew bundle install --file Brewfile

# Dots
DOTFILES=("dots/.zprofile" "dots/.zshrc" "dots/.gitignore")
for file in "${DOTFILES[@]}"; do
    bk_cp "$file" "$HOME/$file"
done

# gitconfig
if ! git -v &>/dev/null; then
    echo "Installing git..."
    brew install git
else
    echo "Git is already installed."
fi

git config --global core.ignorecase false
git config --global core.autocrlf input
git config --global core.compression 0
git config --global core.excludesfile ~/.gitignore
git config --global fetch.prune true
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global http.postBuffer 500M
git config --global http.maxRequestBuffer 100M
git config --global pack.windowMemory 10m
git config --global pack.packSizeLimit 20m
git config --global color.ui auto
echo "Git settings applied."

# iTerm2 settings
if open -Ra "iTerm"; then
    open -a iTerm "iTerm2 State.itermexport"
    echo "iTerm2 settings imported."
else
    echo "iTerm2 is not installed."
fi

# VSCode
vscode_dir="$HOME/.vscode/extensions"
if [ -d "$vscode_dir" ]; then
    rsync -av --progress "vscode/." "$vscode_dir/"
    echo "VSCode extensions copied."
else
    echo "VSCode directory does not exist."
fi

# Sublime
subl_dir="$HOME/Library/Application Support/Sublime Text"
pkg_ctrl_url="https://packagecontrol.io/Package%20Control.sublime-package"

if [ -d "$subl_dir" ]; then
    # Install Sublime Package Control
    echo "Downloading Package Control..."
    curl -o "$subl_dir/Installed Packages/Package Control.sublime-package" "$pkg_ctrl_url" --create-dirs
    echo "Package Control installed successfully."

    # Copy Sublime Text settings
    rsync -av --progress "sublime/." "$subl_dir/Packages/User/"
    echo "Sublime Text settings copied."
else
    echo "Sublime directory does not exist."
fi

# MollyGuard
dl_url="https://dropbox.com/scl/fi/x2tlly6yi2aq5uucqn4zc/MollyGuard.zip?rlkey=t6rsovr0nif36yctg463wmyll&st=s16avyff&dl=1"
app_name="MollyGuard"
zip_path=".tmp/$app_name.zip"
echo "Downloading $app_name..."
curl -L -o "$zip_path" "$dl_url" --create-dirs
echo "Extracting $app_name..."
unzip -o "$zip_path" -d "/Applications"
echo "$app_name installed successfully."
rm -rf "$zip_path"

# macOS Global Settings
echo "Applying macOS global settings..."
cmd "defaults write NSGlobalDomain ApplePressAndHoldEnabled -int 0"
cmd "defaults write NSGlobalDomain InitialKeyRepeat -int 15"
cmd "defaults write NSGlobalDomain KeyRepeat -int 2"
cmd "defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -int 0"
cmd "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -int 1"
cmd "defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -int 0"
cmd "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -int 0"
cmd "defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -int 0"
cmd "defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -int 0"

# Keyboard and Mouse Settings
echo "Applying keyboard and mouse settings..."
cmd "defaults write NSGlobalDomain com.apple.keyboard.fnState -int 0"
cmd "defaults write NSGlobalDomain com.apple.mouse.doubleClickThreshold -float 0.2"
cmd "defaults write NSGlobalDomain com.apple.mouse.linear -int 1"
cmd "defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5"
cmd "defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 1"
cmd "defaults write NSGlobalDomain com.apple.springing.delay -float 0"
cmd "defaults write NSGlobalDomain com.apple.springing.enabled -int 0"
cmd "defaults write NSGlobalDomain com.apple.swipescrolldirection -int 1"
cmd "defaults write NSGlobalDomain com.apple.trackpad.forceClick -int 0"
cmd "defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3"
cmd "defaults write NSGlobalDomain com.apple.trackpad.scrolling -float 1"

# Accessibility Settings
echo "Applying accessibility settings..."
cmd "defaults write com.apple.Accessibility KeyRepeatDelay -int 0.5"
cmd "defaults write com.apple.Accessibility KeyRepeatEnabled -int 1"
cmd "defaults write com.apple.Accessibility KeyRepeatInterval -float 0.083333333"

# Mouse Settings
echo "Applying mouse settings..."
cmd "defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string TwoButton"
cmd "defaults write com.apple.AppleMultitouchMouse MouseOneFingerDoubleTapGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchMouse MouseTwoFingerDoubleTapGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchMouse MouseTwoFingerHorizSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchMouse MouseVerticalScroll -int 1"

# Trackpad Settings
echo "Applying trackpad settings..."
cmd "defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad DragLock -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad Dragging -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadHandResting -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll -int 1"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0"
cmd "defaults write com.apple.AppleMultitouchTrackpad USBMouseStopsTrackpad -int 0"

# Menu Bar Clock Settings
echo "Applying menu bar clock settings..."
cmd "defaults write com.apple.menuextra.clock FlashDateSeparators -int 0"
cmd "defaults write com.apple.menuextra.clock IsAnalog -int 0"
cmd "defaults write com.apple.menuextra.clock Show24Hour -int 1"
cmd "defaults write com.apple.menuextra.clock ShowAMPM -int 1"
cmd "defaults write com.apple.menuextra.clock ShowDate -int 0"
cmd "defaults write com.apple.menuextra.clock ShowDayOfWeek -int 1"

# Dock Settings
echo "Applying dock settings..."
cmd "defaults write com.apple.dock autohide -int 0"
cmd "defaults write com.apple.dock expose-animation-duration -float 0.12"
cmd "defaults write com.apple.dock expose-group-by-app -int 1"
cmd "defaults write com.apple.dock largesize -int 55"
cmd "defaults write com.apple.dock magnification -int 0"
cmd "defaults write com.apple.dock mineffect -string scale"
cmd "defaults write com.apple.dock minimize-to-application -int 0"
cmd "defaults write com.apple.dock mru-spaces -int 0"
cmd "defaults write com.apple.dock show-recents -int 0"
cmd "defaults write com.apple.dock showAppExposeGestureEnabled -int 0"
cmd "defaults write com.apple.dock showDesktopGestureEnabled -int 0"
cmd "defaults write com.apple.dock showhidden -int 1"
cmd "defaults write com.apple.dock showLaunchpadGestureEnabled -int 0"
cmd "defaults write com.apple.dock showMissionControlGestureEnabled -int 0"
cmd "defaults write com.apple.dock tilesize -int 43"
cmd "defaults write com.apple.dock trash-full -int 1"
cmd "defaults write com.apple.orientation -string bottom"

# Finder Settings
echo "Applying Finder settings..."
cmd "defaults write com.apple.desktopservices DSDontWriteNetworkStores -int 1"
cmd "defaults write com.apple.desktopservices DSDontWriteUSBStores -int 1"

cmd "rm -rf $HOME/.DS_Store"
cmd "defaults write com.apple.finder \"_FXSortFoldersFirst\" -int 1"
cmd "defaults write com.apple.finder \"_FXSortFoldersFirstOnDesktop\" -int 1"
cmd "defaults write com.apple.finder AppleShowAllFiles -int 1"
cmd "defaults write com.apple.finder FXPreferredGroupBy -string kind"
cmd "defaults write com.apple.finder FXPreferredViewStyle -string Nlsv"
cmd "defaults write com.apple.finder FXRecentFoldersMax -int 0"
cmd "defaults write com.apple.finder NewWindowTarget -string PfLo"
cmd "defaults write com.apple.finder NewWindowTargetPath -string file://${HOME}/"

# View Settings
plist_file="$HOME/Library/Preferences/com.apple.finder.plist"
if [ -f "$plist_file" ]; then
    echo "Applying view settings..."
    cmd "/usr/libexec/PlistBuddy -c \"Set :DesktopViewSettings:IconViewSettings:arrangeBy grid\" $plist_file"
    cmd "/usr/libexec/PlistBuddy -c \"Set :FK_StandardViewSettings:IconViewSettings:arrangeBy kind\" $plist_file"
    cmd "/usr/libexec/PlistBuddy -c \"Set :StandardViewSettings:IconViewSettings:arrangeBy kind\" $plist_file"
    cmd "/usr/libexec/PlistBuddy -c \"Set :StandardViewSettings:ListViewSettings:sortColumn kind\" $plist_file"
else
    echo "Plist file $plist_file does not exist."
fi

# Apply Changes
echo "Applying changes..."
cmd "killall cfprefsd Dock Finder"
echo "All settings applied successfully."
