import 'package:flutter/foundation.dart';

import '../../data/repositories/practice_repository.dart';
import '../../data/services/api_failure.dart';
import '../../domain/models/question.dart';
import '../../utils/result.dart';

class PracticeViewModel extends ChangeNotifier {
  PracticeViewModel({required this.repository, required this.studentId});

  final PracticeRepository repository;
  final String studentId;

  bool isLoading = false;
  bool _disposed = false;

  List<Question> questions = [];
  ApiFailure? failure;

  Future<void> loadQuestions() async {
    if (isLoading || _disposed) return;

    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      final result = await repository.nextQuestions(studentId);

      if (_disposed) return;

      if (result is Ok<List<Question>>) {
        questions = result.value;
        failure = null;
      } else if (result is Err<List<Question>>) {
        questions = [];
        failure = result.failure;
      }
    } catch (_) {
      if (_disposed) return;

      questions = [];
      failure = BadResponse('Unable to load questions');
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
