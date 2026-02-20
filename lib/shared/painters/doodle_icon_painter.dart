import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/doodle_icon.dart';

/// 손그림 스타일 아이콘 페인터
///
/// DoodleCheckbox 패턴 기반:
/// - Random(42) 고정 시드로 일관된 wobble
/// - 15% 불규칙성
/// - StrokeCap.round, StrokeJoin.round
/// - quadraticBezierTo로 유기적 곡선
class DoodleIconPainter extends CustomPainter {
  DoodleIconPainter({
    required this.type,
    required this.color,
    this.strokeWidth = 2.0,
  });

  final DoodleIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      // 네비게이션
      case DoodleIconType.home:
        _drawHome(canvas, size, paint);
      case DoodleIconType.calendar:
        _drawCalendar(canvas, size, paint);
      case DoodleIconType.timer:
        _drawTimer(canvas, size, paint);
      case DoodleIconType.fire:
        _drawFire(canvas, size, paint);
      case DoodleIconType.settings:
        _drawSettings(canvas, size, paint);

      // 공통 액션
      case DoodleIconType.add:
        _drawAdd(canvas, size, paint);
      case DoodleIconType.close:
        _drawClose(canvas, size, paint);
      case DoodleIconType.check:
        _drawCheck(canvas, size, paint);
      case DoodleIconType.arrowBack:
        _drawArrowBack(canvas, size, paint);
      case DoodleIconType.chevronLeft:
        _drawChevronLeft(canvas, size, paint);
      case DoodleIconType.chevronRight:
        _drawChevronRight(canvas, size, paint);
      case DoodleIconType.search:
        _drawSearch(canvas, size, paint);
      case DoodleIconType.mic:
        _drawMic(canvas, size, paint);
      case DoodleIconType.filter:
        _drawFilter(canvas, size, paint);
      case DoodleIconType.delete:
        _drawDelete(canvas, size, paint);
      case DoodleIconType.edit:
        _drawEdit(canvas, size, paint);

      // 미디어 컨트롤
      case DoodleIconType.play:
        _drawPlay(canvas, size, paint);
      case DoodleIconType.pause:
        _drawPause(canvas, size, paint);
      case DoodleIconType.stop:
        _drawStop(canvas, size, paint);
      case DoodleIconType.skipNext:
        _drawSkipNext(canvas, size, paint);

