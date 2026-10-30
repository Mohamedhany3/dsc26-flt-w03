import 'package:flutter/material.dart';

import '../../data/repositories/practice_repository.dart';
import '../../data/services/api_failure.dart';
import 'practice_view_model.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.repository,
    required this.studentId,
  });

  final PracticeRepository repository;
  final String studentId;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeViewModel viewModel;

  static const primary = Color(0xFF6654E8);
  static const background = Color(0xFFF5F6FC);

  @override
  void initState() {
    super.initState();
    viewModel = PracticeViewModel(
      repository: widget.repository,
      studentId: widget.studentId,
    );
    viewModel.loadQuestions();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (viewModel.isLoading) {
      return const Center(
        key: Key('practice-loading'),
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (viewModel.failure != null) {
      final unauthorized = viewModel.failure is Unauthorized;

      return Center(
        key: const Key('practice-error'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unauthorized ? Icons.lock_outline : Icons.wifi_off_rounded,
              size: 72,
              color: primary,
            ),
            const SizedBox(height: 20),
            Text(
              unauthorized
                  ? 'Please sign in to continue'
                  : 'Something went wrong',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: Key(unauthorized ? 'practice-signin' : 'practice-retry'),
              onPressed: unauthorized ? () {} : viewModel.loadQuestions,
              child: Text(unauthorized ? 'Sign in' : 'Try again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.questions.isEmpty) {
      return const Center(
        key: Key('practice-empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_rounded, size: 75, color: primary),
            SizedBox(height: 16),
            Text(
              "You've completed today's practice!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('practice-list'),
      padding: const EdgeInsets.all(18),
      itemCount: viewModel.questions.length,
      itemBuilder: (context, index) {
        final question = viewModel.questions[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey('animation-${question.id}'),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + index * 80),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            key: Key('question-${question.id}'),
            elevation: 3,
            shadowColor: primary.withValues(alpha: 0.12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUESTION ${index + 1}',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.stem,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...question.choices.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE6E5F3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color(0xFFE9E6FF),
                            child: Text(
                              String.fromCharCode(65 + entry.key),
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Practice Questions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                key: const Key('practice-refresh'),
                onPressed: viewModel.isLoading ? null : viewModel.loadQuestions,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildBody(),
          ),
        );
      },
    );
  }
}
