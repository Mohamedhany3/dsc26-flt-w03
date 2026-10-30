import 'package:dsc26_flt_w03/ui/practice_screen.dart';
import 'package:flutter/material.dart';

import 'data/repositories/practice_repository.dart';

Widget buildPracticeApp({
  required PracticeRepository repository,
  String studentId = 'demo',
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PracticeScreen(repository: repository, studentId: studentId),
  );
}
