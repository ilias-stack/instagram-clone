class User {
  static int? id, profilePictureId;
  static String? userName,
      fullName,
      email,
      description,
      password,
      accountStatus;
  static void fillInformationFields(Map<String, dynamic> data) {
    id = data["id"];
    userName = data["username"];
    fullName = data["fullname"];
    email = data['email'];
    password = data['password'];
    description = data['description'];
    profilePictureId = data['profilePictureId'];
    accountStatus = data["accountStatus"];
  }

  static void emptyInformationFields() {
    id = null;
    userName = null;
    fullName = null;
    email = null;
    password = null;
    description = null;
    profilePictureId = null;
  }

  static Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "userName": userName,
        "fullName": fullName,
        "email": email,
        "password": password,
        "description": description,
        "profilePictureId": profilePictureId
      };
}
