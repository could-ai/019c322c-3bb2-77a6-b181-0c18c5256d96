import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartBinApp());
}

class SmartBinApp extends StatelessWidget {
  const SmartBinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bin Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isConnected = false;
  bool _isLidOpen = false;
  double _distance = 0.0;
  Timer? _simulationTimer;

  // Simulate receiving data from Arduino
  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });

    if (_isConnected) {
      // Start simulation
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (mounted) {
          setState(() {
            // Simulate random distance between 5cm and 50cm
            _distance = 5 + Random().nextInt(45).toDouble();
            
            // Auto-open logic simulation (matching Arduino logic)
            if (_distance < 20 && !_isLidOpen) {
              _isLidOpen = true;
              // Auto-close after 5 seconds simulation
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    _isLidOpen = false;
                  });
                }
              });
            }
          });
        }
      });
    } else {
      _simulationTimer?.cancel();
      setState(() {
        _distance = 0.0;
        _isLidOpen = false;
      });
    }
  }

  void _manualOpen() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to device first')),
      );
      return;
    }
    setState(() {
      _isLidOpen = true;
    });
    // In a real app, you would send 'O' character to Bluetooth here
  }

  void _manualClose() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to device first')),
      );
      return;
    }
    setState(() {
      _isLidOpen = false;
    });
    // In a real app, you would send 'C' character to Bluetooth here
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bin Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _toggleConnection,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              elevation: 2,
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error_outline,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isConnected ? "System Connected" : "Disconnected",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lid Status Visualization
            Center(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _isLidOpen ? Colors.orange.shade100 : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isLidOpen ? Colors.orange : Colors.grey,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      _isLidOpen ? Icons.delete_outline : Icons.delete,
                      size: 80,
                      color: _isLidOpen ? Colors.orange : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLidOpen ? "LID OPEN" : "LID CLOSED",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isLidOpen ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sensor Data
            const Text(
              "Sensor Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Distance Object"),
                      Text(
                        "${_distance.toStringAsFixed(1)} cm",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_distance / 50).clamp(0.0, 1.0), // Max 50cm for visual
                    backgroundColor: Colors.grey.shade200,
                    color: _distance < 20 ? Colors.red : Colors.blue,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _distance < 20 ? "Object Detected!" : "Clear",
                    style: TextStyle(
                      color: _distance < 20 ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Manual Controls
            const Text(
              "Manual Controls",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _manualOpen,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text("OPEN"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _manualClose,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text("CLOSE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
