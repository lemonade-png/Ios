# How to Build and Sideload EcoPlayer (Windows)

Since you are on Windows, you cannot compile the iOS app directly. However, we can use **GitHub Actions** to build the app in the cloud and **Sideloadly** to install it on your device.

## Prerequisites
1.  **GitHub Account**: [Sign up here](https://github.com/join).
2.  **Sideloadly**: Download and install [Sideloadly for Windows](https://sideloadly.io/).
3.  **iTunes**: Install the non-Microsoft Store version if possible (Sideloadly often needs it for drivers).

## Step 1: Push Code to GitHub
1.  Create a new **Public** repository on GitHub (e.g., `EcoPlayer`).
2.  Upload the files created in `Documents/Ios/EcoPlayer` to this repository.
    *   `EcoPlayerApp.swift`
    *   `ContentView.swift`
    *   `PlayerView.swift`
    *   `BatteryOptimizer.swift`

## Step 2: Add Build Workflow
In your GitHub repository, create a specific file structure to tell GitHub how to build the app.

1.  Create a folder named `.github`
2.  Inside it, create a folder named `workflows`
3.  Inside that, create a file named `build.yml`
4.  Paste the following content into `build.yml`:

```yaml
name: Build iOS App

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Create Xcode Project
        run: |
          # Create a temporary project structure
          mkdir -p EcoPlayer
          mv *.swift EcoPlayer/
          
          # Compile the swift files into an executable
          # Note: We are manually compiling to avoid needing an xcodeproj file.
          mkdir -p Payload/EcoPlayer.app
          
          swiftc -o Payload/EcoPlayer.app/EcoPlayer \
            -target arm64-apple-ios16.0 \
            -sdk $(xcrun --show-sdk-path --sdk iphoneos) \
            -F $(xcrun --show-sdk-path --sdk iphoneos)/System/Library/Frameworks \
            EcoPlayer/*.swift
            
          # Create Info.plist (Required)
          cat <<EOF > Payload/EcoPlayer.app/Info.plist
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>CFBundleExecutable</key>
              <string>EcoPlayer</string>
              <key>CFBundleIdentifier</key>
              <string>com.example.EcoPlayer</string>
              <key>CFBundleName</key>
              <string>EcoPlayer</string>
              <key>CFBundleVersion</key>
              <string>1.0</string>
              <key>CFBundleShortVersionString</key>
              <string>1.0</string>
              <key>UILaunchScreen</key>
              <dict/>
              <key>UISupportedInterfaceOrientations</key>
              <array>
                  <string>UIInterfaceOrientationPortrait</string>
                  <string>UIInterfaceOrientationLandscapeLeft</string>
                  <string>UIInterfaceOrientationLandscapeRight</string>
              </array>
          </dict>
          </plist>
          EOF
          
          # Zip it into an IPA
          zip -r EcoPlayer.ipa Payload

      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: EcoPlayer-IPA
          path: EcoPlayer.ipa
```

## Step 3: Run the Build
1.  Commit the file.
2.  Go to the **Actions** tab in your GitHub repository.
3.  Click on the "Build iOS App" workflow.
4.  If it hasn't run automatically, click **Run workflow**.
5.  Wait for it to complete.
6.  Download the `EcoPlayer-IPA` artifact.

## Step 4: Sideload with Sideloadly
1.  Plug your iPhone into your Windows PC.
2.  Open **Sideloadly**.
3.  Drag and drop the `EcoPlayer.ipa` (you might need to unzip the artifact zip first to get the IPA) into Sideloadly.
4.  Enter your **Apple ID**.
5.  Click **Start**.
6.  Trust the app in iPhone Settings > General > VPN & Device Management.
