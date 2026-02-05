---
name: refactor
description: SOLID 원칙 기반 코드 리팩토링
argument-hint: [file_path]
---

# Code Refactoring

SOLID 원칙에 따라 코드를 리팩토링합니다.

## Instructions

1. **대상 파일 분석**
   - $ARGUMENTS로 지정된 파일 또는 최근 변경 파일
   - 코드 구조 파악

2. **문제점 식별**
   - Code Smell 탐지
   - SOLID 원칙 위반 확인
   - 중복 코드 확인

3. **리팩토링 계획**
   - 변경 범위 최소화
   - 단계별 리팩토링

4. **리팩토링 실행**
   - 테스트 통과 확인하며 진행
   - 한 번에 하나의 변경만

5. **검증**
   ```bash
   flutter analyze
   flutter test
   ```

## SOLID Checklist

| 원칙 | 확인 사항 |
|------|----------|
| **S**RP | 클래스가 하나의 책임만 가지는가? |
| **O**CP | 확장에 열려있고 수정에 닫혀있는가? |
| **L**SP | 하위 타입이 상위 타입을 대체할 수 있는가? |
| **I**SP | 인터페이스가 필요한 것만 노출하는가? |
| **D**IP | 추상화에 의존하는가? |

## Common Refactorings

| Smell | Refactoring |
|-------|-------------|
| 긴 메서드 | Extract Method |
| 큰 클래스 | Extract Class |
| 중복 코드 | Extract Method/Class |
| 긴 파라미터 | Parameter Object |
| Feature Envy | Move Method |
| 조건문 복잡도 | Replace Conditional with Polymorphism |

## Flutter Specific

- Widget 분리 (Extract Widget)
- BuildContext 의존성 최소화
- const 생성자 활용
- Provider 분리

## Arguments

$ARGUMENTS

- 빈 값: 최근 변경 파일 리팩토링
- `lib/path/to/file.dart`: 특정 파일 리팩토링
