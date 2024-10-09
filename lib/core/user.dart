import "package:acqua/utils.dart";

class User {
  User({
    required this.name, 
    //required this.password, 
    required this.createdAt, 
    required this.lastLoginAt
  });

  String name;
  //String password;
  DateTime createdAt;
  //DateTime modifiedAt;
  DateTime lastLoginAt;
  
}
