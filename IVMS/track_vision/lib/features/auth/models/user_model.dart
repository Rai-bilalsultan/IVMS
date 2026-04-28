class UserModel {
  final int id;
  final String? full_Name;
  final String? email;
  final String? phone_Number;
  final String? cnic_Number;
  final String? password;
  final String role;

  UserModel({
    required this.id,
    this.full_Name,
    this.email,
    this.phone_Number,
    this.cnic_Number,
    this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      full_Name: json['fullName'] ?? json['full_Name'] ?? json['full_name'],
      email: json['email'],
      phone_Number:
          json['phoneNumber'] ?? json['phone_Number'] ?? json['phone_number'],
      cnic_Number:
          json['cnic'] ?? json['cnic_Number'] ?? json['Id_card-number'],
      password: json['password'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_Name': full_Name,
    'email': email,
    'phone_Number': phone_Number,
    'cnic_Number': cnic_Number,
    'password': password,
    'role': role,
  };
}
