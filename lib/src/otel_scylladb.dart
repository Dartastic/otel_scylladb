// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_scylladb_suppression.dart';

class ScyllaDBResult {
  const ScyllaDBResult({
    this.keyspace,
    this.table,
    this.statementType,
    this.queryText,
    this.consistencyLevel,
    this.coordinator,
    this.pageSize,
    this.rowsAffected,
    this.datacenter,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? keyspace;
  final String? table;
  final String? statementType;
  final String? queryText;
  final String? consistencyLevel;
  final String? coordinator;
  final int? pageSize;
  final int? rowsAffected;
  final String? datacenter;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class ScyllaDBCallResult<T> {
  const ScyllaDBCallResult({required this.value, this.result});
  final T value;
  final ScyllaDBResult? result;
}

Future<T> tracedScyllaDB<T>({
  required String operation,
  required Future<ScyllaDBCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (scyllaDBInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_scylladb');
  final span = t.startSpan('scylladb $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'scylladb');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.keyspace != null) {
        span.setStringAttribute('db.namespace', res.keyspace!);
      }
      if (res.table != null) {
        span.setStringAttribute('db.collection.name', res.table!);
      }
      if (res.statementType != null) {
        span.setStringAttribute('db.operation.name', res.statementType!);
      }
      if (res.queryText != null) {
        span.setStringAttribute('db.query.text', res.queryText!);
      }
      if (res.consistencyLevel != null) {
        span.setStringAttribute(
          'db.cassandra.consistency_level',
          res.consistencyLevel!,
        );
      }
      if (res.coordinator != null) {
        span.setStringAttribute('db.cassandra.coordinator', res.coordinator!);
      }
      if (res.pageSize != null) {
        span.setIntAttribute('db.cassandra.page_size', res.pageSize!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.datacenter != null) {
        span.setStringAttribute('scylla.datacenter', res.datacenter!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('scylladb.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'scylla.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
