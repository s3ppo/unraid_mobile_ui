import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:unmobile/notifiers/locale_notifier.dart';
import 'package:unmobile/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<SettingsPage> {
  AuthState? _state;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    if(_state!.client != null) {
      _state!.client!.resetStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settingsTitle),
          actions: <Widget>[],
          elevation: 0,
        ),
        body: Container(child: showSettingsContent()));
  }

  Widget showSettingsContent() {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final currentLocale = localeNotifier.locale;

    String currentLanguageLabel;
    if (currentLocale == null) {
      currentLanguageLabel = AppLocalizations.of(context)!.languageSystemDefault;
    } else if (currentLocale.languageCode == 'zh') {
      currentLanguageLabel = AppLocalizations.of(context)!.languageChinese;
    } else {
      currentLanguageLabel = AppLocalizations.of(context)!.languageEnglish;
    }

    return ListView(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.multiserverSettingsTitle),
          onTap: () {
            Navigator.pushNamed(context, Routes.settingsMultiserver);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)!.languageTitle),
          subtitle: Text(currentLanguageLabel),
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.languageTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<Locale?>(
                        title: Text(AppLocalizations.of(context)!.languageSystemDefault),
                        value: null,
                        groupValue: localeNotifier.locale,
                        onChanged: (value) {
                          localeNotifier.setLocale(null);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile<Locale?>(
                        title: Text(AppLocalizations.of(context)!.languageEnglish),
                        value: const Locale('en'),
                        groupValue: localeNotifier.locale,
                        onChanged: (value) {
                          localeNotifier.setLocale(value);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile<Locale?>(
                        title: Text(AppLocalizations.of(context)!.languageChinese),
                        value: const Locale('zh'),
                        groupValue: localeNotifier.locale,
                        onChanged: (value) {
                          localeNotifier.setLocale(value);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
