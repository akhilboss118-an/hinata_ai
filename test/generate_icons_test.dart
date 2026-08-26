import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate high resolution Spider-Man app icons', () async {
    final sizes = {
      'assets/icons/app_icon.png': 512,
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
      'web/icons/Icon-192.png': 192,
      'web/icons/Icon-512.png': 512,
      'web/favicon.png': 64,
    };

    for (final entry in sizes.entries) {
      final size = entry.value.toDouble();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

      // Background rounded squircle / circle
      final bgPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size * 0.4, size * 0.35),
          size * 0.7,
          [
            const Color(0xFFE31C25), // Spider Red
            const Color(0xFF9E0B13),
            const Color(0xFF140306), // Midnight
          ],
          [0.0, 0.6, 1.0],
        );

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size),
        Radius.circular(size * 0.22),
      );
      canvas.drawRRect(rrect, bgPaint);

      // Spider Web Lattice
      final webPaint = Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.015;

      final center = Offset(size * 0.5, size * 0.48);
      for (double r = size * 0.12; r <= size * 0.46; r += size * 0.10) {
        canvas.drawCircle(center, r, webPaint);
      }
      for (int i = 0; i < 8; i++) {
        final angle = i * (pi / 4);
        final end = center + Offset(cos(angle) * size * 0.48, sin(angle) * size * 0.48);
        canvas.drawLine(center, end, webPaint);
      }

      // Outer Glow Border
      final borderPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size, size),
          [const Color(0xFFFF4D55), const Color(0xFF38BDF8), const Color(0xFFE31C25)],
          [0.0, 0.5, 1.0],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.035;
      canvas.drawRRect(rrect, borderPaint);

      // Left Eye Outer Black Frame
      final leftEyePath = Path();
      leftEyePath.moveTo(size * 0.22, size * 0.46);
      leftEyePath.lineTo(size * 0.44, size * 0.35);
      leftEyePath.lineTo(size * 0.42, size * 0.58);
      leftEyePath.close();

      // Right Eye Outer Black Frame
      final rightEyePath = Path();
      rightEyePath.moveTo(size * 0.78, size * 0.46);
      rightEyePath.lineTo(size * 0.56, size * 0.35);
      rightEyePath.lineTo(size * 0.58, size * 0.58);
      rightEyePath.close();

      final eyeBlackPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.045
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(leftEyePath, eyeBlackPaint);
      canvas.drawPath(rightEyePath, eyeBlackPaint);

      // Left Eye Inner Glowing White Lens
      final leftLensPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(size * 0.22, size * 0.35),
          Offset(size * 0.44, size * 0.58),
          [const Color(0xFFFFFFFF), const Color(0xFFE0F7FA)],
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(leftEyePath, leftLensPaint);

      // Right Eye Inner Glowing White Lens
      final rightLensPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(size * 0.56, size * 0.35),
          Offset(size * 0.78, size * 0.58),
          [const Color(0xFFFFFFFF), const Color(0xFFE0F7FA)],
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(rightEyePath, rightLensPaint);

      // Cyber Cyan Lens Flare / Rim Glow
      final cyanGlow = Paint()
        ..shader = ui.Gradient.linear(
          Offset(size * 0.35, size * 0.6),
          Offset(size * 0.65, size * 0.75),
          [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.015;
      canvas.drawLine(Offset(size * 0.30, size * 0.70), Offset(size * 0.70, size * 0.70), cyanGlow);

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File(entry.key);
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(buffer);
      print('Generated: ${entry.key} (${size.toInt()}x${size.toInt()})');
    }
  });
}
