import '../../domain/models/question.dart';
import '../../utils/result.dart';
import '../services/question_api.dart';
import '../services/api_failure.dart';

class PracticeRepository {
  PracticeRepository({
    required QuestionApi api,
    required Future<void> Function(Duration) sleep,
    int maxRetries = 2,
  }) : _api = api,
       _sleep = sleep,
       _maxRetries = maxRetries;

  final QuestionApi _api;
  final Future<void> Function(Duration) _sleep;
  final int _maxRetries;

  Future<Result<List<Question>>> nextQuestions(String studentId) async {
    int retries = 0;

    while (true) {
      final result = await _api.fetchNext(studentId: studentId);

      if (result is Ok<List<Question>>) {
        return result;
      }

      if (result is Err<List<Question>>) {
        final failure = result.failure;

        if (!failure.isTransient || retries >= _maxRetries) {
          return result;
        }

        Duration delay;

        if (failure is RateLimited) {
          final retryAfter = failure.retryAfter;

          delay = retryAfter > const Duration(seconds: 30)
              ? const Duration(seconds: 30)
              : retryAfter;
        } else {
          delay = Duration(seconds: 1 << retries);
        }

        await _sleep(delay);
        retries++;
      } else {
        return result;
      }
    }
  }
}
