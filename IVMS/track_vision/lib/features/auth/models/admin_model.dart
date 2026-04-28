class AdminModel {
  final String? full_Name;
  final String? email;
  final String? phone_Number;
  final String? organization_Name;
  final String? organization_Code;
  final String? password;


  AdminModel({
    required this.full_Name,
    required this.email,
    required this.phone_Number,
    required this.organization_Name,
    required this.organization_Code,
    required this.password});

  factory AdminModel.fromJson(Map<String, dynamic>json){
    return AdminModel(
        full_Name: json['full_Name']?? json['Full Name'],
        email: json['email'],
        phone_Number: json['phone_Number'] ?? json['phone_number'],
        organization_Name: json['organization_Name'] ?? json['organization_name'],
        organization_Code: json['organization_Code'] ?? json['organization_code'],
        password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'full_Name' : full_Name,
    'email' : email,
    'phone_Number' : phone_Number,
    'organization_Name' : organization_Name,
    'organization_Code' : organization_Code,
  };
}
