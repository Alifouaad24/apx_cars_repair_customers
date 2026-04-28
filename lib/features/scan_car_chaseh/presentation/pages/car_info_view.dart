import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarInfoView extends StatelessWidget {
  const CarInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final Map<String, dynamic> car =
        args is Map<String, dynamic> ? args : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Information"),
        centerTitle: true,
      ),
      body: car.isEmpty
          ? const Center(
              child: Text(
                'No data returned from API',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car,
                          size: 50, color: Colors.blue),
                      const SizedBox(height: 10),
                      const Text(
                        "Car Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      ...car.entries.map(
                        (entry) => _buildRow(entry.key, entry.value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}