import 'package:flutter/material.dart';
import '../../../utils/helper_widget.dart';

class GearImage extends StatelessWidget {
  final GearIllustration kind;
  final bool big;

  /// ถ้าอยากระบุ path เอง (เช่นรูปเฉพาะรุ่น) ให้ส่ง path นี้เข้ามา
  final String? assetPath;

  const GearImage({
    super.key,
    required this.kind,
    this.big = false,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // ขนาดกรอบรูป (ปรับให้ตรงกับการ์ดของคุณได้)
    final double size = big ? 100 : 120;

    // map รูปพื้นฐานตามชนิดอุปกรณ์
    final String defaultAsset = const {
      GearIllustration.helmet: 'assets/images/image_helmet.png',
      GearIllustration.tank:   'assets/images/image_breathing.png',
      GearIllustration.hose:   'assets/images/image_firehoses.png',
    }[kind]!;

    final String resolvedPath = assetPath ?? defaultAsset;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(big ? 14 : 12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.06),
      //       blurRadius: 10,
      //       offset: const Offset(0, 6),
      //     ),
      //   ],
      // ),
      // clipBehavior: Clip.antiAlias, // ให้ภาพถูกตัดตามมุมโค้ง
      child: Image.asset(
        resolvedPath,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}