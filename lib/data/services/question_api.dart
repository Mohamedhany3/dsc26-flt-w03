import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/question.dart';
import '../../utils/result.dart';
import 'api_failure.dart';

class QuestionApi {
  QuestionApi({
    required http.Client client,
    required Uri baseUrl,
    Duration timeout = const Duration(seconds: 10),
  }) : _client = client,
       _baseUrl = baseUrl,
       _timeout = timeout;

  final http.Client _client;
  final Uri _baseUrl;
  final Duration _timeout;

  Future<Result<List<Question>>> fetchNext({
    required String studentId,
    int limit = 10,
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 50');
    }

    final url = _baseUrl.replace(
      pathSegments: [
        ..._baseUrl.pathSegments.where((s) => s.isNotEmpty),
        'v1',
        'students',
        studentId,
        'next-questions',
      ],
      queryParameters: {'limit': limit.toString()},
    );

    try {
      final response = await _client
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final body = utf8.decode(response.bodyBytes);
          final data = jsonDecode(body);

          if (data is! Map<String, dynamic>) {
            throw const FormatException('Invalid JSON object');
          }

          final rawQuestions = data['questions'];

          if (rawQuestions is! List) {
            throw const FormatException('Invalid questions list');
          }

          final questions = rawQuestions.map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid question');
            }

            return Question.fromJson(item);
          }).toList();

          return Ok(questions);
        } catch (e) {
          return Err(BadResponse('Invalid response data'));
        }
      }

      if (response.statusCode == 401) {
        return Err(Unauthorized());
      }

      if (response.statusCode == 404) {
        return Err(NotFound());
      }

      if (response.statusCode == 429) {
        final retryHeader = response.headers['retry-after'];

        final seconds =
            retryHeader != null && RegExp(r'^[0-9]+$').hasMatch(retryHeader)
            ? int.tryParse(retryHeader)
            : null;

        return Err(RateLimited(Duration(seconds: seconds ?? 5)));
      }

      if (response.statusCode >= 500 && response.statusCode <= 599) {
        return Err(ServerError(response.statusCode));
      }

      return Err(UnexpectedStatus(response.statusCode));
    } on http.ClientException {
      return Err(Offline());
    } on TimeoutException {
      return Err(TimedOut());
    }
  }
}
