class AuthService {
  // key: nim, value: map with keys: name, password, faculty, program
  static final Map<String, Map<String, String>> _users = {};

  /// Register a new user. Returns false if nim already exists.
  static Future<bool> register({
    required String nim,
    required String name,
    required String password,
    String? faculty,
    String? program,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_users.containsKey(nim)) return false;
    _users[nim] = {
      'name': name,
      'password': password,
      'faculty': faculty ?? '',
      'program': program ?? '',
    };
    return true;
  }

  /// Authenticate by nim + password
  static Future<bool> authenticate({
    required String nim,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = _users[nim];
    if (user == null) return false;
    return user['password'] == password;
  }

  /// For debugging: list users
  static Map<String, Map<String, String>> get users => _users;
}
