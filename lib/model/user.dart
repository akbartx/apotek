class User {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String? photoUrl;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.photoUrl,
  });

  // Konstruktor default untuk Firebase
  User.fromData(Map<String, dynamic> data)
      : username = data['username'] ?? '',
        email = data['email'] ?? '',
        password = data['password'] ?? '',
        confirmPassword = data['confirmPassword'] ?? '',
        photoUrl = data['photoUrl'];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() {
    return 'User{username: $username, email: $email, password: $password, confirmPassword: $confirmPassword, photoUrl: $photoUrl}';
  }
}
