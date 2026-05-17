# otel_scylladb

Dartastic OpenTelemetry bridge for ScyllaDB (Cassandra-compatible wide-column NoSQL).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_scylladb/otel_scylladb.dart';

await tracedScyllaDB<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return ScyllaDBCallResult(value: r, result: ScyllaDBResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutScyllaDBInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
