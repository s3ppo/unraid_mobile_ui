import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/l10n/app_localizations.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class SettingsMultiserver extends StatefulWidget {
  const SettingsMultiserver({Key? key}) : super(key: key);

  @override
  _MySettingsMultiserverState createState() => _MySettingsMultiserverState();
}

class _MySettingsMultiserverState extends State<SettingsMultiserver> {
  AuthState? _state;
  List<dynamic> _servers = [];

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    if(_state!.client != null) {
      _state!.client!.resetStore();
      _servers = _state!.getMultiservers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.multiserverSettingsTitle),
        actions: <Widget>[],
        elevation: 0,
      ),
      body: Container(child: showListContent()),
      floatingActionButton: FloatingActionButton(
        onPressed: pressAddServer,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget showListContent() {
    return ListView.builder(
        itemCount: _servers.length,
        itemBuilder: (context, index) {
          final server = _servers[index];
          return ListTile(
            enabled: _state!.storage.getString('ip') != server['ip'],
            title: Text(server['ip']),
            subtitle: Text('Protocol: ${server['prot']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _state!.storage.getString('ip') == server['ip']
                  ? null
                  : () {
                      setState(() {
                        _servers.removeAt(index);
                        _state!.removeMultiserver(server['ip']);
                      });
                    },
            ),
          );
        });
  }

  void pressAddServer() {
    // Show a dialog to add a new server
    showDialog(
      context: context,
      builder: (context) {
        String ip = '';
        String token = '';
        String protocol = 'http';
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addServer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Server IP:Port'),
                onChanged: (value) {
                  ip = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Token'),
                onChanged: (value) {
                  token = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Protocol'),
                initialValue: 'http',
                items: [
                  DropdownMenuItem(value: 'http', child: Text('http')),
                  DropdownMenuItem(value: 'https', child: Text('https')),
                  DropdownMenuItem(
                      value: 'https_insecure', child: Text('https(insecure)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    protocol = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (ip.isNotEmpty && token.isNotEmpty && protocol.isNotEmpty) {
                  await _state!.setMultiservers(ip, protocol, token);
                  setState(() {
                    _servers = _state!.getMultiservers();
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }
}
