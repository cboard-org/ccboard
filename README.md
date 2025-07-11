# Cboard Cordova - AAC communication board with text-to-speech for mobile devices

[![cboard-org](https://circleci.com/gh/cboard-org/ccboard.svg?style=shield)](https://app.circleci.com/pipelines/github/cboard-org/ccboard)

This is a Cordova application that wraps the original [Cboard React application](https://github.com/cboard-org/cboard) to bring native mobile and desktop support. The Cboard react app is maintained to support Cordova detection, setup and bindings.

Text-to-speach (TTS) support is provided via [`phonegap-plugin-speech-synthesis`](https://github.com/macdonst/SpeechSynthesisPlugin). This plugin bridges the native operating system TTS functionality to browser app, in a way that mimics [W3C Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API): `SpeechSynthesis`. It uses the `android.speech.tts.TextToSpeech` interface on Android.

## Platforms supported:

1. Android
1. Electron - Windows

## Before setup

You will need to modify the next files:

- In `/cboard/package.json` change `"homepage": "https://app.cboard.io"` to `"homepage": "."`
- In `/cboard/public/index.html` add `<script src="cordova.js"></script>` below `<head>` tag

## One-time setup

1. `git submodule update` - Get Cboard app
1. `npm i`
1. `mkdir -p www` - Make root cordova app folder
1. `cordova platform add android` or `cordova platform add electron@2.0.0` - Add Cordova platforms. _`www` folder must be present._
1. `cd cboard`
1. `npm i`

## Building Cboard (React project)

You need to build the React.js app, and after that, Copy it to cordova project:

1. `cd cboard`
1. Release `yarn build` / Debug `yarn run build-cordova-debug`
1. `cp -r ./build/* ../www`
1. `cd ..`

## Building and running Ccboard (Cordova project)

Android:

- `cordova run android --emulator` run on emulator
- `cordova run android --device` run on device

Electron:

- `cordova build electron --release` For release
- `cordova build electron --debug ` For enable the dev tools

iOS: See below section #iOS Platform

## Android Platform

### Generate Release APK

1. Build `cordova build android --release`
1. Copy `cp platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk ccboard.apk`
1. Sign

   1. Generate self-signed keys `keytool -genkey -v -keystore ccboard.keystore -alias ccboard -keyalg RSA -keysize 2048 -validity 100000`
   1. Sign `jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ccboard.keystore ccboard.apk ccboard`

### Debugging output

For emulator console.log output, you can either run in the debugging under eg. `Android Studio`, or in Chrome, navigate to `chrome://inspect`, and select the remote target that shows up once the emulator starts.

## Electron Platform

You can find the documentation [here](https://cordova.apache.org/docs/en/10.x/guide/platforms/electron/index.html)

In the root folder, you will find the file `settings.json` where are the configurations of the [BrowserWindow](https://www.electronjs.org/docs/api/browser-window#new-browserwindowoptions). This contains all the graphics options to modify the electron window.

## IOS Platform

A) Follow the Cordova documentation [here](https://cordova.apache.org/docs/en/11.x/guide/platforms/ios/index.html)

B) If necessary, install Cocoapods using `sudo gem install cocoapods`.

### Optional: Running the app in iOS simulator

If you need to test the app in the iOS simulator, some plugins may cause conflicts. To resolve this:

1. Remove the conflicting plugin temporarily:

   ```bash
   cordova plugin rm cordova-plugin-iosrtc
   ```

2. Run your simulator tests

3. **Important:** After testing, remember to restore the plugin for production use:
   ```bash
   cordova plugin add cordova-plugin-iosrtc
   ```

> **Note:** This modification should only be done for simulator testing purposes. Make sure to restore the plugin before committing any changes or building for production.

C) Follow these setup steps in order:

1.  Complete all steps from the "Before setup" section above
2.  Complete all steps from the "One-time setup" section above
3.  In `config.xml` change the id of the main widget to `com.cboardorg.cboard`
4.  Add `GoogleService-info.plist` and `google-services.json` file in the project's root folder or decrypt them using the openssl commands stored in the config.yml file:

```bash
openssl aes-256-cbc -d -md sha256 \
            -pbkdf2 \
            -in  GoogleService-info.plist.cipher \
            -out GoogleService-info.plist \
            -k $KEY
```

```bash
openssl aes-256-cbc -d -md sha256 \
            -pbkdf2 \
            -in  google-services.json.cypher \
            -out google-services.json.plist \
            -k $KEY
```
5.  Run `cordova platform add ios` to set up the initial iOS project structure

D) On Xcode, open `AAC Cboard.xcworkspace` that is located under `ccboard/platforms/ios` (Make sure to use the `.xcworkspace` to work with the cocoapods project )

1.  Select a group for the iOS sign-in certificate.

2.  Set a swift-language-version >= 4.0. This should be settled on AAC Cboard Target under Swift compiler - language

3.  Update to recommended settings and do not allow changes on 'always embed Swift standards libraries' to not break the voice record feature (this step is necessary only if iosrtc plugin is present)
    <img width="998" alt="image" src="https://user-images.githubusercontent.com/21298844/234080729-a93b8d34-87dd-40f1-a168-b6f3abacd039.png">

4.  To enable Facebook and Google sign-in, the 'fbXXXXXXXXXXXXX' and the Google Reversed Client Id URL Scheme should be registered. To do it:
    Under AAC Cboard Target > info > URL TYPES >
    Add a new one with our APP bundle identifier and set the 'fbXXXXXXXXXXXXX' for the URL SCHEME field.
    Add a new one with our REVERSED_CLIENT_ID
    <img width="888" alt="configure_FB_login" src="https://github.com/cboard-org/ccboard/assets/21298844/d306ba8a-d903-4ef2-b6d5-80f221338572">

> **Note:** Before building the app, you must configure the Facebook credentials. Locate the `cordova-util.js` file in the cboard app source and replace the following values with your environment-specific (test/production) credentials:
>
> - `FACEBOOK_APP_ID`
> - `FACEBOOK_CLIENT_TOKEN`
> - `FACEBOOK_APP_NAME`

5. Before starting the build. Open the 'Build Phases' section on Xcode and move Crashlytics to the last position (a required step to make the build). If you miss this step, an error (Cycle inside AAC Cboard; building could produce unreliable results.) appears and causes the build to fail (If you remove the iosRTC plugin, this step is not required).

6. To allow users to open files created by the Export feature:
   Edit the plist file `AAC Cboard-Info.plist` under `platforms/ios/AAC Cboard/`
   Adding these keys and values

```
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    <key>UIFileSharingEnabled</key>
    <true/>
```

7. To allow the app to use the voice in high volume on iPhones:
   Edit the plist file `AAC Cboard-Info.plist` under `platforms/ios/AAC Cboard/`

```
    <key>ManualInitAudioDevice</key>
    <string>TRUE</string>
```

8. Start the active scheme with the 'play' button in the top left corner

## iOS Troubleshooting

If you encounter build issues or unexpected behavior with the iOS platform, try the following steps in order:

1. Clean the build folder in Xcode

   - In Xcode, go to Product > Clean Build Folder
   - Or use keyboard shortcut: Cmd + Shift + K
   - Try building again

2. Remove the iOS platform

   - ```bash
     cordova platform remove ios
     ```

   - ```bash
     rm -rf plugins/
     ```

   - ```bash
     cordova platform add ios
     ```

   Try build again

> **Note:** After performing these steps, you'll need to take steps again from step D-5 of ## IOS Platform

### Create app size report

To know the size of the app before submitting it to the App Store Connect.
Follow these steps: https://developer.apple.com/documentation/xcode/reducing-your-app-s-size#Create-the-app-size-report
