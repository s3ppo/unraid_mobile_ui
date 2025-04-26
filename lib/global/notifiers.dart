import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:unmobile/notifiers/auth_state.dart';

List<SingleChildWidget> providers = [ChangeNotifierProvider(create: (context) => AuthState())];
