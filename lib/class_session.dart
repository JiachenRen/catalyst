class ClassSession {
  int id;

  String get url =>
      'https://learningcatalytics.com/class_sessions/join?class_session_id=$id';
  String name;

  ClassSession(this.id, {this.name});

  @override
  String toString() {
    return name ?? id;
  }
}
