import 'package:flutter/material.dart';
import 'package:watching_clipboard_demo/clipboard_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  String copiedBitcoinAddress = '';

  @override
  void initState() {
    super.initState();
    _startClipboardWatching();
  }

  void _startClipboardWatching() {
    print("[+] _watchingIncoming");

    widget.clipboardManager.clipboardStream.distinct().skip(1).listen((data) {
      if (isBitcoinAddress(data)) {
        _showBitcoinAddressDialog(data);
      }
    });
  }

  bool isBitcoinAddress(String address) {
    // Implement your Bitcoin address validation logic here
    // Check if the provided address matches the Bitcoin address pattern
    return address.startsWith('bc1');
  }

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
