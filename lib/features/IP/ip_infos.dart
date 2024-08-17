import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class IPInfoScreen extends StatefulWidget {
  const IPInfoScreen({super.key});

  @override
  State<IPInfoScreen> createState() => _IPInfoScreenState();
}

class _IPInfoScreenState extends State<IPInfoScreen> {
  String _ipAddress = '';
  String _location = '';
  String _ipInfo = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP and Location Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _fetchIPInfo,
              child: const Text('Fetch IP and Location Info'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IP Address: $_ipAddress'),
                      const SizedBox(height: 10),
                      Text('Location: $_location'),
                      const SizedBox(height: 10),
                      Text('IP Information: $_ipInfo'),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchIPInfo() async {
    setState(() {
      _isLoading = true;
    });

    await _getIPAddress();
    await _getLocation();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getIPAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.techniknews.net/ipgeo'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ipAddress = data['ip'];
          _ipInfo = data.toString();
        });
      } else {
        setState(() {
          _ipInfo = 'Failed to load IP information';
        });
      }
    } catch (e) {
      setState(() {
        _ipInfo = 'Error: $e';
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _location = 'Error: $e';
      });
    }
  }
}
