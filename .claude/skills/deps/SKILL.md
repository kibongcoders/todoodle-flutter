---
name: deps
description: pubspec.yaml 의존성 업데이트 확인
argument-hint: [--upgrade]
---

# Dependency Management

프로젝트 의존성을 확인하고 관리합니다.

## Instructions

1. **현재 의존성 확인**
   ```bash
   flutter pub deps
   ```

2. **업데이트 가능 패키지 확인**
   ```bash
   flutter pub outdated
   ```

3. **결과 분석**
   - Current: 현재 버전
   - Upgradable: 업그레이드 가능 버전
   - Resolvable: 해결 가능 최신 버전
   - Latest: 최신 버전

4. **업데이트 실행** (`--upgrade` 옵션 시)
   ```bash
   flutter pub upgrade
   ```

5. **호환성 검증**
   ```bash
   flutter analyze
   flutter test
   ```

## Dependency Categories

| 카테고리 | 설명 |
|----------|------|
| dependencies | 런타임 의존성 |
| dev_dependencies | 개발 의존성 |
| dependency_overrides | 버전 오버라이드 |

## Common Dependencies

### State Management
- `provider` - 상태 관리

### Storage
- `hive` - 로컬 DB
- `hive_flutter` - Flutter 바인딩

### UI
- `table_calendar` - 캘린더
- `flutter_local_notifications` - 알림

### Utilities
- `speech_to_text` - 음성 인식
- `intl` - 국제화

## Version Constraints

```yaml
# 정확한 버전
provider: 6.0.5

# 캐럿 구문 (권장)
provider: ^6.0.5  # >=6.0.5 <7.0.0

# 범위 지정
provider: '>=6.0.0 <7.0.0'
```

## Arguments

$ARGUMENTS

- 빈 값: 의존성 상태 확인만
- `--upgrade`: 의존성 업그레이드 실행
