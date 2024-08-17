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
  String _ipInfo = '';
  bool _isLoading = true;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _gpsLatitude = 0.0;
  double _gpsLongitude = 0.0;

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
                    _buildSectionTitle('IP Address'),
                    _buildInfoCard(content: _ipAddress),
                    const SizedBox(height: 20),
                    _buildSectionTitle('GPS Coordinates'),
                    _buildInfoCard(
                        content:
                            'Latitude: $_gpsLatitude\nLongitude: $_gpsLongitude'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('IP-Based Coordinates'),
                    _buildInfoCard(
                        content:
                            'Latitude: $_latitude\nLongitude: $_longitude'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('IP Information'),
                    _buildInfoCard(content: _ipInfo),
                    const SizedBox(height: 30),
                    _buildMapButton(
                      'Open GPS Location in Maps',
                      useGPS: true,
                    ),
                    const SizedBox(height: 10),
                    _buildMapButton(
                      'Open IP Location in Maps',
                      useGPS: false,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildInfoCard({required String content}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMapButton(String label, {required bool useGPS}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleMapButtonClick(useGPS: useGPS),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(label),
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
    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _gpsLatitude = position.latitude;
        _gpsLongitude = position.longitude;
      });
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _handleMapButtonClick({required bool useGPS}) async {
    if (useGPS) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationActivationDialog();
      } else {
        _openMap(useGPS: true);
      }
    } else {
      _openMap(useGPS: false);
    }
  }

  void _showLocationActivationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable GPS'),
          content: const Text('Please enable GPS to use this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  void _openMap({required bool useGPS}) async {
    try {
      final double latitude = useGPS ? _gpsLatitude : _latitude;
      final double longitude = useGPS ? _gpsLongitude : _longitude;

      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

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
