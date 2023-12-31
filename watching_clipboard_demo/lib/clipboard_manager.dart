import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardManager extends ClipboardListener {
  String? _lastFromAppClip;

  static const String LAST_CLIPPING_PREFERENCES_KEY = "lastClipping";
  static const String LAST_FROM_APP_CLIPPING_PREFERENCES_KEY =
      "lastFromAppClipping";

  final _clipboardController = BehaviorSubject<String>();
  Stream<String> get clipboardStream => _clipboardController.stream
      .where((content) => content != _lastFromAppClip);

  ClipboardManager() {
    print('[+] Initiating ClipboardManager');

    var sharedPreferences = SharedPreferences.getInstance();

    sharedPreferences.then((preferences) {
      _lastFromAppClip =
          preferences.getString(LAST_FROM_APP_CLIPPING_PREFERENCES_KEY);
      _clipboardController
          .add(preferences.getString(LAST_CLIPPING_PREFERENCES_KEY) ?? "");
      print("[+] Last clipping: $_lastFromAppClip");
      fetchClipboard(preferences);
    });
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

  void fetchClipboard(SharedPreferences preferences) {
    print("[+] Fetching clipboard");
    Clipboard.getData('text/plain').then((clipboardData) {
      final text = clipboardData?.text;
      print('[+] Clipboard text: $text');
      if (text != null) {
        _clipboardController.add(text);
        preferences.setString(LAST_CLIPPING_PREFERENCES_KEY, text);
      }
    });
  }

  Future<void> setClipboardText(String text) async {
    // TODO: Implement setClipboardText
  }

  @override
  void onClipboardChanged() {
    print("[+] Clipboard changed");
    SharedPreferences.getInstance().then((preferences) {
      fetchClipboard(preferences);
    });
  }
}
