import 'package:calculator/config.dart';
import 'package:calculator/main.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: <Widget>[
        _title("General"),
        SwitchListTile(
          title: const Text("Dark Mode"),
          value: Config.darkMode,
          onChanged: (value) =>
              setState(() => Config.darkMode = App.darkNotifier.value = value),
        ),
        AboutListTile(
          applicationName: Config.packageInfo.appName,
          applicationVersion: Config.appVersion,
          applicationIcon: Image.asset(
            "assets/icon 128.png",
            width: 80,
          ),
          applicationLegalese: "©2021 FriendlyBanana",
        ),
      ]),
    );
  }

  ListTile _title(String text) {
    return ListTile(
        title: Text(
      text,
      style: TextStyle(color: Theme.of(context).indicatorColor),
    ));
  }
}
