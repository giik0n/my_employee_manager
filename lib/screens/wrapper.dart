import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/screens/authenticate/authenticate.dart';
import 'package:my_employee_manager/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    //return either Home or Login
    return user == null ? Authenticate() : Home(user: user);
  }
}
