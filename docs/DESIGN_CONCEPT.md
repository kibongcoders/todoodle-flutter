# Todoodle Design Concept

> "할일을 낙서하듯 자유롭게" - Doodle your todos freely

## 1. 브랜드 아이덴티티

### 1.1 컨셉 정의

**Todoodle = Todo + Doodle**

"Doodle(낙서)"의 특성을 앱 디자인에 반영합니다:

| Doodle 특성 | 앱 적용 |
|------------|--------|
| 손으로 그린 느낌 | 손글씨 스타일 폰트, 유기적 곡선 |
| 자유로움 | 격식 없는 레이아웃, 플레이풀한 애니메이션 |
| 불완전한 매력 | 약간 삐뚤빠뚤한 요소, 스케치 테두리 |
| 노트/종이 느낌 | 종이 텍스처, 격자/줄노트 배경 |
| 컬러풀 | 밝고 따뜻한 파스텔 컬러 |

### 1.2 디자인 원칙

1. **Playful (장난스러운)**: 딱딱한 생산성 앱이 아닌, 즐거운 낙서장
2. **Organic (유기적인)**: 기계적 직선보다 자연스러운 곡선
3. **Personal (개인적인)**: 내 노트에 끄적이는 듯한 친밀감
4. **Delightful (즐거운)**: 작은 인터랙션에도 재미 요소

---

## 2. 컬러 시스템

### 2.1 Primary Palette (메인 팔레트)

낙서장의 따뜻하고 편안한 느낌을 주는 컬러:

```
┌─────────────────────────────────────────────────────┐
│  🎨 Primary Colors                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ██████  Paper Cream     #FFF9E6  (배경)            │
│  ██████  Pencil Gray     #4A4A4A  (기본 텍스트)      │
│  ██████  Sketch Line     #E0D5C1  (테두리/구분선)    │
│  ██████  Doodle Green    #7CB342  (Primary Action)  │
│  ██████  Highlight Pink  #FF8A80  (강조)            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 2.2 Accent Colors (강조 컬러)

낙서에서 쓰는 형광펜/색연필 느낌:

```dart
// lib/core/constants/doodle_colors.dart

class DoodleColors {
  // === Paper & Base ===
  static const paperCream = Color(0xFFFFF9E6);      // 노트 종이
  static const paperWhite = Color(0xFFFFFDF7);      // 밝은 종이
  static const paperGrid = Color(0xFFE8E0D0);       // 모눈 격자

  // === Pencil & Ink ===
  static const pencilDark = Color(0xFF4A4A4A);      // 연필 진하게
  static const pencilLight = Color(0xFF9E9E9E);     // 연필 연하게
  static const inkBlue = Color(0xFF5C6BC0);         // 잉크펜 파랑

  // === Highlighters (형광펜) ===
  static const highlightYellow = Color(0xFFFFF59D); // 노랑 형광
  static const highlightPink = Color(0xFFFF8A80);   // 핑크 형광
  static const highlightGreen = Color(0xFFC5E1A5);  // 초록 형광
  static const highlightBlue = Color(0xFF81D4FA);   // 파랑 형광
  static const highlightOrange = Color(0xFFFFCC80); // 주황 형광

  // === Color Pencils (색연필) ===
  static const crayonRed = Color(0xFFE57373);
  static const crayonOrange = Color(0xFFFFB74D);
  static const crayonYellow = Color(0xFFFFF176);
  static const crayonGreen = Color(0xFF81C784);
  static const crayonBlue = Color(0xFF64B5F6);
  static const crayonPurple = Color(0xFFBA68C8);

  // === Priority Mapping ===
  static const priorityVeryHigh = Color(0xFFFF6B6B);  // 빨간 동그라미
  static const priorityHigh = Color(0xFFFFB347);      // 주황 별
  static const priorityMedium = Color(0xFFFFE066);    // 노랑 체크
  static const priorityLow = Color(0xFF98D8C8);       // 민트 물결
  static const priorityVeryLow = Color(0xFFAED9E0);   // 하늘 점
}
```

### 2.3 우선순위 시각화 (Doodle Style)

기존 배지 대신 손그림 아이콘으로 표현:

```
비상!  → 🔴 빨간 동그라미 (손으로 휙 그린 느낌)
높음   → ⭐ 별표 (삐뚤한 별)
보통   → ✓ 체크 (연필 체크마크)
낮음   → 〰️ 물결 (느긋한 웨이브)
여유   → · 점 (작은 점)
```

---

## 3. 타이포그래피

### 3.1 폰트 선택

**손글씨 느낌을 주면서도 가독성 유지**

```yaml
# pubspec.yaml

