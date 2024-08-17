import 'package:flutter/material.dart';
import 'package:transverse/sidebar.dart';

import 'features/IP/ip_infos.dart';
import 'features/device/device_info.dart';
import 'features/video/video_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' APIs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ML Kit APIs'),
      routes: {
        '/video_reader': (context) => const VideoPlayersScreen(),
        '/device_info': (context) => const DeviceInfoScreen(),
        '/ip_info': (context) => const IPInfoScreen(),

        // Add more routes for other features
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text('Main Page'),
      ),
      drawer: const Sidebar(),
    );
  }
}
