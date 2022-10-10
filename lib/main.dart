import 'package:calculator/screens/calculator.dart';
import 'package:calculator/screens/settings.dart';
import 'package:flutter/material.dart';

import 'config.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  static ValueNotifier<bool> darkNotifier = ValueNotifier(true);

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    Config.load();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Config.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.darkNotifier,
      builder: (BuildContext context, bool value, Widget? child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Calculator",
        theme: value ? ThemeData.dark() : ThemeData.light(),
        initialRoute: "calculator",
        routes: {
          "calculator": (context) => const Calculator(),
          "settings": (context) => const Settings(),
        },
      ),
    );
  }
}
