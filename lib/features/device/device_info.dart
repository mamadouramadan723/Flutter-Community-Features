import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
              _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
              _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
              _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
            'Error:': 'Fuchsia platform isn\'t supported'
          },
        };
      }
    } on PlatformException catch (e) {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version. $e'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'SDK Version': build.version.sdkInt,
      'Release Version': build.version.release,
      'Incremental Version': build.version.incremental,
      'Codename': build.version.codename,
      'Base OS': build.version.baseOS,
      'Board': build.board,
      'Bootloader': build.bootloader,
      'Brand': build.brand,
      'Device': build.device,
      'Display': build.display,
      'Fingerprint': build.fingerprint,
      'Hardware': build.hardware,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
      'Product': build.product,
      'Supported 32-bit ABIs': build.supported32BitAbis,
      'Supported 64-bit ABIs': build.supported64BitAbis,
      'Supported ABIs': build.supportedAbis,
      'Tags': build.tags,
      'Type': build.type,
      'Is Physical Device': build.isPhysicalDevice,
      'System Features': build.systemFeatures,
      'Serial Number': build.serialNumber,
      'Build ID': build.id,
      'Is Low RAM Device': build.isLowRamDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'System Name': data.systemName,
      'System Version': data.systemVersion,
      'Model': data.model,
      'Localized Model': data.localizedModel,
      'Identifier For Vendor': data.identifierForVendor,
      'Is Physical Device': data.isPhysicalDevice,
      'UTS Name Sysname': data.utsname.sysname,
      'UTS Name Nodename': data.utsname.nodename,
      'UTS Name Release': data.utsname.release,
      'UTS Name Version': data.utsname.version,
      'UTS Name Machine': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'Version': data.version,
      'ID': data.id,
      'ID Like': data.idLike,
      'Version Codename': data.versionCodename,
      'Version ID': data.versionId,
      'Pretty Name': data.prettyName,
      'Build ID': data.buildId,
      'Variant': data.variant,
      'Variant ID': data.variantId,
      'Machine ID': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'Browser Name': data.browserName.name,
      'App Code Name': data.appCodeName,
      'App Name': data.appName,
      'App Version': data.appVersion,
      'Device Memory': data.deviceMemory,
      'Language': data.language,
      'Languages': data.languages,
      'Platform': data.platform,
      'Product': data.product,
      'Product Sub': data.productSub,
      'User Agent': data.userAgent,
      'Vendor': data.vendor,
      'Vendor Sub': data.vendorSub,
      'Hardware Concurrency': data.hardwareConcurrency,
      'Max Touch Points': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'Computer Name': data.computerName,
      'Host Name': data.hostName,
      'Architecture': data.arch,
      'Model': data.model,
      'Kernel Version': data.kernelVersion,
      'Major Version': data.majorVersion,
      'Minor Version': data.minorVersion,
      'Patch Version': data.patchVersion,
      'OS Release': data.osRelease,
      'Active CPUs': data.activeCPUs,
      'Memory Size': data.memorySize,
      'CPU Frequency': data.cpuFrequency,
      'System GUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'Number of Cores': data.numberOfCores,
      'Computer Name': data.computerName,
      'System Memory (MB)': data.systemMemoryInMegabytes,
      'User Name': data.userName,
      'Major Version': data.majorVersion,
      'Minor Version': data.minorVersion,
      'Build Number': data.buildNumber,
      'Platform ID': data.platformId,
      'CSD Version': data.csdVersion,
      'Service Pack Major': data.servicePackMajor,
      'Service Pack Minor': data.servicePackMinor,
      'Suit Mask': data.suitMask,
      'Product Type': data.productType,
      'Reserved': data.reserved,
      'Build Lab': data.buildLab,
      'Build Lab Ex': data.buildLabEx,
      'Digital Product ID': data.digitalProductId,
      'Display Version': data.displayVersion,
      'Edition ID': data.editionId,
      'Install Date': data.installDate,
      'Product ID': data.productId,
      'Product Name': data.productName,
      'Registered Owner': data.registeredOwner,
      'Release ID': data.releaseId,
      'Device ID': data.deviceId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4376F8),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          elevation: 4,
          backgroundColor: const Color(0xFF4376F8),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: _deviceData.keys.map(
                (String property) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: Icon(
                    Icons.info,
                    color: Colors.blue.shade700,
                  ),
                  title: Text(
                    property,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${_deviceData[property]}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  String _getAppBarTitle() => kIsWeb
      ? 'Web Browser Info'
      : switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android Device Info',
    TargetPlatform.iOS => 'iOS Device Info',
    TargetPlatform.linux => 'Linux Device Info',
    TargetPlatform.windows => 'Windows Device Info',
    TargetPlatform.macOS => 'MacOS Device Info',
    TargetPlatform.fuchsia => 'Fuchsia Device Info',
  };
}