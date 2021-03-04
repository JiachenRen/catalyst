import 'dart:io';

class Credential {
  final String username;

  final String password;

  final String clientId;

  static const String _filePath = 'user_data/credentials';

  Credential({this.username, this.password, this.clientId});

  Future save() {
    return File(_filePath).create().then((file) {
      return file.writeAsString('$username\n$password\n$clientId');
    });
  }

  static Future<Credential> load() {
    if (!File(_filePath).existsSync()) {
      throw 'Credential does not exist';
    }
    return File(_filePath).readAsString().then((value) {
      var lines = value.split('\n');
      return Credential(username: lines[0], password: lines[1], clientId: lines[2]);
    });
  }

  @override
  String toString() {
    return 'Credential{username: $username, password: $password, clientId: $clientId}';
  }
}
