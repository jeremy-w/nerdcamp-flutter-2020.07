# Day 1: Quickstart & Docs Familiarization + Build Pipeline
## The Plan
- timebox: 2 hours:
  - run through codelabs for first app part 1 & part 2 and flutter for web
  - https://flutter.dev/docs/codelabs
- timebox: 2 hours:
  - browse the other docs and get a sense for what resources are available
  - (also hit up o'reilly and see what's in there, though i'd prefer first-party docs)
- how easy is code sharing across platforms?
  - e.g. create a flutter view, can i use it across iOS & Web & Android, or do i need to code in flutter for a particular platform?
- build pipeline:
  - what does CI look like?
  - what build platforms are supported? (can i do dev on windows? linux?)
  - cross-compilation support? or do you need multiple runners?
  - any good linters? autoformatters?
  - what gets run to create a flutter app for various platforms?
  - what are the inputs and build artifacts?
  - can you ship a binary library, or only open source?

## Codelab 1
https://codelabs.developers.google.com/codelabs/first-flutter-app-pt1/#0

### Intro
#### Platform Support: Mainly native Mobile
> looks natural on iOS, Android, and the web

OK, that sounds in line with my interests.

Note that **"Desktop"** is not mentioned here. That's because,
as of 2020-07, Flutter Desktop support for macOS is in alpha, and Win and Linux
are not even alpha yet (https://flutter.dev/desktop).

And **Web** is also a tiny bit of a stretch:

> Flutter has early support for building web applications using the beta
> channel of Flutter. (https://flutter.dev/docs/get-started/install/macos)

#### Natural, or Material, Look?
But I note that the demo GIF shows an iPhone X with Material theming,
not platform-native.
I guess eschewing Apple-style UI for Google-style would be one way to avoid
getting out of step with platform UI changes.

#### Dev-Only Build Pipeline for Hot Reload?
> Using hot reload for a quicker development cycle

interesting - that intros a dev-only build pipeline. unless you can trigger a
hot-reload over the wire?
(consider how folks have shipped updated React Native code bundles independent
of App Store releases.)

### Env Setup
#### Editor Selection
> The codelab assumes that you're using Android Studio, but you can use your
> preferred editor.

i wonder what AS adds to the experience.
i'm tempted to use VS Code, simply because it's a bit lighter.

And indeed, the bit more loved-looking main Flutter.dev setup page explains
[setting up VS Code](https://flutter.dev/docs/get-started/editor?tab=vscode),
Android Studio, and (surprisingly) Emacs (using lsp-dart).

#### Web Platform: Just Chrome, or also any fork thereof?
> A browser (Chrome is required for debugging)

i wonder if Vivaldi would work as well

#### Installing the SDK
##### Not Homebrew? Nope
Interesting: It's not in Homebrew. Lots of closed PRs though.

Apparently it fell into a gap between Cask (doesn't want CLI tools)
and Core (wants to be able to build from source unless the asset is
cross-platform).
https://github.com/Homebrew/homebrew-core/pull/46727#issuecomment-554914026

And getting a working install when it's installed by a privileged tool is
also an issue due to Flutter mixing cached files alongside installed files
and ultimately expecting to have a git repo for distribution (similar to
Homebrew, that).
https://github.com/flutter/flutter/issues/14050#issuecomment-646122824

##### Download & Update Path
- Download
- Unzip
- `set -a fish_user_paths $HOME/Downloads/flutter/bin/`

Done!

##### Install Plugins
Well, OK, not quite, per `flutter doctor`:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.17.5, on Mac OS X 10.15.5 19F101, locale en-US)
[!] Android toolchain - develop for Android devices (Android SDK version 28.0.3)
    ! Some Android licenses not accepted.  To resolve this, run: flutter doctor --android-licenses
[!] Xcode - develop for iOS and macOS (Xcode 11.5)
    ✗ CocoaPods installed but not working.
        You appear to have CocoaPods installed but it is not working.
        This can happen if the version of Ruby that CocoaPods was installed with is different from the one being used to
        invoke it.
        This can usually be fixed by re-installing CocoaPods. For more info, see
        https://github.com/flutter/flutter/issues/14293.
      To re-install CocoaPods, run:
        sudo gem install cocoapods
[!] Android Studio (version 3.6)
    ✗ Flutter plugin not installed; this adds Flutter specific functionality.
    ✗ Dart plugin not installed; this adds Dart specific functionality.
[!] VS Code (version 1.46.1)
    ✗ Flutter extension not installed; install from
      https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
[✓] Connected device (1 available)

! Doctor found issues in 4 categories.
```

Interesting that it uses CocoaPods.
The right move for easy, just-works stitching-together of dependencies for now.

It was pretty easy to get a clean bill of health though.
Interestingly, Android Studio has gained a "Create a new Flutter project"
action right on the main app launch landing screen.

```
> flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.17.5, on Mac OS X 10.15.5 19F101, locale en-US)
[✓] Android toolchain - develop for Android devices (Android SDK version 28.0.3)
[✓] Xcode - develop for iOS and macOS (Xcode 11.5)
[✓] Android Studio (version 4.0)
[✓] VS Code (version 1.46.1)

[✓] Connected device (1 available)

• No issues found!
```

##### Available Plugins
AS & Code both have many more plugins around Flutter.
Often there's overlap between them.

It looks like project-scaffold generators are common, as are helpers for
filling out dependencies and checking for updates.

More interesting plugins:

- Angular-inspired XML layout: https://marketplace.visualstudio.com/items?itemName=WaseemDev.flutter-xml-layout
- Localizely's i18n helper, Flutter Intl: https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl
- BLoC pattern support: https://marketplace.visualstudio.com/items?itemName=yt1997kt.flutter-bloc
  - https://github.com/felangel/bloc

Also seeing MVVM and "XModular" and "Clean" architecture plugins.

### Running the App
Skipping editing it for now per step 3, and just running the template.

Wow it is super slow to launch. But it worked on both Sim & device.

Launching from VS Code stumped me for a bit.
I don't much use its run/debug support.
Once I enabled the Run sidebar, it was easy to work out.

The docs though were no good from Flutter - the UI they described didn't seem
to exist:

> Press the Settings button—a cog icon gear on the top right (now marked with
> a red or orange indicator) next to the DEBUG text box that reads No
> Configuration. Select flutter. And choose the debug configuration: To create
> your emulator if it is closed or to run the emulator or device that is now
> connected.
> (https://flutter.dev/docs/get-started/test-drive?tab=vscode#run-the-app-1)

This does sort of match the UI in the Run/Debug sidebar. But they missed the
whole "open the sidebar" step. Anyway, the needed `launch.json` config is just:

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "request": "launch",
            "type": "dart"
        }
    ]
}
```

There is no progress indicator in the UI, unlike in the Terminal.
Just keep waiting.

But once launched, **hot reload** is almost instantaneous. It's awesome.
Save file => see change.

#### GOTCHA: ROTATION
Yeesh but rotation looks hideous. The existing content stretches to fill during
the rotation, so text is very obviously distorted. After the animation
finishes, it rerenders and looks fine, but that is _rough._ This affects both
on device and in simulator.

See video:
[Flutter Rotation - View Distortion (Stretch to Fill) - 2020-07-06.MP4][]

This is apparently a known issue since April 2018.
No fix has been forthcoming:

- The size change hasn't propagated, so there's no way to render at the target window size and then animate to that.
- Flutter renders async, so can't just re-render itself during the rotation at the intermediate sizes.
- Rotation seems to differ between Sim & device.

The [last significant attempt](https://github.com/flutter/engine/pull/14101#issuecomment-566734062)
was Dec 2019.
It foundered on these issues.

I'm hesitant to see what this looks like in a **Desktop** mode,
where window resizing can be interactive and frequent!

### Creating the Start Flutter app
This creates a substantially simpler app with just a text field and no actions.

And…wow. It hot-reloaded an entire replacement of `main()` without a problem.

I mean, I guess it kept the `MyApp` name. But that's still pretty cool.

#### Detour: Cupertino Style
I want to see if I can change this into a Cupertino app, and what that might look like.

It wasn't that bad. I did need to see an example (I looked at the video at the top of the Cupertino API reference).

The main thing is that everything Cupertino has a Cupertino prefix, even stuff that only exists in Cupertino mode.

I ran into problems with **dark mode**, though: my text stayed dark on dark.
The background color did pick up dark mode, but the text didn't seem to get the hint, so it looked like a black screen.

Debugging works well.
The view debugger doesn't have a fun 3d flyout view, but it does let you view the tree and poke around.
I can see it being a bit hard to map between views on the screen vs those in the tree in a busier tree, though.

Layout Explorer only works for flex containers, so a UI that's just a centered text doesn't get visualized beyond a tree.

If you completely change stuff, you can get a scary red screen griping about "Unimplemented handling of missing static target".
Just reload the app, and all will be well.

If you make a widget not const any more, you might have to un-constify all the way up the tree manually.
Ran into that with messing with `style` on the Text in a Center.
The dart error is not very helpful there: "Invalid constant value."
The error you'd _want_ to see would actually be it flagging the `const` keywords and suggesting to drop them on your behalf since the contents are not `const`.

##### Dark Mode?
Here's what I saw on an app reload a bit later when I broke into the debugger:

```
> CupertinoTheme.of(context)
CupertinoThemeData (CupertinoThemeData#a8ea5(primaryColor: systemBlue, primaryContrastingColor: systemBackground, barBackgroundColor: CupertinoDynamicColor(color = Color(0xf0f9f9f9), *darkColor = Color(0xf01d1d1d)*, resolved by: RandomWords), scaffoldBackgroundColor: systemBackground, textStyle: TextStyle(inherit: false, color: label(color = Color(0xff000000), *darkColor = Color(0xffffffff)*, resolved by: RandomWords), family: .SF Pro Text, size: 17.0, letterSpacing: -0.4, decoration: TextDecoration.none), actionTextStyle: TextStyle(inherit: false, color: systemBlue(color = Color(0xff007aff), *darkColor = Color(0xff0a84ff)*, highContrastColor = Color(0xff0040dd), darkHighContrastColor = Color(0xff409cff), resolved by: RandomWords), family: .SF Pro Text, size: 17.0, letterSpacing: -0.4, decoration: TextDecoration.none), tabLabelTextStyle: TextStyle(inherit: false, color: inactiveGray(color = Color(0xff999999), *darkColor = Color(0xff757575)*, resolved by: RandomWords), family: .SF Pro Text, size: 10.0, letterSpacing: -0.2), navTitleTextStyle: TextStyle(inherit: false, color: label(color = Color(0xff000000), *darkColor = Color(0xffffffff)*, resolved by: RandomWords), family: .SF Pro Text, size: 17.0, weight: 600, letterSpacing: -0.4), navLargeTitleTextStyle: TextStyle(inherit: false, color: label(color = Color(0xff000000), *darkColor = Color(0xffffffff)*, resolved by: RandomWords), family: .SF Pro Display, size: 34.0, weight: 700, letterSpacing: 0.4), navActionTextStyle: TextStyle(inherit: false, color: systemBlue(color = Color(0xff007aff), *darkColor = Color(0xff0a84ff)*, highContrastColor = Color(0xff0040dd), darkHighContrastColor = Color(0xff409cff), resolved by: RandomWords), family: .SF Pro Text, size: 17.0, letterSpacing: -0.4, decoration: TextDecoration.none), pickerTextStyle: TextStyle(inherit: false, color: label(color = Color(0xff000000), *darkColor = Color(0xffffffff)*, resolved by: RandomWords), family: .SF Pro Display, size: 21.0, weight: 400, letterSpacing: -0.4), dateTimePickerTextStyle: TextStyle(inherit: false, color: label(color = Color(0xff000000), *darkColor = Color(0xffffffff)*, resolved by: RandomWords), family: .SF Pro Display, size: 21.0, weight: 400)))
> CupertinoTheme.of(context).brightness
null
> CupertinoTheme.brightnessOf(context)
Brightness (Brightness.dark)
```

Nice to see high-contrast support in there! And it sure looks like there's a dark color for text that's applied.

And yet, when rendering finishes, the text is black, not white. Hmm.
Going to let this drop for now.

…ok, accidentally had another look.
I noticed that setting and updating the text style wasn't live-updating; I had to do a full quit and rebuild to see any changes.
At a guess, it might have to do with inlining const values.
(But the text still didn't render with the dark mode color. :( )

Confirmed also an issue on device.

Oh sheesh. Text isn't a Cupertino widget, so it ignores Cupertino styling.
And if I import material, I can see:

```
> Theme.of(context).brightness
Brightness (Brightness.light)
```

Material doesn't seem to be picking up the system brightness.

_I wish Dash had Flutter docs support. It supports Dart, but Flutter packages don't seem to be in Pub for it to fetch the docs?_

### Pulling in a pub package
Add it into the yml file, save, and it gets pulled in.

Importing: I'm not sure what the convention is in Dart-land for import paths.
It seems weird to me to import a specific dart file, but that's what you do.

I keep forgetting to write semicolons. Dart, unlike most everything else, has kept them.

Since I'd already experienced the un-const fun, I didn't hit any snags using the new package.

I kinda wish stuff wasn't all glued into the main namespace, but stayed namespaced. Ah well.

### Adding a stateful widget
> Prefixing an identifier with an underscore enforces privacy in the Dart language and is a recommended best practice for State objects.

 I find this more obvious and intuitive than Go's capitalization-based convention, since it agrees with common practice across a lot of languages for flagging private API.

Painless. Kinda funny they're not actually using diff syntax in the tutorial steps.

Would be more impressive as an Extract Component refactoring that lets you mark the state to yank out.
The expected snippet was there in VS Code, though.

I wonder if the Code extension has first-party support?
Looking at https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter and: yup. First-party. Nice!

### Infinite ListView
Going to comment less and just try to go through this now. Running out of time.
