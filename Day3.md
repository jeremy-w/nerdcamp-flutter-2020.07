# Day 3: Mixing UI Kits & Dev Experience
## The Plan
- architecture:
        - flutter/native layering: flutter using native, native using flutter, considering both code only & ui.
            - native embedding flutter is well-supported. going the other way is not really recommended for ui, though easy enough for code using plugins & platform channels, as discussed yesterday in ["Communicating Across Boundaries"](./Day2.md#communicating-across-boundaries).
        - how quickly can i adopt new platform APIs? is that gated on the Flutter team doing stuff?
            - updating widget appearance would be gated.
            - introducing new widgets can be done easily yourself.
- dev cycle
    - is there hot-reloading? on which platforms?
        - yes, in debug builds. but not on web; there hot restart alone works.
    - can i live-edit within the app somehow, vs in IDE and wait for deploy? handy for tweaking magic constants for offset, color, animation speed. (like Chrome's "sync in-browser changes back to disk" support for web code)
        - no, but hot reload is fast enough that it's not a big loss.
- testing
    - what does E2E and Unit testing look like?
        - see: https://flutter.dev/docs/testing
        - flutter divides the world into unit, widget (component), and e2e tests.
        - unit tests use the [test package](https://pub.dev/packages/test).
        - widget tests use the [flutter_test package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) and the `testWidgets` test function, which gets handed a `WidgetTester` to interact with widgets and `find` class to build widget finders, which are asserted against using `findsOneWidget` and such. `find.byWidget()` where you pass in the actual `Widget` instance you're testing is kind of mindblowing, coming from iOS out-of-process UI testing.
        - e2e tests use [flutter_driver]() and [e2e]().
        - integration tests use
    - good libraries for mocks, spies, matchers and friends?
        - The test and mockito packages have you covered.
        - **TODO: What about network testing?**
- how does the debugging setup work:
    - with dart CLI apps?
    - with a Flutter app running on iOS?
    - on the Web?
    - **all platforms are debugged pretty much the same. things are moving from Observatory to the Dart Debugger. IDE support is good.**
- what can debugging do? does it vary by platform?
    - can i explore the component tree in a debugger somehow?
        - yes, using the Dart DevTools. the layout explorer only works with Flex widgets. there is a "Select Widget Mode" that lets you touch the widget you want to focus in the debugger, and that also calls out the selected widget in the app.
        - but how can i map from a widget to something i can poke at in the console?
        - **VSCode's debug console doesn't have autocomplete!**
        - I can't seem to interact with the Console panel in Chrome in the Dart Debugger when paused, at least when I launched everything via Code. breakpoints set in the Dart Debugger in Chrome don't show up in Code, but those set in Code do show up in DD. If I step in DD, Code comes to the fore. Interestingly, DD does indicate position within the paused line, not just the currently paused line as Code does.
    - can i set breakpoints
        - by line? **yes.**
        - symbolically?
            - **not in Dart DevTools.** VS Code will let you add it, then show it grayed out with a note that "function breakpoints are not supported by this debug type".
            - **yes in Observatory, but it gets resolved to a file:line breakpoint.** Observatory has a more typical debugger REPL, but it's very limited. e.g. `break main` answers "Function 'main' is ambiguous" without explaining the available symbols, or, say, setting a breakpoint at all of them. Attempting to narrow it down using expressions like `main.dart:main` or `main.dart/main` just give a "Function '…' not found" error. There is nothing like `i sym` to dump the known symbols.
        - in third-party code? **where you have the source, yes.**
        - **TODO: Does Pub support shipping binary resources? Binary-only packages?**

## Retro
- i feel like i covered a ton today. playing with debugging & investigating test APIs felt meaty.

## Flutter & Native, Together
- hosting flutter in your app: expected use case for trialing or rewriting an app into Flutter.
    - well-supported using an "in-app module". see: https://flutter.dev/docs/development/add-to-app
    - there's mention throughout about only supporting one FlutterViewController per app, but i believe that limit is being relaxed with the new plugin system.
    - you can keep the FlutterEngine running independent of the FlutterViewController, which might come and go. this would also let you move generic business logic into Dart code, though i expect you could just embed Dart directly without the Flutter part if you wanted that?
        - perhaps not - i see no discussion of embedding on the main Dart page. [dart2native](https://dart.dev/tools/dart2native) builds x64 machine code, while flutter docs say flutter can compile to native code only for arm64, not x64. hmm.
        - that said, the Flutter docs do talk about "if you used the Dart SDK directly, without the Flutter engine" (https://flutter.dev/docs/development/add-to-app/performance#starting-the-dart-vm), so maybe yes?
            - "One isolate exists per FlutterEngine instance, and multiple isolates can be hosted by the same Dart VM." so perhaps you can have at most one Dart VM in the app, but multiple engines and so FlutterVCs now?
            - "Behind the scene, both platform’s UI components provide the FlutterEngine with a rendering surface such as a Surface on Android or a CAEAGLLayer or CAMetalLayer on iOS. At this point, the [Layer](https://api.flutter.dev/flutter/rendering/Layer-class.html) tree generated by your Flutter program, per frame, is converted into OpenGL (or Vulkan or Metal) GPU instructions." Oh hey, so that's what it boils down to. So add the **Layer tree** to my mental collection of Flutter trees (Semantics, Widgets, Elements, RenderObjects/RenderBoxes, Layers).
- **hosting native views in Flutter: experimental; avoid whenever possible.**
    - very much discouraged, as it's very expensive to render & wrangle
    - supported on Android API 20+ per [AndroidView](https://api.flutter.dev/flutter/widgets/AndroidView-class.html#autolink-68120).
    - in preview for iOS per [UIKitView](https://api.flutter.dev/flutter/widgets/UiKitView-class.html):

      > Embedding UIViews is still in release preview, to enable the preview for an iOS app add a boolean field with the key 'io.flutter.embedded_views_preview' and the value set to 'YES' to the application's Info.plist file
    - there's no real docs for either of these.
    - i'm not clear on the relationship to [PlatformViewLink](https://api.flutter.dev/flutter/widgets/PlatformViewLink-class.html). [`SceneBuilder.addPlatformView()](https://api.flutter.dev/flutter/dart-ui/SceneBuilder/addPlatformView.html) is a no-op outside iOS.
    - a key component looks to be [PlatformViewsService.initUiKitView()](https://api.flutter.dev/flutter/services/PlatformViewsService/initUiKitView.html) which mentions registering platform views in a registry and registering factories for them in plugin code.
    - [PlatformViewSurface](https://api.flutter.dev/flutter/widgets/PlatformViewSurface-class.html#autolink-72394) explains that "PlatformViewLayer isn't supported on all platforms (e.g on Android platform views are composited using a TextureLayer)", which might in part explain the Android / iOS disparity here?


huh, a very practical compromise on named args: suffix initials onto the function name. `RRect.fromLTRBXY()` has left, top, right, bottom edge, and x/y radius args. (The full RRect supports different radii for each corner, e.g. `brRadiusX` for the bottom-right X radius.)

## Error Handling
https://flutter.dev/docs/testing/errors

errors in callbacks are caught by the framework and reported to an app-wide `FlutterError.onError` handler. by default, it logs.

errors in build functions are routed to `ErrorWidget.builder`, which returns either a red box with error text (debug mode) or a gray rect (not-debug). this would seem to preclude React's notion of an error boundary, though effectively the default behavior seems to be to have every widget be its own error boundary.

## Testing
### The test package
https://pub.dev/documentation/test/latest/test/test-library.html

can run in browser, node, or vm. node tests can't access `dart:io` or `dart:html`. and of course, with flutter, it can run in platform environments, which i guess are VMs that might be on-device.

can groups nest in other groups? yes, the group doc mentions "tests or subgroup". the description (it can be any object that can be stringified) is tacked on to child group/test names. "All tags should be declared in the package configuration file" has a dead link to the package config file.

supports setUp and setUpAll and corresponding tearDown/All per group.

suites (aka files), groups, and tests can be skipped, but that determination cannot be made at runtime. (it sort of can - you can pass a skip: true flag to `expect(actual, matches)`; it will still evaluate actual & expected, but won't match them.)

a separate testOn annotation is available for restricting to specific platforms.

async tests are automatically supported; the default timeout duration is 30 seconds, but that can be set at the per-file level. a config file can also be used tweak settings, as can CLI settings, and in-code config. an interesting feature is expressing timeout adjustments in terms of a multiplication factor, e.g. `Timeout.factor(2)` for saying "this should be given 2x as long as the usual timeout".

tests can be tagged. tests can be annotated for retry. onPlatform support lets you configure tests (e.g. timeouts or skipped-ness) per platform.

hybrid tests are supported, where code runs in the browser & in the VM, which can be used to set up mock servers.

`test` comes with stream-matchers for talking about the output values of a stream. `expect(actual, matcher, reason)` (give or take a few other args) is the basic assertion mechanism. **matchers can be async (!),** and execution will just continue past, with the test running till they complete; you can `await expectLater(…)` if you want a barrier there.

making a custom matcher is pretty easy: you subclass `Matcher` and implement at the least `matches` and `describe`, or if it's just a specific value you can compute and equality check, subclass `CustomMatcher` and pass in a description, feature name, and a feature-extractor. You can also use `wrapMatcher` to turn a predicate function into a matcher; there's no way to pass a name with that, so you'd need that reason param on `expect`.

the docs are really harmed by not being grouped in any way; you can't readily locate various kinds of matcher vs core structuring functions vs test helpers (like `escape` and `collapseWhitespace`).

but overall this is a pretty darn nice core test library!

some sort of mocking support? `neverCalled`, `expectAsync` and `expectAsyncUntil` (well, their 0, 1, …, 6 arity variants)?

there's also a [mockito](https://pub.dev/packages/mockito) port that makes good use of `noSuchMethod`.

and a teensy **codegen helper** to avoid a tch of boilerplate, [mockito-codegen](https://pub.dev/packages/mockito_code_generator) that turns `@BuildMock() Cat _cat;` into `class CatMock extends Mock implements Cat {}` plus generates `_initMocks()` to assign `_cat = CatMock();`. `part 'my_test.g.dart'` in the main one, then generates that file with `part of 'my_test.dart'`. codegen leans on `build` + `analyzer` to find stuff and `source_gen` to actually generate the code, all of which were written by Googlers.

codegen & dynamic programming: very exciting. :D

### flutter_test
https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html

oh wow, there _are_ automated tests for some accessibility guidelines! e.g. `MinimumTextContrastGuideline().evaluate(tester)`

`testWidgets` supports a `variant` arg and is run once per `variant.values` element. the variant object gets to run per-variation setup and teardown. i don't see any way to get at the current variant in the test, though? ooh, `test.addTearDown`, there's a convenient helper.

### flutter_driver & e2e
https://api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html

https://pub.dev/packages/e2e

**TODO: flutter_driver & e2e**

looks like out-of-process testing.

i think e2e is replacing flutter_driver (https://github.com/flutter/website/issues/4240) & letting you use regular widgetTests, with some per-platform native code setup required. the docs are kind of scant.
