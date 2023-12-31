# Clipboard Monitoring for Bitcoin Addresses in Flutter

## Introduction

Hello, and welcome to this tutorial article! In this article, I'll guide you through the process of implementing clipboard monitoring in a Flutter app. You'll learn how to watch the device clipboard and take actions based on the clipboard data.

<img src="https://i.ibb.co/T4v4j69/Clipboard-Monitoring-for-Bitcoin-Addresses-in-Flutter.gif" alt="Demo" width="400"/>

## Use Case
Have you ever wondered how Bitcoin wallets detect copied addresses and prompt you when you open another wallet? We'll be implementing exactly that functionality in this article.

<img src="https://i.ibb.co/6gvyBVH/blue-wallet-clipboard-dialog.jpg" alt="Clipboard Dialog" width="400"/>

This is what you'll learn to implement in this article.

## Getting Started

Let's begin!

First, create a new Flutter project:

```bash
flutter create watching_clipboard_demo
```

After creating the project, open the `pubspec.yaml`` file and add the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  clipboard_watcher: ^0.2.0
  rxdart: ^0.27.7
  shared_preferences: ^2.2.2
```

Here's what each dependency helps you with:

- `clipboard_watcher`: A Flutter plugin for listening to clipboard changes. Useful for detecting changes in the clipboard.

- `rxdart`: RxDart is a reactive functional programming library for Dart. It provides a set of reactive extensions for Dart streams.

- `shared_preferences`: Shared Preferences plugin for Flutter, providing a persistent key-value store for simple data storage.

After adding the dependencies, run `flutter pub get` to fetch them.

## Clipboard Manager Implementation:
Now, let's create a new file inside the `lib` folder named `clipboard_manager.dart` and add the following code:

```dart
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1
class ClipboardManager extends ClipboardListener {
  // 2
  String? _lastFromAppClip;

  // 3
  static const String LAST_CLIPPING_PREFERENCES_KEY = "lastClipping";
  static const String LAST_FROM_APP_CLIPPING_PREFERENCES_KEY =
      "lastFromAppClipping";

  // 4
  final _clipboardController = BehaviorSubject<String>();
  Stream<String> get clipboardStream => _clipboardController.stream
      .where((content) => content != _lastFromAppClip);

  ClipboardManager() {
    print('[+] Initiating ClipboardManager');

    // 5
    var sharedPreferences = SharedPreferences.getInstance();

    // 6
    sharedPreferences.then((preferences) {
      // 7
      _lastFromAppClip =
          preferences.getString(LAST_FROM_APP_CLIPPING_PREFERENCES_KEY);
      // 8
      _clipboardController
          .add(preferences.getString(LAST_CLIPPING_PREFERENCES_KEY) ?? "");
      print("[+] Last clipping: $_lastFromAppClip");
      // 9
      fetchClipboard(preferences);
    });
    // 10
    clipboardWatcher.addListener(this);
    // 11
    clipboardWatcher.start();
  }

  void fetchClipboard(SharedPreferences preferences) {
    // TODO: Implement fetchClipboard
  }

  Future<void> setClipboardText(String text) async {
    // TODO: Implement setClipboardText
  }

  // 12
  @override
  void onClipboardChanged() {
    print("[+] Clipboard changed");
    // 13
    SharedPreferences.getInstance().then((preferences) {
      fetchClipboard(preferences);
    });
  }
}
```

In this code, we're performing the following steps:

1. The `ClipboardManager` class extends `ClipboardListener` to capture clipboard change events.
2. `_lastFromAppClip` stores the last clipboard content copied from inside our app.
3. Keys used for storing and retrieving clipboard content in SharedPreferences.
4. Controller for managing clipboard content stream.

Inside the `ClipboardManager` constructor, we're:

5. Retriving the `SharedPreferences` instance.
6. Handling the `SharedPreferences` instance when available.
7. Retrieving the last clipboard content copied from inside the app.
8. Adding the last clipboard content to the stream.
9. Fetch the clipboard content.
10. Adding `ClipboardListener` to detect clipboard changes.
11. Starting to listen for clipboard changes.
12. Overriding `onClipboardChanged` method to handle clipboard change events.
13. Getting the `SharedPreferences` instance and fetching clipboard content.

One thing I want you to understand is the approach behind `_lastFromAppClip`, `LAST_CLIPPING_PREFERENCES_KEY`, and `LAST_FROM_APP_CLIPPING_PREFERENCES_KEY`. When the user copies a bitcoin address from inside our app (referred to as "*from app clipping*"), we don't want to show the Clipboard dialog because that content is copied within the app. Displaying the dialog for content copied within the app is considered a bug.

That's why in the `clipboardStream`, we're discarding all elements that are not equal to the content copied within the app (`_lastFromAppClip`).

Let's move on to implement `fetchClipboard` method by locating `// TODO: Implement fetchClipboard` and replacing it with the following code as:

```dart
  void fetchClipboard(SharedPreferences preferences) {
    print("[+] Fetching clipboard");
    // 1
    Clipboard.getData('text/plain').then((clipboardData) {
      // 2
      final text = clipboardData?.text;
      print('[+] Clipboard text: $text');
      // 3
      if (text != null) {
        // 4
        _clipboardController.add(text);
        // 5
        preferences.setString(LAST_CLIPPING_PREFERENCES_KEY, text);
      }
    });
  }
```

The above method retrieves the current content of the clipboard using the `Clipboard.getData` method from the `flutter/services.dart` package. If the clipboard contains text data, it is added to the `_clipboardController` stream and stored in `SharedPreferences` for future reference. Here we're:

