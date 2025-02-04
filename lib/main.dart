import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:typed_data';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ArduinoLEDControl(),
  ));
}

class ArduinoLEDControl extends StatefulWidget {
  const ArduinoLEDControl({super.key});

  @override
  _ArduinoLEDControlState createState() => _ArduinoLEDControlState();
}

class _ArduinoLEDControlState extends State<ArduinoLEDControl> {
  UsbPort? _port;
  String _status = "Disconnected";
  bool _isLedOn = false;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _connectToArduino();
  }

  Future<void> _connectToArduino() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print("Found ${devices.length} USB devices");

    if (devices.isEmpty) {
      setState(() {
        _status = "No door found";
      });
      return;
    }

    try {
      UsbPort? port = await devices[0].create();
      if (port == null) {
        setState(() {
          _status = "Failed to create port";
        });
        return;
      }

      bool openResult = await port.open();
      if (!openResult) {
        setState(() {
          _status = "Failed to open port";
        });
        return;
      }

      await port.setDTR(true);
      await port.setRTS(true);
      await port.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      setState(() {
        _port = port;
        _status = "Connected";
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }

  Future<void> _authenticateAndToggleLED() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to control the LED',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        _toggleLED();
      } else {
        setState(() {
          _status = "Authentication failed";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Authentication error: $e";
      });
    }
  }

  void _toggleLED() async {
    if (_port == null) {
      setState(() {
        _status = "Arduino not connected";
      });
      return;
    }

    try {
      setState(() {
        _isLedOn = !_isLedOn;
      });

      String command = _isLedOn ? "1" : "0";
      await _port!.write(Uint8List.fromList(command.codeUnits));

      setState(() {
        _status = "Door is ${_isLedOn ? 'unlocked' : 'locked'}.";
      });
    } catch (e) {
      setState(() {
        _status = "Failed to send command: $e";
        _isLedOn = !_isLedOn; // Revert state if failed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Door Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _connectToArduino,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection Status
            Container(
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  Text("23BEC1146 - T.S. Kaushal"),
                  Text("23BEC1206 - Anant Kumar Singh"),
                  Text("23BEC1212 - Arsh Saxena"),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _port != null ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _port != null ? Icons.usb : Icons.usb_off,
                    color: _port != null ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(_status),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // LED Control Button with Authentication
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: _isLedOn ? Colors.yellow : Colors.grey,
              ),
              onPressed: _port != null ? _authenticateAndToggleLED : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_isLedOn ? Icons.lightbulb : Icons.lightbulb_outline),
                  const SizedBox(width: 8),
                  Text(_isLedOn ? 'Lock' : 'Unlock'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _port?.close();
    super.dispose();
  }
}
