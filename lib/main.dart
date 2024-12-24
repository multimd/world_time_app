import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const WorldTimeApp());
}

class WorldTimeApp extends StatelessWidget {
  const WorldTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WorldTimePage(),
    );
  }
}

class WorldTimePage extends StatefulWidget {
  const WorldTimePage({super.key});

  @override
  State<WorldTimePage> createState() => _WorldTimePageState();
}

class _WorldTimePageState extends State<WorldTimePage> {
  late Timer _timer;
  bool _is24HourFormat = true;
  bool _showDates = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, Duration> _cityOffsets = {
    'Boston': const Duration(hours: -5), // EST
    'London': const Duration(hours: 0),  // GMT
    'Madrid': const Duration(hours: 1),  // CET
    'Seoul': const Duration(hours: 9),   // KST
    'Los Angeles': const Duration(hours: -8), // PST
    'Minneapolis': const Duration(hours: -6), // CST
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _getTimeForCity(String cityName) {
    final now = DateTime.now().toUtc();
    final offset = _cityOffsets[cityName]!;
    final cityTime = now.add(offset);
    final timeFormat = _is24HourFormat ? 'HH:mm:ss' : 'hh:mm:ss a';
    final dateFormat = 'MMM d, yyyy';
    
    if (_showDates) {
      return '${DateFormat(dateFormat).format(cityTime)}\n${DateFormat(timeFormat).format(cityTime)}';
    } else {
      return DateFormat(timeFormat).format(cityTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCities = _cityOffsets.keys.toList()
      ..sort((a, b) => _cityOffsets[a]!.compareTo(_cityOffsets[b]!));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('World Time'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thickness: 8.0,
              radius: const Radius.circular(4.0),
              thumbVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _cityOffsets.length,
                itemBuilder: (context, index) {
                  final cityName = sortedCities[index];
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            cityName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _getTimeForCity(cityName),
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _is24HourFormat = !_is24HourFormat;
                      });
                    },
                    icon: Icon(_is24HourFormat ? Icons.access_time : Icons.access_time_filled),
                    label: Text(_is24HourFormat ? '24-hour' : '12-hour'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showDates = !_showDates;
                      });
                    },
                    icon: Icon(_showDates ? Icons.calendar_month : Icons.calendar_today),
                    label: Text(_showDates ? 'Hide Date' : 'Show Date'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
