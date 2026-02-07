/// 자연어 입력에서 날짜/시간/우선순위를 추출하는 파서
class NaturalLanguageParser {
  factory NaturalLanguageParser() => _instance;
  NaturalLanguageParser._internal();
  static final NaturalLanguageParser _instance = NaturalLanguageParser._internal();

  /// 입력 텍스트를 파싱하여 할일 정보 추출
  ParsedTodoInput parse(String input) {
    String title = input;
    DateTime? dueDate;
    int? dueHour;
    int? dueMinute;
    int? priority; // 0-4 (veryLow ~ veryHigh)
    final List<String> tags = [];

    // 태그 추출 (#태그)
    final tagRegex = RegExp(r'#(\S+)');
    final tagMatches = tagRegex.allMatches(input);
    for (final match in tagMatches) {
      tags.add(match.group(1)!);
      title = title.replaceFirst(match.group(0)!, '');
    }

    // 우선순위 추출
    final priorityResult = _extractPriority(title);
    title = priorityResult.remainingText;
    priority = priorityResult.priority;

    // 날짜 추출
    final dateResult = _extractDate(title);
    title = dateResult.remainingText;
    dueDate = dateResult.date;

    // 시간 추출
    final timeResult = _extractTime(title);
    title = timeResult.remainingText;
    dueHour = timeResult.hour;
    dueMinute = timeResult.minute;

    // 날짜가 있고 시간도 있으면 합치기
    if (dueDate != null && dueHour != null) {
      dueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueHour,
        dueMinute ?? 0,
      );
    } else if (dueDate != null && dueHour == null) {
      // 날짜만 있으면 오전 9시로 기본값 설정
      dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0);
    } else if (dueDate == null && dueHour != null) {
      // 시간만 있으면 오늘 날짜 사용
      final now = DateTime.now();
      dueDate = DateTime(now.year, now.month, now.day, dueHour, dueMinute ?? 0);
      // 이미 지난 시간이면 내일로
      if (dueDate.isBefore(now)) {
        dueDate = dueDate.add(const Duration(days: 1));
      }
    }

    // 제목 정리
    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');

    return ParsedTodoInput(
      title: title,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
  }

  /// 우선순위 키워드 추출
  _PriorityResult _extractPriority(String text) {
    String remaining = text;
    int? priority;

    // 높은 우선순위 패턴
    final highPatterns = [
      RegExp(r'\b(긴급|급함|급한|빨리|시급|당장|지금당장|비상)\b'),
      RegExp(r'!{2,}'), // !! 이상
      RegExp(r'\[긴급\]|\[급함\]|\[중요\]'),
    ];

    for (final pattern in highPatterns) {
      if (pattern.hasMatch(remaining)) {
        priority = 4; // veryHigh
        remaining = remaining.replaceAll(pattern, '');
        break;
      }
    }

    // 중요 패턴
    if (priority == null) {
      final importantPatterns = [
        RegExp(r'\b(중요|중요한|꼭|반드시|필수)\b'),
        RegExp(r'!(?!!)'), // 단일 !
        RegExp(r'\[중요\]'),
      ];

      for (final pattern in importantPatterns) {
        if (pattern.hasMatch(remaining)) {
          priority = 3; // high
          remaining = remaining.replaceAll(pattern, '');
          break;
        }
      }
    }

    // 낮은 우선순위 패턴
    if (priority == null) {
      final lowPatterns = [
        RegExp(r'\b(나중에|천천히|여유|여유롭게|시간날때|시간되면)\b'),
      ];

      for (final pattern in lowPatterns) {
        if (pattern.hasMatch(remaining)) {
          priority = 1; // low
          remaining = remaining.replaceAll(pattern, '');
          break;
        }
      }
    }

    return _PriorityResult(remaining, priority);
  }

  /// 날짜 키워드 추출
  _DateResult _extractDate(String text) {
    String remaining = text;
    DateTime? date;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘
    final todayPatterns = [
      RegExp(r'\b오늘\b'),
      RegExp(r'\btoday\b', caseSensitive: false),
    ];
    for (final pattern in todayPatterns) {
      if (pattern.hasMatch(remaining)) {
        date = today;
        remaining = remaining.replaceAll(pattern, '');
        return _DateResult(remaining, date);
      }
    }

    // 내일
    final tomorrowPatterns = [
      RegExp(r'\b내일\b'),
      RegExp(r'\btomorrow\b', caseSensitive: false),
    ];
    for (final pattern in tomorrowPatterns) {
      if (pattern.hasMatch(remaining)) {
        date = today.add(const Duration(days: 1));
        remaining = remaining.replaceAll(pattern, '');
        return _DateResult(remaining, date);
      }
    }

    // 모레
    final dayAfterPatterns = [
      RegExp(r'\b모레\b'),
      RegExp(r'\b내일모레\b'),
    ];
    for (final pattern in dayAfterPatterns) {
      if (pattern.hasMatch(remaining)) {
        date = today.add(const Duration(days: 2));
        remaining = remaining.replaceAll(pattern, '');
        return _DateResult(remaining, date);
      }
    }

    // N일 후 (요일 패턴보다 먼저 체크 - "3일 후"에서 "일"이 요일로 매칭되는 것 방지)
    final daysLaterPattern = RegExp(r'(\d+)\s*일\s*(후|뒤|있다가)');
    final daysLaterMatch = daysLaterPattern.firstMatch(remaining);
    if (daysLaterMatch != null) {
      final days = int.parse(daysLaterMatch.group(1)!);
      date = today.add(Duration(days: days));
      remaining = remaining.replaceFirst(daysLaterMatch.group(0)!, '');
      return _DateResult(remaining, date);
    }

    // 이번 주 특정 요일
    final weekdayMap = {
      '월요일': 1, '월': 1,
      '화요일': 2, '화': 2,
      '수요일': 3, '수': 3,
      '목요일': 4, '목': 4,
      '금요일': 5, '금': 5,
      '토요일': 6, '토': 6,
      '일요일': 7, '일': 7,
    };

    // "이번 주 월요일", "다음 주 화요일" 패턴
    final weekdayPattern = RegExp(r'(이번\s*주|다음\s*주|이번주|다음주)?\s*(월요일|화요일|수요일|목요일|금요일|토요일|일요일|월|화|수|목|금|토|일)');
    final weekdayMatch = weekdayPattern.firstMatch(remaining);
    if (weekdayMatch != null) {
      final prefix = weekdayMatch.group(1);
      final dayName = weekdayMatch.group(2)!;
      final targetWeekday = weekdayMap[dayName]!;

      int daysToAdd = targetWeekday - now.weekday;

      if (prefix != null && (prefix.contains('다음') || prefix.contains('다음주'))) {
        // 다음 주
        if (daysToAdd <= 0) daysToAdd += 7;
        daysToAdd += 7;
      } else {
        // 이번 주 또는 생략
        if (daysToAdd < 0) daysToAdd += 7;
        if (daysToAdd == 0) daysToAdd = 7; // 같은 요일이면 다음 주
      }

      date = today.add(Duration(days: daysToAdd));
      remaining = remaining.replaceFirst(weekdayMatch.group(0)!, '');
      return _DateResult(remaining, date);
    }

    // M월 D일 패턴
    final monthDayPattern = RegExp(r'(\d{1,2})\s*월\s*(\d{1,2})\s*일');
    final monthDayMatch = monthDayPattern.firstMatch(remaining);
    if (monthDayMatch != null) {
      final month = int.parse(monthDayMatch.group(1)!);
      final day = int.parse(monthDayMatch.group(2)!);
      final year = now.year;

      // 이미 지난 날짜면 내년으로
      var targetDate = DateTime(year, month, day);
      if (targetDate.isBefore(today)) {
        targetDate = DateTime(year + 1, month, day);
      }

      date = targetDate;
      remaining = remaining.replaceFirst(monthDayMatch.group(0)!, '');
      return _DateResult(remaining, date);
    }

    // YYYY-MM-DD 또는 YYYY/MM/DD 패턴
    final isoPattern = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    final isoMatch = isoPattern.firstMatch(remaining);
    if (isoMatch != null) {
      final year = int.parse(isoMatch.group(1)!);
      final month = int.parse(isoMatch.group(2)!);
      final day = int.parse(isoMatch.group(3)!);
      date = DateTime(year, month, day);
      remaining = remaining.replaceFirst(isoMatch.group(0)!, '');
      return _DateResult(remaining, date);
    }

    // MM/DD 또는 M/D 패턴
    final shortDatePattern = RegExp(r'(\d{1,2})/(\d{1,2})(?!\d)');
    final shortDateMatch = shortDatePattern.firstMatch(remaining);
    if (shortDateMatch != null) {
      final month = int.parse(shortDateMatch.group(1)!);
      final day = int.parse(shortDateMatch.group(2)!);
      final year = now.year;

      var targetDate = DateTime(year, month, day);
      if (targetDate.isBefore(today)) {
        targetDate = DateTime(year + 1, month, day);
      }

      date = targetDate;
      remaining = remaining.replaceFirst(shortDateMatch.group(0)!, '');
      return _DateResult(remaining, date);
    }

    return _DateResult(remaining, null);
  }

  /// 시간 키워드 추출
  _TimeResult _extractTime(String text) {
    String remaining = text;
    int? hour;
    int? minute;

    // "오후 3시", "오전 10시 30분" 패턴
    final ampmPattern = RegExp(r'(오전|오후|아침|저녁|밤)?\s*(\d{1,2})\s*시\s*(\d{1,2})?\s*분?');
    final ampmMatch = ampmPattern.firstMatch(remaining);
    if (ampmMatch != null) {
      hour = int.parse(ampmMatch.group(2)!);
      minute = ampmMatch.group(3) != null ? int.parse(ampmMatch.group(3)!) : 0;

      final period = ampmMatch.group(1);
      if (period != null) {
        if ((period == '오후' || period == '저녁' || period == '밤') && hour < 12) {
          hour += 12;
        } else if (period == '오전' && hour == 12) {
          hour = 0;
        }
      } else if (hour < 9 && hour > 0) {
        // 시간대 없이 1-8시면 오후로 추정
        hour += 12;
      }

      remaining = remaining.replaceFirst(ampmMatch.group(0)!, '');
      return _TimeResult(remaining, hour, minute);
    }

    // HH:MM 패턴
    final colonPattern = RegExp(r'\b(\d{1,2}):(\d{2})\b');
    final colonMatch = colonPattern.firstMatch(remaining);
    if (colonMatch != null) {
      hour = int.parse(colonMatch.group(1)!);
      minute = int.parse(colonMatch.group(2)!);
      remaining = remaining.replaceFirst(colonMatch.group(0)!, '');
      return _TimeResult(remaining, hour, minute);
    }

    // "정오", "자정" 등 특수 시간
    if (remaining.contains('정오')) {
      remaining = remaining.replaceAll('정오', '');
      return _TimeResult(remaining, 12, 0);
    }
    if (remaining.contains('자정')) {
      remaining = remaining.replaceAll('자정', '');
      return _TimeResult(remaining, 0, 0);
    }

    return _TimeResult(remaining, null, null);
  }
}

class ParsedTodoInput {
  ParsedTodoInput({
    required this.title,
    this.dueDate,
    this.priority,
    this.tags = const [],
  });

  final String title;
  final DateTime? dueDate;
  final int? priority; // 0-4 (veryLow ~ veryHigh)
  final List<String> tags;

  bool get hasDate => dueDate != null;
  bool get hasPriority => priority != null;
  bool get hasTags => tags.isNotEmpty;
  bool get hasAnyExtraction => hasDate || hasPriority || hasTags;
}

class _PriorityResult {
  _PriorityResult(this.remainingText, this.priority);
  final String remainingText;
  final int? priority;
}

class _DateResult {
  _DateResult(this.remainingText, this.date);
  final String remainingText;
  final DateTime? date;
}

class _TimeResult {
  _TimeResult(this.remainingText, this.hour, this.minute);
  final String remainingText;
  final int? hour;
  final int? minute;
}
