import 'dart:convert';
import 'package:flutter_verialma_1/model/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String url = 'https://reqres.in/api/users?page=1';
  Future<UsersModel?> fetchUsers() async {
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      print("Başarılı");
      var jsonBody = UsersModel.fromJson(jsonDecode(res.body));
      return jsonBody;
    } else {
      print("Başarısız");
    }
    return null;
  }
}
