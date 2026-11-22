class User {
  final String _name;
  final String _phone;
  final String _passwordHash;
  final String _salt;

  User({
    required String name,
    required String phone,
    required String passwordHash,
    required String salt,
  })  : _name = name,
        _phone = phone,
        _passwordHash = passwordHash,
        _salt = salt;

  String get name => _name;
  String get phone => _phone;
  String get passwordHash => _passwordHash;
  String get salt => _salt;

  String get role => 'player';

  Map<String, dynamic> toMap() => {
    'name': _name,
    'phone': _phone,
    'passwordHash': _passwordHash,
    'salt': _salt,
    'role': role,
  };

  factory User.fromMap(Map<String, dynamic> map) {
    if (map['role'] == 'admin') {
      return AdminUser(
        name: map['name'],
        phone: map['phone'],
        passwordHash: map['passwordHash'],
        salt: map['salt'],
      );
    }
    return User(
      name: map['name'],
      phone: map['phone'],
      passwordHash: map['passwordHash'],
      salt: map['salt'],
    );
  }
}

class AdminUser extends User {
  AdminUser({
    required super.name,
    required super.phone,
    required super.passwordHash,
    required super.salt,
  });

  @override
  String get role => 'admin';
}