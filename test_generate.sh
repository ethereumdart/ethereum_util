#!/bin/bash
dart run test --coverage=./.dart_tool/coverage
dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./.dart_tool/coverage/lcov.info -i ./.dart_tool/coverage
genhtml -o ./.dart_tool/coverage/report ./.dart_tool/coverage/lcov.info



