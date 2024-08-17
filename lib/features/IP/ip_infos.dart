import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class IPInfoScreen extends StatefulWidget {
  const IPInfoScreen({super.key});

  @override
  State<IPInfoScreen> createState() => _IPInfoScreenState();
}

class _IPInfoScreenState extends State<IPInfoScreen> {
  String _ipAddress = '';
  String _location = '';
  String _ipInfo = '';
  bool _isLoading = true;
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchIPInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP and Location Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IP Address: $_ipAddress',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('Location: $_location',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    const Text('IP Information:',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 5),
                    Text(_ipInfo, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openMap,
                      child: const Text('Open in Maps'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _fetchIPInfo() async {
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
        String formattedTimestamp = '';
        if (data['cached'] == true && data['cacheTimestamp'] != null) {
          int timestamp = data['cacheTimestamp'];
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          formattedTimestamp =
              DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
        }

        setState(() {
          _ipAddress = data['ip'];
          _latitude = data['lat'];
          _longitude = data['lon'];
          _ipInfo = '''
Status: ${data['status']}
Continent: ${data['continent']}
Country: ${data['country']} (${data['countryCode']})
Region: ${data['regionName']}
City: ${data['city']}
Zip: ${data['zip']}
Latitude: ${data['lat']}
Longitude: ${data['lon']}
Timezone: ${data['timezone']}
Currency: ${data['currency']}
ISP: ${data['isp']}
Organization: ${data['org']}
AS: ${data['as']}
Mobile: ${data['mobile']}
Proxy: ${data['proxy']}
Cached: ${data['cached']}
Cache Timestamp: $formattedTimestamp
          ''';
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

  void _openMap() async {
    try {
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude');

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {
      log('Error opening map: $e');
    }
  }
}
