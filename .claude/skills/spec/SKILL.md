---
name: spec
description: 기능 요구사항 및 설계 문서 생성
argument-hint: [feature_name]
---

# Spec-Driven Development

기능 명세서를 단계별로 작성합니다.

## Instructions

### Phase 1: 요구사항 정의

1. **기능 분석**
   - $ARGUMENTS에서 기능명 확인
   - 사용자 스토리 도출
   - 수락 기준(Acceptance Criteria) 정의

2. **requirements.md 생성**
   ```markdown
   # [Feature Name] 요구사항

   ## 개요
   [기능 설명]

   ## 사용자 스토리
   - As a [사용자], I want [기능], so that [가치]

   ## 수락 기준
   - [ ] 기준 1
   - [ ] 기준 2

   ## 제약 사항
   - [제약 1]
   ```

### Phase 2: 설계

1. **아키텍처 설계**
   - 데이터 모델 설계
   - 컴포넌트 구조 설계
   - API 설계 (필요시)

2. **design.md 생성**
   ```markdown
   # [Feature Name] 설계

   ## 데이터 모델
   [Hive 모델 정의]

   ## 컴포넌트 구조
   [Widget 트리]

   ## 상태 관리
   [Provider 설계]
   ```

### Phase 3: 구현 계획

1. **태스크 분해**
   - 구현 단계별 태스크 정의
   - 우선순위 지정
   - 예상 작업량 추정

2. **tasks.md 생성**
   ```markdown
   # [Feature Name] 구현 태스크

   ## Phase 1: 기반 작업
   - [ ] 모델 생성
   - [ ] Provider 생성

   ## Phase 2: UI 구현
   - [ ] 화면 구현
   - [ ] 위젯 구현

   ## Phase 3: 통합
   - [ ] 테스트 작성
   - [ ] 통합 테스트
   ```

## Output Files

| Phase | Output |
|-------|--------|
| 1 | `docs/[feature]/requirements.md` |
| 2 | `docs/[feature]/design.md` |
| 3 | `docs/[feature]/tasks.md` |

## Arguments

$ARGUMENTS

기능명 (예: "cloud-sync", "push-notification")
