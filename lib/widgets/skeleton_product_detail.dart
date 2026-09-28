import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class SkeletonProductDetail extends StatelessWidget {
  const SkeletonProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 380, borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 90, height: 12),
                const SizedBox(height: 10),
                const ShimmerBox(width: 220, height: 22),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const ShimmerBox(width: 100, height: 24),
                    const SizedBox(width: 14),
                    ShimmerBox(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const ShimmerBox(width: 130, height: 16),
                const SizedBox(height: 10),
                const ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                const ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                const ShimmerBox(width: 180, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