1. Using the `Clipboard.getData` method to retrieve clipboard data of type 'text/plain'.
2. Extracting the text content from the clipboard data.
3. Checking if the text content is not null.
4. Adding the text content to the `_clipboardController` stream.
5. Storing the text content in `SharedPreferences` under the specified key.

## Main App Implementation
Now, let's move on to the `main.dart` file and replace the default counter app Flutter example with the following code:

```dart
import 'package:flutter/material.dart';
import 'package:watching_clipboard_demo/clipboard_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1
  final clipboardManager = ClipboardManager();
  runApp(
    MaterialApp(
      home: ClipboardWatcherApp(
        clipboardManager: clipboardManager,
      ),
    ),
  );
}

class ClipboardWatcherApp extends StatefulWidget {
  const ClipboardWatcherApp({
    super.key,
    required this.clipboardManager,
  });
  final ClipboardManager clipboardManager;

  @override
  State<ClipboardWatcherApp> createState() => _ClipboardWatcherAppState();
}

class _ClipboardWatcherAppState extends State<ClipboardWatcherApp> {
  // 2
  String copiedBitcoinAddress = '';

  @override
  void initState() {
    super.initState();
    // 3
    _startClipboardWatching();
  }

  // 4
  void _startClipboardWatching() {
    // TODO: Implement _startClipboardWatching
  }

  // 5
  bool isBitcoinAddress(String address) {
    // TODO: Implement isBitcoinAddress
    // This method should perform Bitcoin address validation.
    // Return true if the address is a valid Bitcoin address, false otherwise.
    return true;
  }

  // 6
  void _showBitcoinAddressDialog(String bitcoinAddress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clipboard"),
          content: const Text(
              "You have a Bitcoin address on your clipboard. Would you like to use it for a transaction?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() => copiedBitcoinAddress = bitcoinAddress);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 7
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.currency_bitcoin_outlined,
                size: 100,
              ),
              Text(
                copiedBitcoinAddress,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

In this code:

1. We initialize `ClipboardManager` to listen for clipboard changes.
2. A variable to store the last copied Bitcoin address.
3. We start watching the clipboard when the app starts.
4. A method to start watching the clipboard for Bitcoin addresses.
5. A method to check if the given string is a Bitcoin address.
6. A method to show a dialog when a Bitcoin address is detected in the clipboard.
7. We build the main screen with a Bitcoin icon and the copied Bitcoin address.

Now, let's run the app and observe the simple screen with the Bitcoin icon in the center.

<img src="https://i.ibb.co/z5D5N8F/Screenshot-1704017539.png" alt="Main Screen" width="400"/>

### Address Validation
Now, let's implement the `isBitcoinAddress` method in `main.dart` by locating `// TODO: Implement isBitcoinAddress` and replace it with the following code:

```dart
  bool isBitcoinAddress(String address) {
    // Implement your Bitcoin address validation logic here
    // Check if the provided address matches the Bitcoin address pattern
    return address.startsWith('bc1');
  }
```

In this `isBitcoinAddress` method, I'm checking if the address starts with `bc1` to determine if it's in segwit or bech32 address format. However, you can use appropriate regex or a Bitcoin package for a more comprehensive validation based on your specific requirements.

### Clipboard Watching
Next, let's implement the `_startClipboardWatching` method by locating `// TODO: Implement _startClipboardWatching` and replacing it with the following code:

```dart
  void _startClipboardWatching() {
    print("[+] _watchingIncoming");

    // 1
    widget.clipboardManager.clipboardStream.distinct().skip(1).listen((data) {
      // 2
      if (isBitcoinAddress(data)) {
        // 3
        _showBitcoinAddressDialog(data);
      }
    });
  }
```

The `_startClipboardWatching` method starts watching the clipboard for Bitcoin addresses. Here's a breakdown:
1. Subscribe to the clipboard stream provided by the `ClipboardManager`.
    - Use `distinct()` to filter out consecutive identical clipboard content.
    - Use `skip(1)` to skip the initial content when the app starts.
    - Use `listen()` to react to changes in the clipboard content.
2. Checking if the clipboard content is a Bitcoin address. 
3. If it is a Bitcoin address, show a dialog to the user.

You maybe thinking why I used `skip(1)` here?

Well, the purpose of `skip(1)` operator is used to skip the initial value emitted by the clipboard stream when the app starts. And the reason of using `skip(1)` is because when the app initializes, the clipboard may already contain some content. If the app doesn't skip the initial value, it might trigger unnecessary actions based on the current clipboard content at the app's launch. By using `skip(1)`, we ensure that the app only react to changes in the clipboard content after the app has started.

Great! With this, we're almost done. Now, run the app again. Copy a Bitcoin address from another app, then open the app. You will see the dialog as shown below:

<img src="https://i.ibb.co/YPgVs6d/Screenshot-1704017829.png" alt="Clipboard Dialog" width="400"/>

Click on "Continue" in the dialog, and the main screen will update accordingly:

<img src="https://i.ibb.co/27TR4yC/Screenshot-1704017852.png" alt="Main Screen Updated" width="400"/>

## Homework and Conclusion
Fantastic! Everything is in place. The only thing left is the setClipboardText method of ClipboardManager, and that is your homework. Try to implement it. Additionally, create a simple widget on the main screen displaying a hardcoded Bitcoin address and a copy button. Clicking on the copy button should copy the Bitcoin address to the clipboard. If the dialog is shown, your implementation is incorrect. If the dialog is not shown, everything is right.

The homework solution will be available on the GitHub repo of this article [here](https://github.com/aniketambore/bitcoin_tutorials_by_anipy/tree/main/watching_clipboard_demo).

If you have questions or want to connect and share your experiences, feel free to reach out to me on Twitter, Nostr, or LinkedIn.

Thank you for joining me. ⚡🌊