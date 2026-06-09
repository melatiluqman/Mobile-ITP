class AppConstants {
  // Emulator Android  : 'http://10.0.2.2:8000/api'
  // Device fisik      : ganti dengan IP komputer, contoh 'http://192.168.1.10:8000/api'
  // Production        : 'https://yourdomain.com/api'
  static const String baseUrl = 'http://192.168.1.47:8000/api';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Sesuaikan dengan baseUrl di atas
  static const String storageBaseUrl = 'http://192.168.1.47:8000/storage/';

  static const List<String> roles = ['admin', 'admin_galangan', 'yard', 'class', 'os', 'stat'];

  static const Map<String, String> roleLabels = {
    'admin': 'Super Admin',
    'admin_galangan': 'Admin Galangan',
    'yard': 'Yard',
    'class': 'Class',
    'os': 'OS',
    'stat': 'Stat',
  };
}
