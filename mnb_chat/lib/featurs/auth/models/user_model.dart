class UserModel {
  final String name;
  final String email;
  final String token;
  final String password;
  String? imgUrl;

  UserModel({
    required this.password,
    required this.name,
    required this.email,
    required this.token,
    this.imgUrl,
  });
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        password: map['password'] ?? '',
        token: map['token'],
        imgUrl: map['imgUrl'],
        name: map['name'],
        email: map['email']);
  }
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'name': name,
      'email': email,
      'token': token,
      'imgUrl': imgUrl ?? ''
    };
  }
}
