import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/features/reconciliation/data/reconciliation_models.dart';

void main() {
  group('ReconciliationRecord', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 1,
        'school_id': 5,
        'school': {'name': 'Accra Academy'},
        'payment_id': 100,
        'student_id': 20,
        'student_name': 'Kwame Mensah',
        'invoice_id': 30,
        'internal_reference': 'INT-001',
        'internal_state': 'successful',
        'internal_amount_pesewas': 10000,
        'internal_currency': 'GHS',
        'internal_paid_at': '2025-09-01T10:00:00Z',
        'internal_platform_fee_pesewas': 500,
        'internal_gateway_fee_pesewas': 200,
        'internal_school_entitlement_pesewas': 9300,
        'gateway_reference': 'GW-001',
        'gateway_state': 'successful',
        'gateway_amount_pesewas': 10000,
        'gateway_currency': 'GHS',
        'gateway_paid_at': '2025-09-01T10:01:00Z',
        'gateway_platform_fee_pesewas': 500,
        'gateway_gateway_fee_pesewas': 200,
        'settlement_status': 'settled',
        'settlement_batch_ref': 'BATCH-001',
        'settlement_date': '2025-09-02',
        'status': 'matched',
        'discrepancy_notes': null,
        'reviewed_at': null,
        'reviewed_by': null,
        'created_at': '2025-09-01T11:00:00Z',
      };
      final record = ReconciliationRecord.fromJson(json);
      expect(record.id, 1);
      expect(record.schoolId, 5);
      expect(record.schoolName, 'Accra Academy');
      expect(record.paymentId, 100);
      expect(record.studentId, 20);
      expect(record.studentName, 'Kwame Mensah');
      expect(record.invoiceId, 30);
      expect(record.internalReference, 'INT-001');
      expect(record.internalState, 'successful');
      expect(record.internalAmountPesewas, 10000);
      expect(record.internalCurrency, 'GHS');
      expect(record.internalPaidAt, '2025-09-01T10:00:00Z');
      expect(record.internalPlatformFeePesewas, 500);
      expect(record.internalGatewayFeePesewas, 200);
      expect(record.internalSchoolEntitlementPesewas, 9300);
      expect(record.gatewayReference, 'GW-001');
      expect(record.gatewayState, 'successful');
      expect(record.gatewayAmountPesewas, 10000);
      expect(record.gatewayCurrency, 'GHS');
      expect(record.gatewayPaidAt, '2025-09-01T10:01:00Z');
      expect(record.gatewayPlatformFeePesewas, 500);
      expect(record.gatewayGatewayFeePesewas, 200);
      expect(record.settlementStatus, 'settled');
      expect(record.settlementBatchRef, 'BATCH-001');
      expect(record.settlementDate, '2025-09-02');
      expect(record.status, 'matched');
      expect(record.createdAt, '2025-09-01T11:00:00Z');
    });

    test('fromJson with nulls uses defaults', () {
      final json = <String, dynamic>{};
      final record = ReconciliationRecord.fromJson(json);
      expect(record.id, 0);
      expect(record.schoolId, 0);
      expect(record.schoolName, isNull);
      expect(record.paymentId, isNull);
      expect(record.studentId, isNull);
      expect(record.studentName, isNull);
      expect(record.invoiceId, isNull);
      expect(record.internalReference, '');
      expect(record.internalState, '');
      expect(record.internalAmountPesewas, 0);
      expect(record.internalCurrency, 'GHS');
      expect(record.status, 'pending_review');
      expect(record.gatewayReference, isNull);
      expect(record.gatewayAmountPesewas, isNull);
      expect(record.settlementStatus, isNull);
    });

    test('isException returns true for exception statuses', () {
      final exceptionStatuses = [
        'amount_mismatch',
        'state_mismatch',
        'missing_gateway',
        'internal_only',
      ];
      for (final s in exceptionStatuses) {
        final record = ReconciliationRecord(
          id: 1,
          schoolId: 1,
          internalReference: 'x',
          internalState: 'y',
          internalAmountPesewas: 0,
          internalCurrency: 'GHS',
          status: s,
        );
        expect(
          record.isException,
          isTrue,
          reason: 'status=$s should be exception',
        );
      }
    });

    test('isException returns false for matched and pending_review', () {
      for (final s in ['matched', 'pending_review']) {
        final record = ReconciliationRecord(
          id: 1,
          schoolId: 1,
          internalReference: 'x',
          internalState: 'y',
          internalAmountPesewas: 0,
          internalCurrency: 'GHS',
          status: s,
        );
        expect(
          record.isException,
          isFalse,
          reason: 'status=$s should not be exception',
        );
      }
    });

    test('isSettled', () {
      final settled = ReconciliationRecord(
        id: 1,
        schoolId: 1,
        internalReference: 'x',
        internalState: 'y',
        internalAmountPesewas: 0,
        internalCurrency: 'GHS',
        status: 'matched',
        settlementStatus: 'settled',
      );
      expect(settled.isSettled, isTrue);

      final unsettled = ReconciliationRecord(
        id: 1,
        schoolId: 1,
        internalReference: 'x',
        internalState: 'y',
        internalAmountPesewas: 0,
        internalCurrency: 'GHS',
        status: 'matched',
        settlementStatus: 'pending',
      );
      expect(unsettled.isSettled, isFalse);
    });
  });

  group('ReconciliationSummary', () {
    test('fromJson', () {
      final json = {
        'total_records': 500,
        'status_counts': {
          'matched': 450,
          'amount_mismatch': 30,
          'pending_review': 20,
        },
        'settlement_counts': {'settled': 400, 'pending': 100},
        'exception_count': 30,
        'exception_rate': 6.0,
      };
      final summary = ReconciliationSummary.fromJson(json);
      expect(summary.totalRecords, 500);
      expect(summary.statusCounts['matched'], 450);
      expect(summary.statusCounts['amount_mismatch'], 30);
      expect(summary.settlementCounts['settled'], 400);
      expect(summary.exceptionCount, 30);
      expect(summary.exceptionRate, 6.0);
    });
  });

  group('ReconciliationRunResult', () {
    test('fromJson', () {
      final json = {
        'summary': {'total': 100, 'matched': 90, 'exceptions': 10},
      };
      final result = ReconciliationRunResult.fromJson(json);
      expect(result.summary['total'], 100);
      expect(result.summary['matched'], 90);
      expect(result.summary['exceptions'], 10);
    });
  });

  group('PaginatedReconciliation', () {
    test('fromJson', () {
      final json = {
        'data': [
          {
            'id': 1,
            'school_id': 5,
            'internal_reference': 'INT-001',
            'internal_state': 'successful',
            'internal_amount_pesewas': 10000,
            'internal_currency': 'GHS',
            'status': 'matched',
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 3,
          'total': 25,
          'per_page': 10,
        },
      };
      final pag = PaginatedReconciliation.fromJson(json);
      expect(pag.data, hasLength(1));
      expect(pag.currentPage, 1);
      expect(pag.lastPage, 3);
      expect(pag.total, 25);
      expect(pag.perPage, 10);
    });
  });
}
