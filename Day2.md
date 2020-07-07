# Day 2: Runtime & Compile-Time Architecture
## The Plan
Runtime:

- how is flutter itself put together?
    - engine + framework.
- how does it render UI?
    - TODO: breakpoint in drawing somehow?
- how does it get input events?
    - TODO: breakpoint in an event handler
- what's the update loop look like?
    - TODO: find this in the source code
- what does this mean for:
    - accessibility?
        - reduce motion
        - bold text
        - reduce transparency
        - voiceover
        - switch control
        - aria-live regions
        - **should be able to test this in the context of a codelab app deployed to an iPhone and for Web hosted locally and visited in Mobile Safari.**
- accessibility for custom-drawing?
    - You'd be using Widgets, which can attach Semantics, so you should be good to go.
- i18n?
    - Good enough for textual stuff, though not active by default. Consider how Flutter code samples don't use localized messages, just plain strings, vs common use on iOS of `NSLocalizedString` even in basic sample code.
    - Totally manual for binary resources such as images.
    - Independent of platform mechanisms, aside from locale selection.
    - TODO: Check into non-Gregorian calendar support, start of week, and contact name order support.
- platform UI changes, e.g. rounded corners or colors?
    - Not automatic. Updates as needed, though they mostly speak of adding widgets, not updating the behavior of existing widgets to play nice across iOS versions (they support back to iOS 8!). See [FAQ, "What happens when my mobile OS updates and introduces new widgets?"](https://flutter.dev/docs/resources/faq#what-happens-when-my-mobile-os-updates-and-introduces-new-widgets)
    - (Though I'd like to see the source for some of the system colors, to see if they are in fact reading in from the system.)
- animations?
    - Built-in support, though picking the right tool for the job has a heck of an [animation means decision diagram](https://flutter.dev/docs/development/ui/animations#choosing-an-approach). The core split is between drawing-based and code-based. Opacity is apparently a major gotcha, and the built-in fader uses a shader to do the job?
    - The core animation system seems pretty sensible, though it'd take some practice to get comfortable with. Flutter's "own the drawing all the way down" + AOT compilation approach definitely shines here; this is not the bugbear it can be for React Native.

Compile-time:

_this was originally planned for Monday_

- what does CI look like?
- what build platforms are supported? (can i do dev on windows? linux?)
- cross-compilation support? or do you need multiple runners?
- any good linters? autoformatters?
- what gets run to create a flutter app for various platforms?
- what are the inputs and build artifacts?
- can you ship a binary library, or only open source?

## Retro
- I feel pretty good about today. I didn't answer all the questions, but the questions I have open are mostly good ones that I can test with an experiment now. I spent a lot of time reading docs on the main Flutter site, and I think that's paying off. I would like to write some more code, but that's mostly the slow way to learn things, as necessary as it is to building the right intuitions for solving problems and getting things done.
- Opened a PR fixing a Getting Started walkthrough page that stumped me yesterday: https://github.com/flutter/website/pull/4310
- And another PR that should save someone a click, on how relative package paths are understood: https://github.com/flutter/website/pull/4311
- Started reading about how Flutter plans to tackle state restoration. Leaving several comments with a more Apple-platform perspective as I go
    - [The Proposal Doc](https://flutter.dev/go/state-restoration-design)
    - [The Implementation](https://github.com/flutter/flutter/pull/60375)

## Runtime Architecture
Uses a VM in debug mode to enable hot-reload, AOT-compiled code otherwise.

### System Level
I'm focusing on native mobile app uses. Web is still WIP; there's no way to do a platform-check, the [forward button doesn't work in the browser](https://flutter.dev/docs/development/platform-integration/web#how-are-forward-and-backward-buttons-presented-in-the-web-ui), dart:ffi apparently isn't supported?, and hot reload doesn't work, just hot restart (discarding all state back to initial).

#### Framework + Engine
At a high level, it's basically a lot of dart code in the [Flutter framework](https://github.com/flutter/flutter), which provides a React-like framework, atop a thin core [engine](https://github.com/flutter/engine) implemented mostly in C/++. The engine is built using [ninja build files](https://ninja-build.org/) generated using [GN (Generate Ninja)](https://github.com/o-lim/generate-ninja), which just so happens to be what the Chromium team also uses. (It's even a valid cmake output target.)

#### No Reflection
One interesting decision with Flutter is to not allow use of dart:mirror (reflection) and dart:html. In the case of mirror, it's to ease treeshaking: reflection effectively marks everything as used (as stated in ["Is there a GSON/Jackson/Moshi equivalent for Flutter?"](https://flutter.dev/docs/development/data-and-backend/json#is-there-a-gsonjacksonmoshi-equivalent-in-flutter)). For html, I have yet to see an explanation; I'm guessing it's just that it's a lot of code that isn't generally needed in the expected applications.

### Lifecycle & Updates
Flutter maintains an Element tree with RenderObjects (specifically RenderBoxes) and a Widget tree that describes the Element tree. The Elements are like the DOM, and the Widgets are the VDOM.

But alongside them is a separate [State](https://api.flutter.dev/flutter/widgets/State-class.html) collection. The Widgets can be completely clobbered, but the State can hang around, which is what enables easy hot-reload. In fact, it's the State that is responsible for building a StatefulWidget, not the StatefulWidget itself. (Even more interesting: The same Widget can get inflated multiple times, so you can have many States for a single Widget.) Identity seems to be tracked by [Key](https://api.flutter.dev/flutter/foundation/Key-class.html).

And the Semantics tree is another parallel tree derived from the Widgets. It's used to support accessibility.

Layout is interesting: constraints on width/height propagate down the tree, widgets return their desired size within that box, and then their parent gets to lay them out. A widget doesn't control where its box origin is, just its box size. See: ["Understanding Constraints"](https://flutter.dev/docs/development/ui/layout/constraints), which sums it up as "constraints down, sizes up, parent sets position."

`InheritedWidget` and friends rig up rebuilding on value change in the environment; think React's ContextProvider. [`InheritedModel`](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html) supports changing only when certain aspects change, vs anything about the widget. Nicer APIs have been built atop these:

- [Provider](https://pub.dev/packages/provider)
- [Scoped Model](https://pub.dev/packages/scoped_model)

There's a great State roundup at https://flutter.dev/docs/development/data-and-backend/state-mgmt/options. Redux, BLoC (Reactive), and MobX also make appearances.

### Communicating Across Boundaries
So, how do the framework and the engine work together?

Let's start with how the framework and the app work together.

On the one hand, you can **directly call C code**: load a dylib/static lib in, pull out its globals by C name, cast it to the right type, and invoke it. (This doesn't work on the Web. Presumably Dart has some way to call into JS?) This is handy for third-party frameworks you want to use directly. See: ["Binding to native code using dart:ffi"](https://flutter.dev/docs/development/platform-integration/c-interop). If you've messed with `dlopen` & `dlsym` in C code, this will be really familiar!

On the other hand, you can stand up a named, bidirectional message channel to send requests and wait for responses. It's all stringly-typed. The [Pigeon RPC codegen package](https://pub.dev/packages/pigeon) can fix a lot of that. The actual codec used is configurable, and you can use a custom one, as apparently Firebase has done. This is handy for **accessing platform APIs** that aren't bound otherwise, or just quickly **bridging into native code** and back. All calls are async and have a future result, which means you need to handle failure. See: ["Writing custom platform-specific code"](https://flutter.dev/docs/development/platform-integration/platform-channels). The one gotcha is that it's **all main-thread–only.**

You can use your app for servicing the channel directly, or move it into a plugin. Those plugins can be published as packages to Pub.

Since late April with Flutter 1.12, Flutter supports ["federated plugins"](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#federated-plugins). These plugins are the result of several coordinating packages, that need not be developed all by the same author:

- App package, which defines your public API: `my_plugin`, depending on `my_plugin_platform_interface` and any known platforms (for convenience; the registration system of clobbering a global `MyPlugin.instance` when the platform-specific package gets attached to a Flutter Engine will allow even a not-depended-on platform to be used)
- Platform interface package, which defines the internal interface between the app package and whatever the platform is: `my_plugin_platform_interface`, depending on `plugin_platform_interface`
- Per-platform implementations of that interface, for however many platforms you support: `my_plugin_ios`, `my_plugin_android`, etc., each depending on `my_plugin_platform_interface`.

Generally, the app package and platform interface package (which tends to include the MethodChannel bindings) are developed up-front with at least one platform package.
Then other platform packages can be published as desired; they need not be part of the same codebase.

This is reminiscent of KMP's approach with expect/actual, but the federation is unique.

The default template also includes an example Flutter app, which conveniently gives you a test host for e2e testing. Pub also shows an "Example" tab with the contents of that example. Usually it's just one big lib/main.dart.

**Dependencies on other plugins are not automatically synced between the pubspec & the native projects.** You have to remember to both depend on the Dart package and wire up the native project Xcode framework dependency for an iOS package.

The old system just kind of assumed both iOS & Android were supported, and it had no way of declaring which platforms actually were supported. This was an OK assumption, up till Flutter added several more platforms in the form of Web and several desktop OSs. And as to the name: "Plugins that are distributed across multiple packages are called federated plugins" (https://medium.com/flutter/modern-flutter-plugin-development-4c3ee015cf5a#8702).

The main docs on this didn't do as good a job of explaining it as the [more Android-focused Medium article](https://medium.com/flutter/modern-flutter-plugin-development-4c3ee015cf5a#8702), FWIW.
But the [original federated plugins proposal](https://flutter.dev/go/federated-plugins) gets even more into the details.

Backwards compatibility is a big concern due to the federation.
https://pub.dev/packages/plugin_platform_interface is a good starting point.

I'm going to generate a boilerplate plugin & then look up this url_launcher one ([url_launcher package](https://pub.dev/packages/url_launcher) and [url_launcher repo](https://github.com/flutter/plugins/tree/master/packages/url_launcher)) they keep talking about.

### Accessibility
https://flutter.dev/docs/development/accessibility-and-localization/accessibility

Accessibility is handled explicitly within the framework using Semantics nodes. The basics appear to Just Work for the most part. Fonts by default respect the system type size preference, too. (Though I expect const Texts won't live-update as the type size pref changes, and I didn't see guidance on manually sizing things relative to the preference - **I don't know how the system text size pref would be read directly.**) Ditto for **Reduce Motion** or **Reduce Transparency.**

I also don't see any interface for **announcing changes** or explicitly **managing focus**; likewise I don't know that any way is exposed to respond to whether a certain assistive tech is active.

So it's way better than I feared, but also either missing a lot, or substantially underdocumented. And tooling is mostly at the platform level; there's no Flutter-level contrast checker, for example.

### I18n
https://flutter.dev/docs/development/accessibility-and-localization/internationalization

Interesting - localization currently doesn't auto-resolve bundled assets:

> Flutter uses asset variants when choosing resolution-appropriate images. In the future, this mechanism might be extended to include variants for different locales or regions, reading directions, and so on. ([Asset variants, "Assets and Images"](https://flutter.dev/docs/development/ui/assets-and-images#asset-variants))

You have to opt into supporting specific locales. Localizations for system stuff are not shipped by default, but easy to pull in. There are only ~70 strings in the system stuff anyway (https://flutter.dev/docs/development/accessibility-and-localization/internationalization#adding-support-for-a-new-language).

The core support is all at the Dart level. Date, time, and numbers are all supported. There's an [intl package](https://pub.dev/packages/intl) and tooling for extracting resources to an App Resource Bundle (ARB) and importing them back into Dart code defining Messages. The messages support parametrization by number and by gender:

```dart
remainingEmailsMessage(int howMany, String userName) =>
Intl.message(
    '''${Intl.plural(howMany,
        zero: 'There are no emails left for $userName.',
        one: 'There is $howMany email left for $userName.',
        other: 'There are $howMany emails left for $userName.')}''',
name: 'remainingEmailsMessage',
args: [howMany, userName],
desc: How many emails remain after archiving.',
examples: const {'howMany': 42, 'userName': 'Fred'});

print(remainingEmailsMessage(1, 'Fred'));

notOnlineMessage(String userName, String userGender) =>
    Intl.gender(
        userGender,
        male: '$userName is unavailable because he is not online.',
        female: '$userName is unavailable because she is not online.',
        other: '$userName is unavailable because they are not online',
        name: 'notOnlineMessage',
        args: [userName, userGender],
        desc: 'The user is not available to hangout.',
        examples: const {{'userGender': 'male', 'userName': 'Fred'},
            {'userGender': 'female', 'userName' : 'Alice'}});
```

Overall, things look to be in pretty good shape for locale-specific text, but not so good for locale-specific assets. And the system is entirely opt-in. And keeping it in sync with the iOS Info.plist is entirely manual.

## Compile-Time Architecture
TODO: This was originally planned for Monday.

And I guess now it gets kicked to Wednesday.

This looks promising though: https://github.com/flutter/flutter/wiki/The-Engine-architecture

## New Platform-Specific Concerns: Text Editing
After reading about [platform adaptations](https://flutter.dev/docs/resources/platform-adaptations),
I wonder if they're out of date on the text editing behavior.
E.g. now long-press highlights word just like Android, and swiping extends selection.

And does it handle the long-press spacebar to trigger cursoring, like was previously only handled via 3D Touch?

I wonder if the "Speak Text" prompt shows up as well.
