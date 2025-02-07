import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_verialma_1/model/user_model.dart';
import 'package:flutter_verialma_1/service/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('tr', 'TR')],
      path: 'assets/lang/',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    String? langCode = await _storage.read(key: 'language_code');
    String? countryCode = await _storage.read(key: 'country_code');
    if (langCode != null && countryCode != null) {
      setState(() {
        _selectedLocale = Locale(langCode, countryCode);
      });
    }
  }

  void _setLanguage(Locale locale) async {
    await _storage.write(key: 'language_code', value: locale.languageCode);
    await _storage.write(key: 'country_code', value: locale.countryCode);
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "flutter_uygulama_ornek",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: _selectedLocale ?? context.locale,
      home: _selectedLocale == null
          ? LanguageSelectionScreen(onLanguageSelected: _setLanguage)
          : HomeScreen(),
    );
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  const LanguageSelectionScreen({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 220, 240),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                onLanguageSelected(Locale('en', 'US'));
                context.setLocale(Locale('en', 'US'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 35, 65), //
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), //
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), //
              ),
              child: Text('English',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onLanguageSelected(Locale('tr', 'TR'));
                context.setLocale(Locale('tr', 'TR'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 35, 65), //
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), //
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), //
              ),
              child: Text('Türkçe',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _service = UserService();
  bool isLoading = false;
  List<UsersModelData?> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    final value = await _service.fetchUsers();
    setState(() {
      isLoading = false;
      if (value?.data != null) {
        users = value!.data!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('user_list'.tr()),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 170, 220, 240),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("loading".tr()),
                      ],
                    ),
                  )
                : users.isNotEmpty
                    ? ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                "${users[index]?.firstName} ${users[index]?.lastName}"),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(users[index]?.avatar ?? ''),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserDetailPage(user: users[index]!),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Center(child: Text("no_users_found".tr())),
          ),
        ],
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
        title: Text("user_detail".tr()),
        backgroundColor: const Color.fromARGB(255, 170, 220, 240),
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
            Text("${'name'.tr()}: ${user.firstName} ${user.lastName}",
                style: const TextStyle(fontSize: 22)),
            Text("${'email'.tr()}: ${user.email}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
