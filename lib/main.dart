import 'package:flutter/material.dart';
import 'package:flutter_verialma_1/model/user_model.dart';
import 'package:flutter_verialma_1/service/user_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppsState();
}

class _MyAppsState extends State<MyApp> {
  final UserService _service = UserService();
  bool? isLoading;
  List<UsersModelData?> users = [];

  @override
  void initState() {
    super.initState();
    _service.fetchUsers().then((value) {
      if (value != null && value.data != null) {
        setState(() {
          users = value.data!;
          isLoading = true;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "'GET' isteği deneme uygulaması",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Kullanıcı Listesi'),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
          centerTitle: true,
          backgroundColor: Colors.greenAccent,
        ),
        body: isLoading == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isLoading == true
                ? ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            "${users[index]!.firstName!}  ${users[index]!.lastName!}"),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(users[index]!.avatar!),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailPage(user: users[index]!)),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text("Üzgünüm bir sorun oluştu")),
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final UsersModelData user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.firstName} ${user.lastName}"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.avatar!),
            ),
            const SizedBox(height: 20),
            Text("Ad: ${user.firstName} ${user.lastName}",
                style: const TextStyle(fontSize: 22)),
            Text("e-posta: ${user.email}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
