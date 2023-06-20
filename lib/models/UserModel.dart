// ignore_for_file: file_names

class UserModel {
  String uid;
  String fullName;
  String email;
  String? profile;
  // String password;
  String role;
  UserModel({
    required this.uid,
    required this.fullName,
    this.profile =
        'https://www.cornwallbusinessawards.co.uk/wp-content/uploads/2017/11/dummy450x450.jpg',
    required this.email,
    // required this.password,
    required this.role,
  });
}
