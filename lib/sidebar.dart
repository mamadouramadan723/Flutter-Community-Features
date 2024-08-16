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
            accountName: Text(
              'ML Kit APIs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('flutter_mlkit@example.com'),
            currentAccountPicture: CircleAvatar(
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
                image: AssetImage(
                    'assets/myLogo.png'), // Add a background image
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.video_collection_outlined),
            title: Text('Video Reader'),
            onTap: () {
              Navigator.pushNamed(context, '/video_reader');
            },
          ),

          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.pushNamed(context, '/help_support');
            },
          ),
        ],
      ),
    );
  }
}