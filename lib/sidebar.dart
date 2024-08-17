import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text(
              'ML Kit APIs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('flutter_mlkit@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'ML',
                style: TextStyle(fontSize: 24.0, color: Colors.blue),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.blueAccent.withOpacity(0.6), BlendMode.dstATop),
                image: const AssetImage(
                    'assets/myLogo.png'), // Add a background image
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.video_collection_outlined),
            title: const Text('Video Reader'),
            onTap: () {
              Navigator.pushNamed(context, '/video_reader');
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices_sharp),
            title: const Text('Device Infos'),
            onTap: () {
              Navigator.pushNamed(context, '/device_info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices_sharp),
            title: const Text('IP Infos'),
            onTap: () {
              Navigator.pushNamed(context, '/ip_info');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pushNamed(context, '/help_support');
            },
          ),
        ],
      ),
    );
  }
}
