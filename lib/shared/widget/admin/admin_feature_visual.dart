import 'package:flutter/material.dart';

class AdminFeatureVisual extends StatelessWidget {
  final Map<String, dynamic> data;

  const AdminFeatureVisual({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color;

    return Center(
      child: Container(
        width: 320,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Simple, static shadow (cheap to render)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Browser Header
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  _windowDot(const Color(0xFFFF5F57)),
                  const SizedBox(width: 8),
                  _windowDot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 8),
                  _windowDot(const Color(0xFF28C840)),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.1),
                    ),
                    child: Icon(data['icon'], size: 50, color: color),
                  ),
                  const SizedBox(height: 24),
                  _skeletonLine(width: 120, color: Colors.grey.shade200),
                  const SizedBox(height: 10),
                  _skeletonLine(width: 180, color: Colors.grey.shade100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _windowDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _skeletonLine({required double width, required Color color}) =>
      Container(
        width: width,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}
