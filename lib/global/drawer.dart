import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/l10n/app_localizations.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:unmobile/notifiers/theme_mode.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _selectedServer = '';
  AuthState? _state;
  ThemeNotifier? _theme;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    _theme = Provider.of<ThemeNotifier>(context, listen: false);
    if (_state!.client != null) {
      _state!.client!.resetStore();
      _selectedServer = _state!.getSelectedServerIp() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthState state = Provider.of<AuthState>(context, listen: false);

    return Drawer(
        child: Column(children: [
      DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.userAstronaut,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                state.userData?["name"] ?? 'Unknown User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '(${(state.userData?["roles"] is List && (state.userData?["roles"]?.isNotEmpty ?? false)) ? state.userData!["roles"][0] : "No Role"})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Consumer<AuthState>(builder: (context, authState, child) {
                if (authState.client == null) {
                  return SizedBox.shrink();
                }
                final servers = authState.getMultiservers();
                if (servers.isEmpty) {
                  return SizedBox.shrink();
                }

                return DropdownButton<String>(
                  isDense: true,
                  value: _selectedServer,
                  dropdownColor: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: Container(height: 0),
                  items: [
                    for (var server in servers)
                      DropdownMenuItem<String>(
                        value: server['ip'],
                        child: SizedBox(
                          width: 160,
                          child: Text(
                            server['ip'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != _selectedServer) {
                      try {
                        await state.switchMultiserver(newValue);
                        _selectedServer = newValue;                        
                        Navigator.of(context)
                              .pushReplacementNamed(Routes.dashboard);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Align(
                                  child: Text('Server switched to $newValue')),
                              duration: const Duration(seconds: 3)));
                      } on AuthException catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Align(
                              alignment: Alignment.center, child: Text(e.msg)),
                          duration: const Duration(seconds: 3),
                        ));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Align(
                              alignment: Alignment.center,
                              child: Text('Failed to switch server')),
                          duration: const Duration(seconds: 3),
                        ));
                      }
                    }
                  },
                );
              }),
            ],
          ))),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(
              child: faIcon(FontAwesomeIcons.gauge),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.dashBoardTitle),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(Routes.dashboard);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.hardDrive)),
          ),
          title: Text(AppLocalizations.of(context)!.arrayTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.array);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.folder)),
          ),
          title: Text(AppLocalizations.of(context)!.sharesTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.shares);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.docker)),
          ),
          title: Text(AppLocalizations.of(context)!.dockerContainerTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.dockers);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.desktop)),
          ),
          title: Text(AppLocalizations.of(context)!.virtualMachineTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.vms);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.server)),
          ),
          title: Text(AppLocalizations.of(context)!.systemInfoTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.system);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.puzzlePiece)),
          ),
          title: Text(AppLocalizations.of(context)!.pluginsTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.plugins);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: faIcon(FontAwesomeIcons.gear)),
          ),
          title: Text(AppLocalizations.of(context)!.settingsTitle),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.settings);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child:
                Center(child: faIcon(FontAwesomeIcons.arrowRightFromBracket)),
          ),
          title: Text(AppLocalizations.of(context)!.logoutTitle),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Do you really want to logout?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              state.logout();
                            })
                      ]);
                });
          }),
    ]));
  }

    Widget faIcon(IconData icon, {double? size}) {
    return FaIcon(
      icon,
      color: _theme!.isDarkMode ? Colors.orange : Colors.black,
      size: size,
    );
  }
}