fonts:
  - family: Pretendard
    fonts:
      - asset: assets/fonts/Pretendard-Regular.otf
      - asset: assets/fonts/Pretendard-Bold.otf
        weight: 700

  # 제목/강조용 손글씨 폰트
  - family: NanumPen
    fonts:
      - asset: assets/fonts/NanumPenScript-Regular.ttf
```

### 3.2 텍스트 스타일

```dart
// lib/core/constants/doodle_typography.dart

class DoodleTypography {
  // === Headers (손글씨 느낌) ===
  static const headlineLarge = TextStyle(
    fontFamily: 'NanumPen',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
  );

  static const headlineMedium = TextStyle(
    fontFamily: 'NanumPen',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
  );

  // === Body (가독성 위해 기본 폰트) ===
  static const bodyLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
  );

  // === Labels (작은 텍스트) ===
  static const labelSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilLight,
  );

  // === 취소선 (완료된 할일) ===
  static const todoCompleted = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    color: DoodleColors.pencilLight,
    decoration: TextDecoration.lineThrough,
    decorationColor: DoodleColors.crayonRed,
    decorationThickness: 2,
  );
}
```

---

## 4. UI 컴포넌트

### 4.1 카드 (Doodle Card)

노트에 붙인 포스트잇/메모지 느낌:

```
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
╎                              ╎
╎  ☐ 오늘 할일 목록 작성하기     ╎
╎     📅 오늘  ⭐ 중요          ╎
╎                              ╎
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
       ↑ 점선 테두리 (손그림 느낌)
```

```dart
// lib/shared/widgets/doodle_card.dart

class DoodleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(4), // 살짝 각진 느낌
        border: Border.all(
          color: DoodleColors.pencilLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(2, 2), // 약간 비대칭 그림자
            blurRadius: 0, // 선명한 그림자
          ),
        ],
      ),
      child: child,
    );
  }
}
```

### 4.2 체크박스 (Doodle Checkbox)

손으로 그린 체크박스:

```
미완료: [ ]  →  빈 네모 (약간 삐뚤)
완료:   [✓]  →  빨간 체크 (휙 그은 느낌)
```

```dart
// lib/shared/widgets/doodle_checkbox.dart

class DoodleCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(24, 24),
        painter: _CheckboxPainter(isChecked: isChecked),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  // 손그림 느낌의 불규칙한 네모 + 체크마크
}
```

### 4.3 버튼 (Doodle Button)

```
┌──────────────┐
│  + 할일 추가  │  ← 손글씨 느낌 폰트
└──────────────┘
     ↑ 둥글지 않은 각진 테두리
```

### 4.4 배경 패턴

노트/격자 느낌의 배경:

```dart
// lib/shared/painters/grid_background_painter.dart

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DoodleColors.paperGrid
      ..strokeWidth = 0.5;

    // 가로 줄 (줄노트)
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 또는 모눈 격자
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }
}
```

---

## 5. 아이콘 시스템

### 5.1 Doodle Icons

Material Icons 대신 손그림 스타일 아이콘 사용:

```
현재             →  Doodle 스타일
─────────────────────────────────
📅 calendar      →  달력 낙서
⏰ alarm         →  시계 스케치
⭐ star          →  삐뚤한 별
✓ check          →  휙 그은 체크
+ add            →  손으로 그린 +
🗑️ delete        →  지우개/구겨진 종이
```

### 5.2 아이콘 적용 방안

**Option A: SVG 커스텀 아이콘**
```yaml
dependencies:
  flutter_svg: ^2.0.0
```

**Option B: 아이콘 폰트 제작**
- Figma/Illustrator에서 손그림 아이콘 디자인
- IcoMoon/Fontello로 폰트 변환

**Option C: CustomPainter로 동적 그리기**
- 장점: 애니메이션 가능, 런타임 커스터마이징
- 단점: 구현 복잡도

---

## 6. 애니메이션 & 인터랙션

### 6.1 Doodle 애니메이션 원칙

| 액션 | 애니메이션 | 느낌 |
|------|----------|------|
| 할일 추가 | 연필로 쓱 쓰는 효과 | Writing animation |
| 완료 체크 | 빨간펜으로 휙 긋기 | Scratch-off effect |
| 삭제 | 지우개로 문지르기 | Eraser wipe |
| 드래그 | 종이가 살짝 들리는 | Paper lift shadow |
| 로딩 | 연필이 움직이며 낙서 | Pencil scribble |

### 6.2 마이크로 인터랙션

```dart
// 체크 완료 시 효과
class CheckAnimation extends StatefulWidget {
  // 1. 체크박스에 빨간 체크 그려짐 (0.3s)
  // 2. 텍스트에 취소선 스윽 (0.2s)
  // 3. 카드가 살짝 옅어짐 (0.2s)
}

