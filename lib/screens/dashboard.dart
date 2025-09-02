import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/drawer.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/notifiers/theme_mode.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _MyDashboardPageState createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<DashboardPage> {
  AuthState? _state;
  ThemeNotifier? _theme;
  Future<QueryResult>? _unreadNotifications;
  Future<QueryResult>? _serverCard;
  Future<QueryResult>? _arrayCard;
  Future<QueryResult>? _infoCard;
  Future<QueryResult>? _parityCard;
  Future<QueryResult>? _upsCard;

  bool _showMoreArrayDetails = false;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    _theme = Provider.of<ThemeNotifier>(context, listen: false);
    if (_state!.client != null) {
      _state!.client!.resetStore();
      getNotifications();
      getServerCard();
      getArrayCard();
      getInfoCard();
      getParityCard();
      getUpsCard();
    }
  }

  void getNotifications() {
    _unreadNotifications = _state!.client!.query(QueryOptions(
      document: gql(Queries.getNotificationsUnread),
    ));
  }

  void getServerCard() {
    _serverCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getServerCard),
    ));
  }

  void getArrayCard() {
    _arrayCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getArrayCard),
    ));
  }

  void getInfoCard() {
    _infoCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getInfoCard),
    ));
  }

  void getParityCard() {
    _parityCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getParityCard),
    ));
  }

  void getUpsCard() {
    _upsCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getUpsCard),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('unMobile'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                _theme!.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () {
                setState(() {
                  _theme!.toggleTheme();
                });
              },
            ),
            Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: showNotificationsButton())
          ],
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (_state!.client == null) {
              return;
            }
            _state!.client!.resetStore();
            getNotifications();
            getServerCard();
            getArrayCard();
            getInfoCard();
            getParityCard();
            getUpsCard();
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: ListView(
              children: [
                const SizedBox(height: 4),
                showServerCard(),
                showArrayCard(),
                showInfoCard(),
                showParityCard(),
                showUpsCard()
              ],
            ),
          ),
        ),
        drawer: MyDrawer());
  }

  void navigateNotifications() {
    Navigator.of(context).pushNamed(Routes.notifications);
  }

  Widget showServerCard() {
    return FutureBuilder<QueryResult>(
        future: _serverCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final server = snapshot.data!.data!['server'];
            final vars = snapshot.data!.data!['vars'];
            final info = snapshot.data!.data!['info'];

            return Card(
                elevation: 2,
                child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionTile(
                              shape: const Border(),
                              initiallyExpanded: true,
                              tilePadding: EdgeInsets.zero,
                              expandedAlignment: Alignment.centerLeft,
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              leading: faIcon(FontAwesomeIcons.server),
                              title: Text(server['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    fontSize: 16,
                                  )),
                              subtitle: Text('Version: ${vars['version']}'),
                              children: [
                                const Divider(),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Center(
                                        child: faIcon(FontAwesomeIcons.plug,
                                            size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Status: '),
                                    Text(
                                      server['status'],
                                      style: TextStyle(
                                        color: server['status'] == 'ONLINE'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(children: [
                                  SizedBox(
                                    width: 24,
                                    child: Center(
                                        child: faIcon(FontAwesomeIcons.clock,
                                            size: 16)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Uptime: '),
                                  Builder(
                                    builder: (context) {
                                      final isoTimestamp = info['os']['uptime'];
                                      final dateTime =
                                          DateTime.tryParse(isoTimestamp);
                                      if (dateTime == null) {
                                        return Text('Unknown');
                                      }
                                      final duration =
                                          DateTime.now().difference(dateTime);
                                      String formatted;
                                      if (duration.inDays > 0) {
                                        formatted =
                                            '${duration.inDays} days ${duration.inHours % 24} hours';
                                      } else if (duration.inHours > 0) {
                                        formatted =
                                            '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                                      } else {
                                        formatted =
                                            '${duration.inMinutes} minutes';
                                      }
                                      return Text(formatted);
                                    },
                                  ),
                                ]),
                                const SizedBox(height: 3),
                                Row(children: [
                                  SizedBox(
                                    width: 24,
                                    child: Center(
                                      child: faIcon(
                                          FontAwesomeIcons.networkWired,
                                          size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Lan IP: '),
                                  Text(server['lanip']),
                                ]),
                                const SizedBox(height: 8),
                              ])
                        ])));
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showArrayCard() {
    return FutureBuilder<QueryResult>(
        future: _arrayCard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final array = snapshot.data!.data!['array'];

            //Total size in TB
            double size = array['capacity']['kilobytes']['total'] != null
                ? double.tryParse(array['capacity']['kilobytes']['total']
                            .toString()) !=
                        null
                    ? double.parse(array['capacity']['kilobytes']['total']
                            .toString()) /
                        1024 /
                        1024 /
                        1024
                    : 0
                : 0;
            double sizeTB = double.parse(size.toStringAsFixed(2));
            //Used size in TB
            double used = array['capacity']['kilobytes']['used'] != null
                ? double.tryParse(array['capacity']['kilobytes']['used']
                            .toString()) !=
                        null
                    ? double.parse(
                            array['capacity']['kilobytes']['used'].toString()) /
                        1024 /
                        1024 /
                        1024
                    : 0
                : 0;
            double fillPercent = size > 0 ? (used / size) : 0;
            double sizeUsedTB = double.parse(used.toStringAsFixed(2));

            return Card(
              elevation: 2,
              child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpansionTile(
                            shape: const Border(),
                            initiallyExpanded: true,
                            tilePadding: EdgeInsets.zero,
                            expandedAlignment: Alignment.centerLeft,
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            leading: faIcon(FontAwesomeIcons.hardDrive),
                            title: Text('Array',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1)),
                            subtitle: Row(
                              children: [
                                Text('State: '),
                                Text('${array['state']}',
                                    style: TextStyle(
                                      color: array['state'] == 'STARTED'
                                          ? Colors.green
                                          : Colors.red,
                                    )),
                              ],
                            ),
                            children: [
                              const Divider(),
                              const SizedBox(height: 6),
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(children: [
                                Expanded(
                                    child: LinearProgressIndicator(
                                        value: fillPercent,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          fillPercent > 0.85
                                              ? Colors.red
                                              : fillPercent > 0.65
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ))),
                                const SizedBox(width: 12),
                                Text(
                                  '${(fillPercent * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ]),
                              const SizedBox(height: 2),
                              Text('$sizeUsedTB TB / $sizeTB TB'),
                              const SizedBox(height: 8),
                                GestureDetector(
                                onTap: () {
                                  setState(() {
                                  _showMoreArrayDetails =
                                    !_showMoreArrayDetails;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Icon(
                                    _showMoreArrayDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _showMoreArrayDetails ? 'less' : 'more',
                                    style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ],
                                ),
                                ),
                              if (_showMoreArrayDetails) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Disks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: List.generate(
                                          array['disks'].length,
                                          (index) {
                                            final disk = array['disks'][index];
                                            double total = disk['fsSize'] !=
                                                    null
                                                ? double.tryParse(disk['fsSize']
                                                        .toString()) ??
                                                    0
                                                : 0;
                                            double used = disk['fsUsed'] != null
                                                ? double.tryParse(disk['fsUsed']
                                                        .toString()) ??
                                                    0
                                                : 0;
                                            double percent =
                                                total > 0 ? (used / total) : 0;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    disk['name'] ?? 'Unknown',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: percent,
                                                      minHeight: 8,
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        percent > 0.85
                                                            ? Colors.red
                                                            : percent > 0.65
                                                                ? Colors.orange
                                                                : Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${(used / 1024 / 1024 / 1024).toStringAsFixed(2)} / ${(total / 1024 / 1024 / 1024).toStringAsFixed(2)} TB',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Caches',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                            children: List.generate(
                                      array['caches'].length,
                                      (index) {
                                        final cache = array['caches'][index];
                                        double total = cache['fsSize'] != null
                                            ? double.tryParse(cache['fsSize']
                                                    .toString()) ??
                                                0
                                            : 0;
                                        double used = cache['fsUsed'] != null
                                            ? double.tryParse(cache['fsUsed']
                                                    .toString()) ??
                                                0
                                            : 0;
                                        double percent =
                                            total > 0 ? (used / total) : 0;
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Row(children: [
                                              Text(
                                                cache['name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: LinearProgressIndicator(
                                                  value: percent,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    percent > 0.85
                                                        ? Colors.red
                                                        : percent > 0.65
                                                            ? Colors.orange
                                                            : Colors.green,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${(used / 1024 / 1024 / 1024).toStringAsFixed(2)} / ${(total / 1024 / 1024 / 1024).toStringAsFixed(2)} TB',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ]));
                                      },
                                    ))),
                                  ],
                                )
                              ],
                              const SizedBox(height: 8),
                            ]),
                      ])),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showInfoCard() {
    return FutureBuilder<QueryResult>(
        future: _infoCard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final info = snapshot.data!.data!['info'];
            final metrics = snapshot.data!.data!['metrics'];

            return Card(
                elevation: 2,
                child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ExpansionTile(
                        expandedAlignment: Alignment.centerLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        shape: const Border(),
                        initiallyExpanded: true,
                        tilePadding: EdgeInsets.zero,
                        leading: faIcon(FontAwesomeIcons.microchip),
                        title: Text('System',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1)),
                        subtitle: Text('Infos'),
                        children: [
                          Divider(),
                          const SizedBox(height: 6),
                          Text(
                            'CPU: ${info['cpu']['manufacturer']}, ${info['cpu']['brand']}',
                            textAlign: TextAlign.left,
                          ),
                          Text(
                              'Cores: ${info['cpu']['cores']}, Threads: ${info['cpu']['threads']}'),
                          Text(
                              'Load: ${double.parse(metrics['cpu']['percentTotal'].toString()).toStringAsFixed(2)} %'),
                          const SizedBox(height: 8),
                          Text(
                              'Baseboard: ${info['baseboard']['manufacturer']}, ${info['baseboard']['model']}'),
                          const SizedBox(height: 8),
                          Divider(),
                          Text('Memory',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          Builder(builder: (context) {
                            double total = double.tryParse(
                                        metrics['memory']['total'].toString())
                                    ?.roundToDouble() ??
                                0;
                            double totalGB =
                                (total / 1024 / 1024 / 1024).roundToDouble();
                            double available = double.tryParse(metrics['memory']
                                            ['available']
                                        .toString())
                                    ?.roundToDouble() ??
                                0;
                            double used = (total - available).roundToDouble();
                            double usedGB =
                                (used / 1024 / 1024 / 1024).roundToDouble();
                            double percent = total > 0 ? used / total : 0;

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: LinearProgressIndicator(
                                            value: percent,
                                            minHeight: 8,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              percent > 0.85
                                                  ? Colors.red
                                                  : percent > 0.65
                                                      ? Colors.orange
                                                      : Colors.green,
                                            ))),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${(percent * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$usedGB GB / $totalGB GB',
                                  ),
                                ]);
                          }),
                          const SizedBox(height: 8),
                        ])));
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showParityCard() {
    return FutureBuilder<QueryResult>(
        future: _parityCard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final parityHistories = snapshot.data!.data!['parityHistory'];
            final parityHistory =
                parityHistories.isNotEmpty ? parityHistories[0] : null;
            if (parityHistory == null) {
              return const SizedBox.shrink();
            }
            return Card(
              elevation: 2,
              child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: ExpansionTile(
                      expandedAlignment: Alignment.centerLeft,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      shape: const Border(),
                      initiallyExpanded: false,
                      tilePadding: EdgeInsets.zero,
                      leading: faIcon(FontAwesomeIcons.heartPulse),
                      title: Text('Parity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          )),
                      subtitle: Row(children: [
                        Text('Status: '),
                        Text('${parityHistory['status']}',
                            style: TextStyle(
                              color: parityHistory['status'] == 'OK' ||
                                      parityHistory['status'] == 'COMPLETED'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            )),
                      ]),
                      children: [
                        Divider(),
                        const SizedBox(height: 6),
                        Row(children: [
                          SizedBox(
                            width: 24,
                            child: Center(
                                child: faIcon(FontAwesomeIcons.calendar,
                                    size: 16)),
                          ),
                          const SizedBox(width: 8),
                          Text('Last check: '),
                          Builder(
                            builder: (context) {
                              final isoTimestamp = parityHistory?['date'];
                              final dateTime = DateTime.tryParse(isoTimestamp);
                              if (dateTime == null) {
                                return Text('Unknown');
                              }
                              final formattedDate =
                                  '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - '
                                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                              return Text(formattedDate);
                            },
                          )
                        ]),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Center(
                                  child:
                                      faIcon(FontAwesomeIcons.clock, size: 16)),
                            ),
                            const SizedBox(width: 8),
                            Text('Duration: '),
                            Builder(
                              builder: (context) {
                                final duration = Duration(
                                    seconds: parityHistory?['duration']);
                                return Text(duration.inHours > 0
                                    ? '${duration.inHours}h ${duration.inMinutes % 60}m'
                                    : '${duration.inMinutes}m ${duration.inSeconds % 60}s');
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Center(
                                  child: faIcon(
                                      FontAwesomeIcons.triangleExclamation,
                                      size: 16)),
                            ),
                            const SizedBox(width: 8),
                            Text('Errors: '),
                            Text(parityHistory?['errors'].toString() ?? '0')
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Center(
                                  child: faIcon(FontAwesomeIcons.gaugeHigh,
                                      size: 16)),
                            ),
                            const SizedBox(width: 8),
                            Text('Speed: '),
                            Text(
                              (double.tryParse(
                                          parityHistory?['speed']?.toString() ??
                                              '0')! /
                                      1024 /
                                      1024)
                                  .toStringAsFixed(2),
                            ),
                            Text(' MB/s')
                          ],
                        ),
                        const SizedBox(height: 8),
                      ])),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showUpsCard() {
    return FutureBuilder<QueryResult>(
        future: _upsCard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final upsDevices = snapshot.data!.data!['upsDevices'];
            if (upsDevices.isEmpty) {
              return const SizedBox.shrink();
            }
            return Card(
                elevation: 2,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: ExpansionTile(
                        expandedAlignment: Alignment.centerLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        shape: const Border(),
                        initiallyExpanded: false,
                        tilePadding: EdgeInsets.zero,
                        leading: faIcon(FontAwesomeIcons.batteryThreeQuarters),
                        title: Text('UPS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1)),
                        subtitle: Text('Devices'),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(upsDevices.length, (index) {
                              final device = upsDevices[index];
                              final battery = device['battery'];
                              final power = device['power'];
                              return Builder(
                                builder: (context) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index > 0) ...[
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      device['name'] ??
                                          device['model'] ??
                                          'Unknown Model',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          child: Center(
                                              child: faIcon(
                                                  FontAwesomeIcons.plug,
                                                  size: 16)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Status: '),
                                        Text(
                                          device['status'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: device['status'] == 'ONLINE'
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          child: Center(
                                              child: faIcon(
                                                  FontAwesomeIcons.batteryFull,
                                                  size: 16)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Battery: '),
                                        Text(
                                            '${battery?['chargeLevel'] ?? '-'}%'),
                                        const SizedBox(width: 4),
                                        Text(
                                            'Health: ${battery?['health'] ?? '-'}'),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          child: Center(
                                              child: faIcon(
                                                  FontAwesomeIcons.bolt,
                                                  size: 16)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Voltage '),
                                        Text(
                                            'In: ${power?['inputVoltage'] ?? '-'} V'),
                                        const SizedBox(width: 4),
                                        Text(
                                            'Out: ${power?['outputVoltage'] ?? '-'} V'),
                                        const SizedBox(width: 4),
                                        Text(
                                            'Load: ${power?['loadPercentage'] ?? '-'}%'),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                        ])));
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showNotificationsButton() {
    return FutureBuilder<QueryResult>(
        future: _unreadNotifications,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => navigateNotifications());
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;
            int unreadTotalCount =
                result.data!['notifications']['overview']['unread']['total'];

            return IconButton(
                onPressed: () => navigateNotifications(),
                icon: unreadTotalCount > 0
                    ? Badge(
                        smallSize: 10,
                        largeSize: 10,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.notifications),
                      )
                    : Icon(Icons.notifications));
          } else {
            return IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => getNotifications());
          }
        });
  }

  Widget faIcon(IconData icon, {double? size}) {
    return FaIcon(
      icon,
      color: _theme!.isDarkMode ? Colors.orange : Colors.black,
      size: size,
    );
  }
}
