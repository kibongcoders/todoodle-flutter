import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// 3D GLB 모델을 사용하는 회전하는 행성 위젯
class RotatingPlanet extends StatelessWidget {
  const RotatingPlanet({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const ModelViewer(
        src: 'assets/models/yellow_moon.glb',
        alt: 'Little Prince Planet',
        autoRotate: true,
        autoRotateDelay: 0,
        rotationPerSecond: '18deg',
        cameraControls: true,
        disableZoom: true,
        backgroundColor: Colors.transparent,
        interactionPrompt: InteractionPrompt.none,
      ),
    );
  }
}
