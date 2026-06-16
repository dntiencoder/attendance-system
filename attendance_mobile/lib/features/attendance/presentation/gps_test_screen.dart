import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/gps_provider.dart';

class GpsTestScreen extends ConsumerWidget {
  const GpsTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test GPS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trạng thái
              if (gpsState.isLoading)
                const CircularProgressIndicator()
              else if (gpsState.error != null)
                Column(
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      gpsState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                )
              else if (gpsState.position != null)
                  Column(
                    children: [
                      const Icon(Icons.location_on, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      Text('Latitude: ${gpsState.position!.latitude}'),
                      Text('Longitude: ${gpsState.position!.longitude}'),
                      Text('Accuracy: ${gpsState.position!.accuracy.toStringAsFixed(1)}m'),
                    ],
                  )
                else
                  const Icon(Icons.location_searching, size: 64, color: Colors.grey),

              const SizedBox(height: 32),

              // Nút lấy vị trí
              ElevatedButton.icon(
                onPressed: gpsState.isLoading
                    ? null
                    : () => ref.read(gpsProvider.notifier).fetchCurrentPosition(),
                icon: const Icon(Icons.my_location),
                label: const Text('Lấy vị trí hiện tại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}