import 'package:flutter/material.dart';
import '../../models/payment.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: payment.isPaid ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: payment.isPaid
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              payment.isPaid ? Icons.check_circle : Icons.schedule,
              color: payment.isPaid
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SAR ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A8A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: payment.isPaid
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              payment.isPaid ? 'Paid' : 'Due',
              style: TextStyle(
                color: payment.isPaid
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
