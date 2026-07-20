import 'package:flutter/material.dart';

class EmptyCarCard extends StatelessWidget {
  const EmptyCarCard({super.key, required this.onAddCar});
  final VoidCallback onAddCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0E7490).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF0E7490),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No car added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'add a car for this order if it need',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAddCar,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add car'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E7490),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}