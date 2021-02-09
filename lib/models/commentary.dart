import 'package:my_employee_manager/models/user.dart';

class Commentary {
  final String id;
  final User user;
  final String commentary;
  final DateTime createdAt;

  Commentary(this.user, this.commentary, this.createdAt, this.id);
}
