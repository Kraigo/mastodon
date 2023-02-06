import 'package:flutter/material.dart';
import 'package:mastodon/base/database.dart';
import 'package:mastodon/base/routes.dart';
import 'package:mastodon/providers/authorization_provider.dart';
import 'package:mastodon/widgets/widgets.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    Future.microtask(_loadInitial);
    super.initState();
  }

  _loadInitial() async {
    await context.read<AuthorizationProvider>().verifyAccount();
  }

  _onLogout() {
    Navigator.of(context).pushNamed(Routes.logout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Column(
        children: [
          StreamBuilder(
              stream:
                  context.read<AppDatabase>().accountDao.findCurrentAccount(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return Container();
                return AccountCard(snapshot.data!);
              }),
          ElevatedButton(onPressed: _onLogout, child: Text("Logout")),
        ],
      ),
    );
  }
}