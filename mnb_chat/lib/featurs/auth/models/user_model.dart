// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String name;
  final String phoneNamber;
  final String token;
  String? imgUrl;

  UserModel({
    required this.name,
    required this.phoneNamber,
    required this.token,
    this.imgUrl,
  });
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        token: map['token'],
        imgUrl: map['imgUrl'],
        name: map['name'],
        phoneNamber: map['number']);
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': phoneNamber,
      'token': token,
      'imgUrl': imgUrl ?? ''
    };
  }
}
