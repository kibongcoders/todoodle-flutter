---
name: fix
description: 버그 분석 및 수정
disable-model-invocation: true
argument-hint: [error_description]
---

# Bug Fix

버그를 분석하고 수정합니다.

## Instructions

1. **에러 분석**
   - $ARGUMENTS에서 에러 설명 확인
   - 관련 파일 찾기

2. **근본 원인 파악**
   - 스택 트레이스 분석
   - 관련 코드 검토

3. **수정 적용**
   - 최소한의 변경으로 수정
   - 기존 패턴 유지

4. **검증**
   - 빌드 확인
   - 테스트 실행

## Common Errors

| Error | Solution |
|-------|----------|
| HiveError: TypeAdapter exists | TypeId 충돌 확인 (10+ 사용) |
| Null check operator | null 체크 또는 기본값 |
| setState after dispose | mounted 체크 |
| Provider not found | MultiProvider 등록 확인 |

## Arguments

$ARGUMENTS

에러 메시지 또는 버그 설명
