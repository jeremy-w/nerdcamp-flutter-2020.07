# Assessing Flutter
I've built iOS, Android, and Web apps.
I've [previously looked at React Native](https://github.com/jeremy-w/nerdcamp-react-native-201712).
I've been curious about Flutter, but I haven't had a chance to dig into it.

This week, I'll be looking at whether Flutter seems usable for the day-to-day,
platform-styled apps I'm used to building on iOS in particular.
I'll also be looking to understand how it's architected and works.

## Contents
- On [Day 1](./Day1.md), I wrote my first Flutter app.
  I deviated from the codelab in favor of creating a Cupertino-style app, which walked straight into issues with rotation and dark mode.
  The rotation issue looks to be a fundamental issue with how Flutter approaches rendering & iOS handles rotation.
  I never quite got Text rendering properly in Dark Mode; the CupertinoThemeData and the ThemeData just aren't on speaking terms.
- On [Day 2](./Day2.md), I looked more at how Flutter is architected and how it addresses cross-cutting concerns like accessibility and internationalization. The general answer is "it's got those covered", but there are some details I'm not convinced it does handle, the biggest probably being announcing changes (Web: [aria-live regions](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Live_Regions), iOS: `UIAccessibility.post(notification: .layoutChanged, argument: stringOrView)`, Android: [accessibilityLiveRegion](https://codelabs.developers.google.com/codelabs/basic-android-accessibility/#6)).
- On [Day 3](./Day3.md), I went back and answered some open questions I'd left about JS FFI and Accessibility from Day 2, then looked at using native UI from Flutter and vice-versa (verdict: avoid using native UI from Flutter if possible) and dug into the dev, debug, and test experience.
    - For debugging, one medium gripe – the lack of autocomplete in the console – and one small gripe: I wish symbolic breakpoints were better-/at-all supported; the lack seems especially odd for native-compiled code, where most debuggers do provide that feature.
    - For testing, Flutter and Dart seem to support everything I'd want from a classical testing environment - great core test library and runner, a matcher system that's easy to extend, and a Mockito port. E2E testing could do with a recording approach to help with initial build-out, but that often seems more demo-fare than actually useful. Unit and widget tests would benefit from mutation, fuzz, and property-based testing support, but I wouldn't be at all surprised to find those are already in Pub. (I just noticed the lack in summing up the day, so I haven't had a look yet.)

## Side Jaunts
- Dark Mode: CupertinoThemeData correctly picks up the system brightness, but in a CupertinoApp, the ThemeData does not, so Text seems to render as if in light mode all the time.
- API Docs: Lots of very visible tasks that aren't getting any investment, it seems.
    - Scrolling: The docs browser at api.flutter.dev doesn't act right on an iPhone. It doesn't scroll to top on status bar tap, and there's no scrollbar, which makes scrolling down to the end of a long page a royal pain, since you can't grab the bar to directly page down 100 pages. [flutter/website doesn't actually manage the API docs](https://github.com/flutter/website/issues/3362#issuecomment-567138709). flutter/flutter [generates the API docs](https://github.com/flutter/flutter/blob/master/dev/tools/dartdoc.dart) using dartdoc. It's in [dartdoc](https://github.com/dart-lang/dartdoc) that the issue must ultimately lie.
    - Size: Turns out the generated docs bundle is huge - there's a file per method. This has been a problem for both Flutter & Dart Angular. https://github.com/dart-lang/dartdoc/issues/1983

## Toolchain
For future reference, I'm using:

```
> flutter --version
Flutter 1.19.0-4.3.pre • channel beta • https://github.com/flutter/flutter.git
Framework • revision 8fe7655ed2 (5 days ago) • 2020-07-01 14:31:18 -0700
Engine • revision 9a28c3bcf4
Tools • Dart 2.9.0 (build 2.9.0-14.1.beta)

> xcodebuild -version
Xcode 11.5
Build version 11E608c

> sw_vers  # Catalina
ProductName:	Mac OS X
ProductVersion:	10.15.5
BuildVersion:	19F101
```