// 할일 추가 시 효과
class AddTodoAnimation extends StatefulWidget {
  // 1. 연필 아이콘이 위에서 내려옴
  // 2. 텍스트가 한 글자씩 나타남 (typewriter)
  // 3. 카드가 툭 떨어지듯 등장
}
```

---

## 7. 화면별 디자인 가이드

### 7.1 홈 화면

```
┌─────────────────────────────────┐
│  📓 Todoodle           ⚙️ 🔔   │  ← 손글씨 로고
├─────────────────────────────────┤
│  ═══════════════════════════   │  ← 줄노트 배경
│  오늘의 할일                     │
│  ═══════════════════════════   │
│                                │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │
│  ╎ ☐ 프로젝트 기획서 작성   ╎    │  ← Doodle Card
│  ╎   ⭐ 중요 · 📅 오늘     ╎    │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │
│                                │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │
│  ╎ ☑ 아침 운동 완료        ╎    │  ← 완료 (취소선)
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │
│                                │
│            [+ 낙서 추가]        │  ← FAB
└─────────────────────────────────┘
```

### 7.2 집중 모드 (포모도로)

```
┌─────────────────────────────────┐
│                                │
│         ╭───────────╮          │
│        ╱             ╲         │  ← 손그림 원형
│       │    25:00     │         │
│        ╲             ╱         │
│         ╰───────────╯          │
│                                │
│      🌱 → 🌿 → 🌳 → 🌲        │  ← 식물 성장
│                                │
│     [ 잠시 쉬기 ]  [ 집중! ]    │
│                                │
└─────────────────────────────────┘
```

### 7.3 숲 꾸미기

```
┌─────────────────────────────────┐
│  🌲 나의 작은 숲                │
├─────────────────────────────────┤
│                                │
│    🌸    🌳        🌻          │
│      🌿      🌲    🌷  🌼      │
│   ════════════════════════    │  ← 잔디/땅
│                                │
│  "열심히 해서 나무 7그루 심었어!"  │
│                                │
└─────────────────────────────────┘
```

---

## 8. 구현 로드맵

### Phase 1: 기반 작업 (우선)
- [ ] `lib/core/constants/doodle_colors.dart` 생성
- [ ] `lib/core/constants/doodle_typography.dart` 생성
- [ ] `lib/shared/themes/doodle_theme.dart` 생성
- [ ] 기존 ThemeData를 DoodleTheme으로 교체

### Phase 2: 핵심 컴포넌트
- [ ] `DoodleCard` 위젯 구현
- [ ] `DoodleCheckbox` 위젯 구현
- [ ] `DoodleButton` 위젯 구현
- [ ] 배경 패턴 (줄노트/모눈) 구현

### Phase 3: 아이콘 & 일러스트
- [ ] 손그림 스타일 아이콘 세트 제작
- [ ] 우선순위 아이콘 (별, 동그라미 등)
- [ ] 빈 상태 일러스트

### Phase 4: 애니메이션
- [ ] 체크 완료 애니메이션
- [ ] 할일 추가 애니메이션
- [ ] 페이지 전환 애니메이션

### Phase 5: 세부 디테일
- [ ] 커스텀 폰트 적용
- [ ] 스플래시 화면 리디자인
- [ ] 앱 아이콘 리디자인
- [ ] 다크 모드 (밤의 낙서장 컨셉)

---

## 9. 참고 자료

### 디자인 레퍼런스
- [Notion](https://notion.so) - 깔끔하면서 개성있는 UI
- [Things 3](https://culturedcode.com/things/) - 미니멀하지만 따뜻한 느낌
- [Bear Notes](https://bear.app) - 마크다운 + 감성적 디자인
- [Google Keep](https://keep.google.com) - 포스트잇/낙서 느낌

### 손글씨 폰트
- 나눔펜스크립트 (무료, 한글)
- Indie Flower (무료, 영문)
- Comic Neue (무료, 영문)

### 손그림 아이콘
- [Doodle Icons](https://khushmeen.com/doodle-icons.html)
- [Handdrawn Icons](https://www.iconfinder.com/search?q=hand+drawn)

---

## 변경 이력

| 날짜 | 버전 | 내용 |
|------|------|------|
| 2025-02-10 | 0.1.0 | 초안 작성 |

---

> 💡 **Note**: 이 문서는 디자인 방향성을 정의한 것이며, 실제 구현 시 Flutter의 제약사항과 성능을 고려하여 조정될 수 있습니다.
