class NewUser {
  NewUser({
    required this.name,
    required this.id,
    required this.username,
    required this.password,
  });
  late final String name;
  late final String id;
  late final String username;
  late final String password;

  
  NewUser.fromJson(Map<String, dynamic> json){
    name = json['name'].toString();
    id = json['id'].toString();
    username = json['username'].toString();
    password = json['password'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    return data;
  }
}