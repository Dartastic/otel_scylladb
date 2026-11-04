// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_scylladb/otel_scylladb.dart';
import 'package:test/test.dart';

void main() {
  group('otel_scylladb', () {
    test('suppression toggles in zone', () async {
      expect(scyllaDBInstrumentationSuppressed(), isFalse);
      await runWithoutScyllaDBInstrumentationAsync(() async {
        expect(scyllaDBInstrumentationSuppressed(), isTrue);
      });
      expect(scyllaDBInstrumentationSuppressed(), isFalse);
    });

    test('ScyllaDBResult fields default null', () {
      const r = ScyllaDBResult();
      expect(r.statusCode, isNull);
    });
  });
}
