---
name: plan
description: 기능 설계 및 구현 계획 작성
argument-hint: [feature_name]
---

# Feature Planning

새 기능의 설계 및 구현 계획을 작성합니다.

## Instructions

1. **요구사항 분석**
   - $ARGUMENTS에서 기능명 확인
   - 기존 코드베이스 분석

2. **아키텍처 설계**
   - Clean Architecture + Feature-First 구조 적용
   - 필요한 레이어 결정

3. **구현 계획 작성**
   ```markdown
   # Feature: [Name]

   ## Overview
   [설명]

   ## Data Model
   - TypeId: [10+]
   - Fields: [...]

   ## Implementation Steps
   1. [ ] Model 생성
   2. [ ] DataSource 구현
   3. [ ] Repository 구현
   4. [ ] Provider 구현
   5. [ ] UI 구현

   ## File Changes
   - Create: [new files]
   - Modify: [existing files]
   ```

## Arguments

$ARGUMENTS

기능명 (예: "cloud-sync", "ai-recommendation")
