import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String _selectedServer;

  @override
  void initState() {
    super.initState();
    _selectedServer = Provider.of<AuthState>(context, listen: false).getSelectedServerIp() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    AuthState state = Provider.of<AuthState>(context, listen: false);

    return Drawer(
        child: Column(children: [
      DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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
                state.userData["name"],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '(${state.userData["roles"][0]})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Consumer<AuthState>(builder: (context, authState, child) {
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
                        Navigator.of(context).pop();
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Align(
                                  child: Text('Server switched to $newValue')),
                              duration: const Duration(seconds: 3)));
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.dashboard);
                        });
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
              child: FaIcon(FontAwesomeIcons.gauge),
            ),
          ),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(Routes.dashboard);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.hardDrive)),
          ),
          title: const Text('Array'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.array);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.folder)),
          ),
          title: const Text('Shares'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.shares);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.docker)),
          ),
          title: const Text('Docker Containers'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.dockers);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.desktop)),
          ),
          title: const Text('Virtual Machines'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.vms);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.server)),
          ),
          title: const Text('System Info'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.system);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.puzzlePiece)),
          ),
          title: const Text('Plugins'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.plugins);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(child: FaIcon(FontAwesomeIcons.gear)),
          ),
          title: const Text('Settings'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.settings);
          }),
      ListTile(
          leading: SizedBox(
            width: 30,
            child:
                Center(child: FaIcon(FontAwesomeIcons.arrowRightFromBracket)),
          ),
          title: const Text('Logout'),
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

}
