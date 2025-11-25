import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:unmobile/notifiers/theme_mode.dart';
import 'package:unmobile/notifiers/locale_notifier.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (context) => AuthState()),
  ChangeNotifierProvider(create: (context) => ThemeNotifier()),
  ChangeNotifierProvider(create: (context) => LocaleNotifier()),
];
