import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  /// 음성 인식 콜백
  Function(String text)? onResult;
  Function(String error)? onError;
  Function()? onListeningStateChanged;

  /// 음성 인식 초기화
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
        debugLogging: kDebugMode,
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Speech service init error: $e');
      return false;
    }
  }

  void _onStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      onListeningStateChanged?.call();
    }
  }

  void _onError(dynamic error) {
    debugPrint('Speech error: $error');
    _isListening = false;
    onError?.call(error.toString());
    onListeningStateChanged?.call();
  }

  /// 음성 인식 시작
  Future<void> startListening() async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        onError?.call('음성 인식을 초기화할 수 없습니다');
        return;
      }
    }

    if (_isListening) {
      await stopListening();
      return;
    }

    try {
      _isListening = true;
      onListeningStateChanged?.call();

      await _speech.listen(
        onResult: _onResult,
        localeId: 'ko_KR', // 한국어
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (e) {
      _isListening = false;
      onError?.call('음성 인식 시작 실패: $e');
      onListeningStateChanged?.call();
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      onResult?.call(result.recognizedWords);
    }
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    _isListening = false;
    onListeningStateChanged?.call();
  }

  /// 음성 인식 취소
  Future<void> cancelListening() async {
    if (!_isListening) return;

    await _speech.cancel();
    _isListening = false;
    onListeningStateChanged?.call();
  }

  /// 사용 가능한 로케일 목록
  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) await init();
    return _speech.locales();
  }

  void dispose() {
    _speech.stop();
    _isListening = false;
  }
}
