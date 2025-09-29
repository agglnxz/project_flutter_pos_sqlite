class User {
  final int id;
  final String fullName;
  final String  username;
  final String  email;
  final String  password;

  User({
    required this.id,
    required this.fullName,
    required this. username,
     required this. email,
     required this. password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      ' username':  username,
       ' email':  email,
        ' password':  password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
        username: map[' username'],
          email: map[' email'],
          password: map[' password'],
    );
  }
}