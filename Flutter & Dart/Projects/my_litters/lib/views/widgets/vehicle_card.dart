import 'package:flutter/material.dart';
import '../../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onRemove;

  const VehicleCard({super.key, required this.vehicle, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: vehicle.imageIndex == 1
                        ? [const Color(0xFF1A3A8A), const Color(0xFF2E5C9E)]
                        : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
                  ),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 80,
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: onRemove,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem('Manufacturer', vehicle.manufacturer),
                _buildDivider(),
                _buildInfoItem('Model', vehicle.modelDisplay),
                _buildDivider(),
                _buildInfoItem('Plate Number', vehicle.plateNumber),
                _buildDivider(),
                _buildInfoItem('Fuel', vehicle.fuelTypeLabel),
                if (vehicle.year != null) ...[
                  _buildDivider(),
                  _buildInfoItem('Year', '${vehicle.year}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
