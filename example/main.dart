// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_scylladb/otel_scylladb.dart';

/// Traces Scylladb calls with OpenTelemetry.
///
/// `otel_scylladb` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Scylladb call in
/// [tracedScyllaDB]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'scylladb-example');

  // Traces a Scylladb call.
  final scyllaDBId = await tracedScyllaDB<String>(
    operation: 'create',
    invoke: () async {
      // Make the Scylladb call here, then report what it returned.
      const id = 'scylladb_8f3a2c';
      return const ScyllaDBCallResult(
          value: id,
          result: ScyllaDBResult(
              keyspace: 'orders/2026/inv-1042.pdf',
              table: 'orders',
              statementType: 'active',
              queryText: 'example',
              consistencyLevel: 'example',
              coordinator: 'example',
              pageSize: 512,
              rowsAffected: 1,
              datacenter: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedScyllaDB create returned $scyllaDBId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutScyllaDBInstrumentationAsync.
  await runWithoutScyllaDBInstrumentationAsync(
    () => tracedScyllaDB<String>(
      operation: 'create',
      invoke: () async {
        const id = 'scylladb_8f3a2c';
        return const ScyllaDBCallResult(
            value: id,
            result: ScyllaDBResult(
                keyspace: 'orders/2026/inv-1042.pdf',
                table: 'orders',
                statementType: 'active',
                queryText: 'example',
                consistencyLevel: 'example',
                coordinator: 'example',
                pageSize: 512,
                rowsAffected: 1,
                datacenter: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
