---
name: dev
description: 개발 완료 워크플로우 (analyze → test → commit)
argument-hint: [--push]
---

# Dev Workflow

개발 완료 후 코드 품질 확인 및 커밋까지 자동화된 워크플로우입니다.

## Pipeline

```
analyze → test → commit [→ push]
```

## Steps

### 1. 코드 분석 (Analyze)
```bash
flutter analyze
```
- 린트 에러 확인
- 에러 발견 시 수정 제안

### 2. 테스트 실행 (Test)
```bash
flutter test
```
- 단위 테스트 실행
- 실패 시 중단 및 원인 분석

### 3. 커밋 (Commit)
- 변경사항 스테이징
- Gitmoji + Conventional Commits 형식으로 커밋
- 형식: `<emoji> <type>(<scope>): <description>`

### 4. 푸시 (선택)
- `--push` 옵션 시 원격에 푸시

## 중단 조건

| 단계 | 중단 조건 |
|------|----------|
| analyze | 에러 발견 시 |
| test | 테스트 실패 시 |
| commit | 변경사항 없을 시 |

## Arguments

$ARGUMENTS

- `--push`: 커밋 후 원격에 푸시
- `--skip-test`: 테스트 건너뛰기
- `--skip-analyze`: 분석 건너뛰기

## 예시

```bash
# 기본 워크플로우
/dev

# 푸시까지 포함
/dev --push

# 테스트만 건너뛰기
/dev --skip-test
```