      // 기타
      case DoodleIconType.share:
        _drawShare(canvas, size, paint);
      case DoodleIconType.dragHandle:
        _drawDragHandle(canvas, size, paint);
      case DoodleIconType.arrowUp:
        _drawArrowUp(canvas, size, paint);
      case DoodleIconType.arrowDown:
        _drawArrowDown(canvas, size, paint);
      case DoodleIconType.lock:
        _drawLock(canvas, size, paint);
      case DoodleIconType.restore:
        _drawRestore(canvas, size, paint);
    }
  }

  // ============================================
  // Wobble 헬퍼
  // ============================================

  static final _random = math.Random(42);

  /// 좌표에 wobble 적용
  double _w(double value, double range) {
    return value + (_random.nextDouble() - 0.5) * range * 0.15;
  }

  /// wobble이 적용된 Offset 생성
  Offset _wo(double x, double y, double range) {
    return Offset(_w(x, range), _w(y, range));
  }

  /// 불규칙한 선 그리기
  void _drawWobblyLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double range,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // 중간 컨트롤 포인트로 살짝 곡선
    final mid = Offset(
      (start.dx + end.dx) / 2 + (_random.nextDouble() - 0.5) * range * 0.1,
      (start.dy + end.dy) / 2 + (_random.nextDouble() - 0.5) * range * 0.1,
    );
    path.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  /// 불규칙한 원 그리기
  void _drawWobblyCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    const segments = 12;

    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi - math.pi / 2;
      final wobble = (_random.nextDouble() - 0.5) * radius * 0.15;
      final r = radius + wobble;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi - math.pi / 2;
        final controlAngle = (prevAngle + angle) / 2;
        final controlR = radius * 1.02;

        final cx = center.dx + controlR * math.cos(controlAngle);
        final cy = center.dy + controlR * math.sin(controlAngle);

        path.quadraticBezierTo(cx, cy, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// 불규칙한 사각형 그리기
  void _drawWobblyRect(
    Canvas canvas,
    double left,
    double top,
    double right,
    double bottom,
    Paint paint,
    double range,
  ) {
    final path = Path();
    final tl = _wo(left, top, range);
    final tr = _wo(right, top, range);
    final br = _wo(right, bottom, range);
    final bl = _wo(left, bottom, range);

    path.moveTo(tl.dx, tl.dy);
    path.quadraticBezierTo(
      (tl.dx + tr.dx) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      (tl.dy + tr.dy) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      tr.dx,
      tr.dy,
    );
    path.quadraticBezierTo(
      (tr.dx + br.dx) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      (tr.dy + br.dy) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      br.dx,
      br.dy,
    );
    path.quadraticBezierTo(
      (br.dx + bl.dx) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      (br.dy + bl.dy) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      bl.dx,
      bl.dy,
    );
    path.quadraticBezierTo(
      (bl.dx + tl.dx) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      (bl.dy + tl.dy) / 2 + (_random.nextDouble() - 0.5) * range * 0.05,
      tl.dx,
      tl.dy,
    );

    canvas.drawPath(path, paint);
  }

  // ============================================
  // 네비게이션 아이콘 (5)
  // ============================================

  /// 집 아이콘: 삼각 지붕 + 사각 벽체
  void _drawHome(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 지붕 (삼각형)
    final roofPath = Path();
    final roofTop = _wo(w * 0.5, h * 0.12, w);
    final roofLeft = _wo(w * 0.1, h * 0.48, w);
    final roofRight = _wo(w * 0.9, h * 0.48, w);

    roofPath.moveTo(roofLeft.dx, roofLeft.dy);
    roofPath.quadraticBezierTo(
      (roofLeft.dx + roofTop.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.05,
      (roofLeft.dy + roofTop.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.05,
      roofTop.dx,
      roofTop.dy,
    );
    roofPath.quadraticBezierTo(
      (roofTop.dx + roofRight.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.05,
      (roofTop.dy + roofRight.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.05,
      roofRight.dx,
      roofRight.dy,
    );
    canvas.drawPath(roofPath, paint);

    // 벽체 (사각형)
    _drawWobblyRect(canvas, w * 0.2, h * 0.48, w * 0.8, h * 0.88, paint, w);

    // 문 (작은 사각형)
    _drawWobblyRect(canvas, w * 0.38, h * 0.6, w * 0.62, h * 0.88, paint, w);
  }

  /// 캘린더 아이콘: 사각형 + 상단 바 + 격자 점
  void _drawCalendar(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 메인 사각형
    _drawWobblyRect(canvas, w * 0.12, h * 0.22, w * 0.88, h * 0.88, paint, w);

    // 상단 바 (두꺼운 선)
    final thickPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawWobblyLine(
      canvas,
      Offset(w * 0.12, h * 0.35),
      Offset(w * 0.88, h * 0.35),
      thickPaint,
      w,
    );

    // 고리 2개
    _drawWobblyLine(canvas, Offset(w * 0.35, h * 0.12), Offset(w * 0.35, h * 0.3), paint, w);
    _drawWobblyLine(canvas, Offset(w * 0.65, h * 0.12), Offset(w * 0.65, h * 0.3), paint, w);

    // 격자 점 (3x3)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final dx = w * (0.3 + col * 0.2);
        final dy = h * (0.48 + row * 0.14);
        canvas.drawCircle(
          _wo(dx, dy, w),
          strokeWidth * 0.6,
          dotPaint,
        );
      }
    }
  }

  /// 타이머 아이콘: 원 + 시계 바늘 2개
  void _drawTimer(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.55);
    final radius = w * 0.38;

    // 원
    _drawWobblyCircle(canvas, center, radius, paint);

    // 꼭지 (상단 작은 사각)
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.08),
      Offset(w * 0.5, h * 0.17),
      paint,
      w,
    );

    // 분침 (12시 방향)
    _drawWobblyLine(
      canvas,
      center,
      _wo(w * 0.5, h * 0.3, w),
      paint,
      w,
    );

    // 시침 (3시 방향)
    _drawWobblyLine(
      canvas,
      center,
      _wo(w * 0.7, h * 0.55, w),
      paint,
      w,
    );
  }

  /// 불꽃 아이콘: 3개의 유기적 곡선
  void _drawFire(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 바깥 불꽃 (메인)
    final outerPath = Path();
    outerPath.moveTo(w * 0.5, h * 0.08);
    outerPath.cubicTo(
      w * 0.15, h * 0.35,
      w * 0.15, h * 0.65,
      w * 0.3, h * 0.85,
    );
    outerPath.quadraticBezierTo(w * 0.5, h * 0.95, w * 0.7, h * 0.85);
    outerPath.cubicTo(
      w * 0.85, h * 0.65,
      w * 0.85, h * 0.35,
      w * 0.5, h * 0.08,
    );
    canvas.drawPath(outerPath, paint);

    // 안쪽 불꽃 (작은)
    final innerPath = Path();
    innerPath.moveTo(w * 0.5, h * 0.4);
    innerPath.cubicTo(
      w * 0.32, h * 0.55,
      w * 0.32, h * 0.7,
      w * 0.42, h * 0.82,
    );
    innerPath.quadraticBezierTo(w * 0.5, h * 0.88, w * 0.58, h * 0.82);
    innerPath.cubicTo(
      w * 0.68, h * 0.7,
      w * 0.68, h * 0.55,
      w * 0.5, h * 0.4,
    );
    canvas.drawPath(innerPath, paint);
  }

  /// 설정 아이콘: 원 + 톱니 6개
  void _drawSettings(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 안쪽 원
    _drawWobblyCircle(canvas, center, w * 0.15, paint);

    // 톱니 6개
    const teeth = 6;
    final innerR = w * 0.24;
    final outerR = w * 0.42;
    const toothWidth = math.pi / 12;

    final gearPath = Path();

    for (var i = 0; i < teeth; i++) {
      final angle = (i / teeth) * 2 * math.pi - math.pi / 2;

      // 톱니 안쪽 시작
      final ia1 = angle - toothWidth * 1.5;
      final ix1 = center.dx + innerR * math.cos(ia1);
      final iy1 = center.dy + innerR * math.sin(ia1);

      // 톱니 바깥쪽 시작
      final oa1 = angle - toothWidth;
      final ox1 = center.dx + outerR * math.cos(oa1);
      final oy1 = center.dy + outerR * math.sin(oa1);

      // 톱니 바깥쪽 끝
      final oa2 = angle + toothWidth;
      final ox2 = center.dx + outerR * math.cos(oa2);
      final oy2 = center.dy + outerR * math.sin(oa2);

      // 톱니 안쪽 끝
      final ia2 = angle + toothWidth * 1.5;
      final ix2 = center.dx + innerR * math.cos(ia2);
      final iy2 = center.dy + innerR * math.sin(ia2);

      if (i == 0) {
        gearPath.moveTo(_w(ix1, w), _w(iy1, w));
      } else {
        gearPath.lineTo(_w(ix1, w), _w(iy1, w));
      }

      gearPath.lineTo(_w(ox1, w), _w(oy1, w));
      gearPath.lineTo(_w(ox2, w), _w(oy2, w));
      gearPath.lineTo(_w(ix2, w), _w(iy2, w));
    }
    gearPath.close();
    canvas.drawPath(gearPath, paint);
  }

  // ============================================
  // 공통 액션 아이콘 (10)
  // ============================================

  /// 더하기 아이콘: + 모양
  void _drawAdd(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 세로선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.5, h * 0.85),
      paint,
      w,
    );

    // 가로선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.15, h * 0.5),
      Offset(w * 0.85, h * 0.5),
      paint,
      w,
    );
  }

  /// 닫기 아이콘: X 모양
  void _drawClose(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 왼쪽 위 → 오른쪽 아래
    _drawWobblyLine(
      canvas,
      Offset(w * 0.2, h * 0.2),
      Offset(w * 0.8, h * 0.8),
      paint,
      w,
    );

    // 오른쪽 위 → 왼쪽 아래
    _drawWobblyLine(
      canvas,
      Offset(w * 0.8, h * 0.2),
      Offset(w * 0.2, h * 0.8),
      paint,
      w,
    );
  }

  /// 체크 아이콘: 체크마크
  void _drawCheck(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final start = _wo(w * 0.15, h * 0.5, w);
    final mid = _wo(w * 0.4, h * 0.75, w);
    final end = _wo(w * 0.85, h * 0.25, w);

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
      (start.dx + mid.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.05,
      (start.dy + mid.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.05,
      mid.dx,
      mid.dy,
    );
    path.quadraticBezierTo(
      (mid.dx + end.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.05,
      (mid.dy + end.dy) / 2 - h * 0.08,
      end.dx,
      end.dy,
    );
    canvas.drawPath(path, paint);
  }

  /// 뒤로가기 화살표: ← 모양
  void _drawArrowBack(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 가로선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.15, h * 0.5),
      Offset(w * 0.85, h * 0.5),
      paint,
      w,
    );

    // 화살표 위쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.15, h * 0.5),
      Offset(w * 0.42, h * 0.25),
      paint,
      w,
    );

    // 화살표 아래쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.15, h * 0.5),
      Offset(w * 0.42, h * 0.75),
      paint,
      w,
    );
  }

  /// 왼쪽 꺾쇠: < 모양
  void _drawChevronLeft(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final top = _wo(w * 0.68, h * 0.18, w);
    final mid = _wo(w * 0.32, h * 0.5, w);
    final bottom = _wo(w * 0.68, h * 0.82, w);

    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      mid.dx + (_random.nextDouble() - 0.5) * w * 0.05,
      mid.dy + (_random.nextDouble() - 0.5) * h * 0.05,
      mid.dx,
      mid.dy,
    );
    path.quadraticBezierTo(
      mid.dx + (_random.nextDouble() - 0.5) * w * 0.05,
      mid.dy + (_random.nextDouble() - 0.5) * h * 0.05,
      bottom.dx,
      bottom.dy,
    );
    canvas.drawPath(path, paint);
  }

  /// 오른쪽 꺾쇠: > 모양
  void _drawChevronRight(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final top = _wo(w * 0.32, h * 0.18, w);
    final mid = _wo(w * 0.68, h * 0.5, w);
    final bottom = _wo(w * 0.32, h * 0.82, w);

    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      mid.dx + (_random.nextDouble() - 0.5) * w * 0.05,
      mid.dy + (_random.nextDouble() - 0.5) * h * 0.05,
      mid.dx,
      mid.dy,
    );
    path.quadraticBezierTo(
      mid.dx + (_random.nextDouble() - 0.5) * w * 0.05,
      mid.dy + (_random.nextDouble() - 0.5) * h * 0.05,
      bottom.dx,
      bottom.dy,
    );
    canvas.drawPath(path, paint);
  }

  /// 돋보기 아이콘: 원 + 손잡이
  void _drawSearch(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 돋보기 원
    final center = Offset(w * 0.42, h * 0.42);
    _drawWobblyCircle(canvas, center, w * 0.28, paint);

    // 손잡이 (오른쪽 아래 대각선)
    _drawWobblyLine(
      canvas,
      Offset(w * 0.62, h * 0.62),
      Offset(w * 0.88, h * 0.88),
      paint,
      w,
    );
  }

  /// 마이크 아이콘: 반원 위에 원형 머리 + 아래 받침
  void _drawMic(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 마이크 머리 (둥근 사각)
    _drawWobblyRect(canvas, w * 0.35, h * 0.1, w * 0.65, h * 0.52, paint, w);

    // 위쪽 반원 (마이크 머리)
    final topArc = Path();
    topArc.moveTo(w * 0.35, h * 0.2);
    topArc.quadraticBezierTo(w * 0.35, h * 0.1, w * 0.5, h * 0.1);
    topArc.quadraticBezierTo(w * 0.65, h * 0.1, w * 0.65, h * 0.2);
    canvas.drawPath(topArc, paint);

    // 컵 모양 (반원)
    final cupPath = Path();
    cupPath.moveTo(w * 0.22, h * 0.42);
    cupPath.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.5, h * 0.72);
    cupPath.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.78, h * 0.42);
    canvas.drawPath(cupPath, paint);

    // 받침대
    _drawWobblyLine(canvas, Offset(w * 0.5, h * 0.72), Offset(w * 0.5, h * 0.88), paint, w);
    _drawWobblyLine(canvas, Offset(w * 0.32, h * 0.88), Offset(w * 0.68, h * 0.88), paint, w);
  }

  /// 필터 아이콘: 깔때기 모양
  void _drawFilter(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final tl = _wo(w * 0.1, h * 0.15, w);
    final tr = _wo(w * 0.9, h * 0.15, w);
    final mid = _wo(w * 0.5, h * 0.58, w);
    final bottom = _wo(w * 0.5, h * 0.88, w);

    path.moveTo(tl.dx, tl.dy);
    path.quadraticBezierTo(
      (tl.dx + mid.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.03,
      (tl.dy + mid.dy) / 2,
      mid.dx,
      mid.dy,
    );
    path.lineTo(bottom.dx, bottom.dy);

    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(tr.dx, tr.dy);
    path2.quadraticBezierTo(
      (tr.dx + mid.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.03,
      (tr.dy + mid.dy) / 2,
      mid.dx,
      mid.dy,
    );

    canvas.drawPath(path2, paint);

    // 상단 가로선
    _drawWobblyLine(canvas, tl, tr, paint, w);
  }

  /// 삭제 아이콘: 쓰레기통 모양
  void _drawDelete(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 뚜껑
    _drawWobblyLine(
      canvas,
      Offset(w * 0.15, h * 0.22),
      Offset(w * 0.85, h * 0.22),
      paint,
      w,
    );

    // 뚜껑 손잡이
    final handlePath = Path();
    handlePath.moveTo(w * 0.38, h * 0.22);
    handlePath.quadraticBezierTo(w * 0.38, h * 0.12, w * 0.5, h * 0.12);
    handlePath.quadraticBezierTo(w * 0.62, h * 0.12, w * 0.62, h * 0.22);
    canvas.drawPath(handlePath, paint);

    // 통 몸체 (사다리꼴)
    final bodyPath = Path();
    final bl = _wo(w * 0.25, h * 0.22, w);
    final br = _wo(w * 0.75, h * 0.22, w);
    final bbl = _wo(w * 0.28, h * 0.88, w);
    final bbr = _wo(w * 0.72, h * 0.88, w);

    bodyPath.moveTo(bl.dx, bl.dy);
    bodyPath.lineTo(bbl.dx, bbl.dy);
    bodyPath.quadraticBezierTo(
      (bbl.dx + bbr.dx) / 2,
      bbl.dy + (_random.nextDouble() - 0.5) * h * 0.02,
      bbr.dx,
      bbr.dy,
    );
    bodyPath.lineTo(br.dx, br.dy);
    canvas.drawPath(bodyPath, paint);

    // 세로줄 2개
    _drawWobblyLine(canvas, Offset(w * 0.42, h * 0.35), Offset(w * 0.42, h * 0.78), paint, w);
    _drawWobblyLine(canvas, Offset(w * 0.58, h * 0.35), Offset(w * 0.58, h * 0.78), paint, w);
  }

  /// 편집 아이콘: 연필 모양
  void _drawEdit(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 연필 몸통 (대각선 사각형)
    final path = Path();
    path.moveTo(w * 0.72, h * 0.12);
    path.lineTo(w * 0.88, h * 0.28);
    path.lineTo(w * 0.35, h * 0.82);
    path.lineTo(w * 0.18, h * 0.65);
    path.close();
    canvas.drawPath(path, paint);

    // 연필 촉 (삼각형)
    final tipPath = Path();
    tipPath.moveTo(w * 0.18, h * 0.65);
    tipPath.lineTo(w * 0.35, h * 0.82);
    tipPath.lineTo(w * 0.12, h * 0.88);
    tipPath.close();
    canvas.drawPath(tipPath, paint);

    // 중간 경계선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.62, h * 0.22),
      Offset(w * 0.78, h * 0.38),
      paint,
      w,
    );
  }

  // ============================================
  // 미디어 컨트롤 아이콘 (4)
  // ============================================

  /// 재생 아이콘: 삼각형
  void _drawPlay(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final top = _wo(w * 0.25, h * 0.15, w);
    final right = _wo(w * 0.82, h * 0.5, w);
    final bottom = _wo(w * 0.25, h * 0.85, w);

    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      (top.dx + right.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.03,
      (top.dy + right.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.03,
      right.dx,
      right.dy,
    );
    path.quadraticBezierTo(
      (right.dx + bottom.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.03,
      (right.dy + bottom.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.03,
      bottom.dx,
      bottom.dy,
    );
    path.quadraticBezierTo(
      (bottom.dx + top.dx) / 2 + (_random.nextDouble() - 0.5) * w * 0.03,
      (bottom.dy + top.dy) / 2 + (_random.nextDouble() - 0.5) * h * 0.03,
      top.dx,
      top.dy,
    );
    canvas.drawPath(path, paint);
  }

  /// 일시정지 아이콘: 수직 바 2개
  void _drawPause(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 왼쪽 바
    _drawWobblyRect(canvas, w * 0.18, h * 0.15, w * 0.4, h * 0.85, paint, w);

    // 오른쪽 바
    _drawWobblyRect(canvas, w * 0.6, h * 0.15, w * 0.82, h * 0.85, paint, w);
  }

  /// 정지 아이콘: 사각형
  void _drawStop(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    _drawWobblyRect(canvas, w * 0.18, h * 0.18, w * 0.82, h * 0.82, paint, w);
  }

  /// 다음 건너뛰기 아이콘: 삼각형 + 수직 바
  void _drawSkipNext(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 삼각형
    final triPath = Path();
    final triTop = _wo(w * 0.12, h * 0.18, w);
    final triRight = _wo(w * 0.62, h * 0.5, w);
    final triBottom = _wo(w * 0.12, h * 0.82, w);

    triPath.moveTo(triTop.dx, triTop.dy);
    triPath.quadraticBezierTo(
      (triTop.dx + triRight.dx) / 2,
      (triTop.dy + triRight.dy) / 2,
      triRight.dx,
      triRight.dy,
    );
    triPath.quadraticBezierTo(
      (triRight.dx + triBottom.dx) / 2,
      (triRight.dy + triBottom.dy) / 2,
      triBottom.dx,
      triBottom.dy,
    );
    triPath.lineTo(triTop.dx, triTop.dy);
    canvas.drawPath(triPath, paint);

    // 수직 바
    _drawWobblyLine(
      canvas,
      Offset(w * 0.75, h * 0.18),
      Offset(w * 0.75, h * 0.82),
      paint,
      w,
    );
  }

  // ============================================
  // 기타 아이콘 (6)
  // ============================================

  /// 공유 아이콘: 세 개 점 + 연결선
  void _drawShare(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final topRight = Offset(w * 0.72, h * 0.22);
    final left = Offset(w * 0.28, h * 0.5);
    final bottomRight = Offset(w * 0.72, h * 0.78);

    // 연결선
    _drawWobblyLine(canvas, left, topRight, paint, w);
    _drawWobblyLine(canvas, left, bottomRight, paint, w);

    // 점 3개
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    _drawWobblyCircle(canvas, topRight, w * 0.08, paint);
    canvas.drawCircle(topRight, w * 0.05, dotPaint);

    _drawWobblyCircle(canvas, left, w * 0.08, paint);
    canvas.drawCircle(left, w * 0.05, dotPaint);

    _drawWobblyCircle(canvas, bottomRight, w * 0.08, paint);
    canvas.drawCircle(bottomRight, w * 0.05, dotPaint);
  }

  /// 드래그 핸들 아이콘: 6개 점 (2x3)
  void _drawDragHandle(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        final dx = w * (0.35 + col * 0.3);
        final dy = h * (0.25 + row * 0.25);
        canvas.drawCircle(
          _wo(dx, dy, w),
          strokeWidth * 0.9,
          dotPaint,
        );
      }
    }
  }

  /// 위쪽 화살표: ↑ 모양
  void _drawArrowUp(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 세로선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.5, h * 0.85),
      paint,
      w,
    );

    // 화살표 왼쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.25, h * 0.42),
      paint,
      w,
    );

    // 화살표 오른쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.75, h * 0.42),
      paint,
      w,
    );
  }

  /// 아래쪽 화살표: ↓ 모양
  void _drawArrowDown(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 세로선
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.5, h * 0.85),
      paint,
      w,
    );

    // 화살표 왼쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.85),
      Offset(w * 0.25, h * 0.58),
      paint,
      w,
    );

    // 화살표 오른쪽
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.85),
      Offset(w * 0.75, h * 0.58),
      paint,
      w,
    );
  }

  /// 자물쇠 아이콘
  void _drawLock(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // 잠금 고리 (상단 반원)
    final lockPath = Path();
    lockPath.moveTo(w * 0.28, h * 0.45);
    lockPath.lineTo(w * 0.28, h * 0.32);
    lockPath.quadraticBezierTo(w * 0.28, h * 0.12, w * 0.5, h * 0.12);
    lockPath.quadraticBezierTo(w * 0.72, h * 0.12, w * 0.72, h * 0.32);
    lockPath.lineTo(w * 0.72, h * 0.45);
    canvas.drawPath(lockPath, paint);

    // 몸통 (사각형)
    _drawWobblyRect(canvas, w * 0.18, h * 0.45, w * 0.82, h * 0.88, paint, w);

    // 열쇠 구멍 (작은 원 + 선)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.6), w * 0.06, dotPaint);
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.62),
      Offset(w * 0.5, h * 0.75),
      paint,
      w,
    );
  }

  /// 복원 아이콘: 반시계 화살표
  void _drawRestore(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 호 (270도)
    final arcPath = Path();
    const startAngle = -math.pi / 2;
    const sweepAngle = -math.pi * 1.5;
    arcPath.addArc(
      Rect.fromCircle(center: center, radius: w * 0.35),
      startAngle,
      sweepAngle,
    );
    canvas.drawPath(arcPath, paint);

    // 화살촉 (위쪽 끝에)
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.3, h * 0.22),
      paint,
      w,
    );
    _drawWobblyLine(
      canvas,
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.58, h * 0.32),
      paint,
      w,
    );
  }

  @override
  bool shouldRepaint(covariant DoodleIconPainter oldDelegate) {
    return type != oldDelegate.type ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
