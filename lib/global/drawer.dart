import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);
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
                SizedBox(height: 12),
                Text(
                  state.userData["name"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(${state.userData["roles"][0]})',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
      ListTile(
          leading: SizedBox(
            width: 30,
            child: Center(
              child: FaIcon(FontAwesomeIcons.gauge),
            ),
          ),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.dashboard);
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
