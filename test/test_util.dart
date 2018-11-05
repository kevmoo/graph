import 'package:test/test.dart';

Matcher throwsAssertionError(messageMatcher) =>
    throwsA(const TypeMatcher<AssertionError>()
        .having((ae) => ae.message, 'message', messageMatcher));
