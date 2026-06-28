import 'package:flutter/material.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton_container.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Container(
            color: const Color(0xFFC8102E),
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 52, AppSpacing.md, 28),
            child: Row(
              children: [
                const SkeletonContainer(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonContainer(width: 60, height: 12),
                      SizedBox(height: 4),
                      SkeletonContainer(width: 120, height: 16),
                    ],
                  ),
                ),
                SkeletonContainer(width: 50, height: 30, borderRadius: 8),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkin Card Skeleton
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SkeletonContainer(height: 40, borderRadius: 8),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SkeletonContainer(width: 100, height: 14),
                          SkeletonContainer(width: 80, height: 20, borderRadius: 10),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(child: SkeletonContainer(height: 60, borderRadius: 10)),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonContainer(height: 60, borderRadius: 10)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                const SkeletonContainer(width: 150, height: 20),
                const SizedBox(height: AppSpacing.sm),

                // Stats Skeleton (2x2 grid based on reference design)
                Row(
                  children: [
                    const Expanded(child: SkeletonContainer(height: 72, borderRadius: 12)),
                    const SizedBox(width: 8),
                    const Expanded(child: SkeletonContainer(height: 72, borderRadius: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: SkeletonContainer(height: 72, borderRadius: 12)),
                    const SizedBox(width: 8),
                    const Expanded(child: SkeletonContainer(height: 72, borderRadius: 12)),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                const SkeletonContainer(width: 180, height: 20),
                const SizedBox(height: AppSpacing.sm),

                // Recent List Skeleton
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SkeletonContainer(height: 60, borderRadius: 12),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
