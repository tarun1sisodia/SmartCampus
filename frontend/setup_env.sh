#!/bin/bash

# SmartCampus Environment Setup Script for Linux/macOS

echo "=========================================="
echo "SmartCampus Development Environment Setup"
echo "=========================================="

OS="$(uname -s)"

echo "Detected OS: $OS"

if [ "$OS" = "Darwin" ]; then
    echo "macOS detected."
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi

    echo "Installing Flutter..."
    brew install --cask flutter

    echo "Installing CocoaPods (for iOS)..."
    brew install cocoapods

    echo "Installing VSCode..."
    brew install --cask visual-studio-code

    echo "Setup complete! Please restart your terminal."
    echo "Run 'flutter doctor' to verify your installation."

elif [ "$OS" = "Linux" ]; then
    echo "Linux detected."
    
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

    echo "Installing Flutter..."
    # Try installing via Snap first
    if command -v snap &> /dev/null; then
        echo "Snap found. Installing Flutter via snap..."
        sudo snap install flutter --classic
    else
        echo "Snap not found. Falling back to manual installation..."
        
        # Define installation directory
        INSTALL_DIR="$HOME/development"
        mkdir -p "$INSTALL_DIR"
        
        # Download Flutter (stable)
        echo "Downloading Flutter SDK..."
        curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz -o flutter.tar.xz
        
        # Extract
        echo "Extracting Flutter..."
        tar xf flutter.tar.xz -C "$INSTALL_DIR"
        rm flutter.tar.xz
        
        # Update PATH
        FLUTTER_BIN="$INSTALL_DIR/flutter/bin"
        echo "Configuring PATH..."
        
        # Helper function to add to PATH if not present
        add_to_path() {
            local RC_FILE="$1"
            if [ -f "$RC_FILE" ]; then
                if ! grep -q "$FLUTTER_BIN" "$RC_FILE"; then
                    echo "" >> "$RC_FILE"
                    echo "# Flutter SDK" >> "$RC_FILE"
                    echo "export PATH=\"\$PATH:$FLUTTER_BIN\"" >> "$RC_FILE"
                    echo "Added Flutter to $RC_FILE"
                else
                    echo "Flutter already in $RC_FILE"
                fi
            fi
        }

        add_to_path "$HOME/.bashrc"
        add_to_path "$HOME/.zshrc"
        
        # Export for current session
        export PATH="$PATH:$FLUTTER_BIN"
    fi

    echo "Setup complete! Run 'flutter doctor' to verify."

else
    echo "Unsupported OS via this script. Please check the documentation."
fi
