import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:my_employee_manager/screens/wrapper.dart';
import 'package:my_employee_manager/services/auth.dart';
import 'package:provider/provider.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => BoardUsers()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
