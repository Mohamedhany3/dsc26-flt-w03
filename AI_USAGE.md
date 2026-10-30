# AI usage: dsc26-flt-w03

## 1. Tools I used

I used ChatGPT to understand the assignment requirements, help write Flutter code, and debug errors during implementation and testing.

I also used Stack Overflow to look for solutions and understand Flutter and Dart errors.

## 2. The prompts that helped most

1. Help me implement QuestionApi with JSON parsing, HTTP status handling, UTF-8 decoding, and network error handling.
2. Help me implement the retry logic in PracticeRepository, fix failing Flutter tests, and organize the UI using ChangeNotifier.

## 3. Where the assistant's code would have failed a hidden-test area, and how I noticed

The assistant initially suggested using `result.error` in PracticeRepository, but the Result class in my project used `result.failure`.

I noticed this because VS Code showed a compilation error. I checked the Result class and corrected the property name.

This could have caused the project to fail compilation before running the hidden tests, including H08 (retry policy).

I also reviewed the asynchronous UI code to ensure the ViewModel checks whether it has been disposed before updating the state. This is important for H13 (leaving mid-request).

## 4. My state-management choice

I used ChangeNotifier to manage loading, success, empty, and error states. I chose it because it is simple, easy to understand, and does not require additional packages.