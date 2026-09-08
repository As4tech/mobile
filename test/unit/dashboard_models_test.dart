import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/features/dashboard/data/dashboard_models.dart';

void main() {
  group('DashboardStats', () {
    test('fromJson with all fields', () {
      final json = {
        'today_collections_pesewas': 5000,
        'month_collections_pesewas': 150000,
        'total_collections_pesewas': 1200000,
        'outstanding_dues_pesewas': 80000,
        'paid_students': 120,
        'unpaid_students': 30,
        'pending_payments': 5,
        'failed_payments': 2,
      };
      final stats = DashboardStats.fromJson(json);
      expect(stats.todayCollectionsPesewas, 5000);
      expect(stats.monthCollectionsPesewas, 150000);
      expect(stats.totalCollectionsPesewas, 1200000);
      expect(stats.outstandingDuesPesewas, 80000);
      expect(stats.paidStudents, 120);
      expect(stats.unpaidStudents, 30);
      expect(stats.pendingPayments, 5);
      expect(stats.failedPayments, 2);
    });

    test('fromJson with empty map defaults to 0', () {
      final stats = DashboardStats.fromJson({});
      expect(stats.todayCollectionsPesewas, 0);
      expect(stats.monthCollectionsPesewas, 0);
      expect(stats.totalCollectionsPesewas, 0);
      expect(stats.outstandingDuesPesewas, 0);
      expect(stats.paidStudents, 0);
      expect(stats.unpaidStudents, 0);
      expect(stats.pendingPayments, 0);
      expect(stats.failedPayments, 0);
    });

    test('fromJson with null values defaults to 0', () {
      final json = {
        'today_collections_pesewas': null,
        'month_collections_pesewas': null,
        'total_collections_pesewas': null,
        'outstanding_dues_pesewas': null,
        'paid_students': null,
        'unpaid_students': null,
        'pending_payments': null,
        'failed_payments': null,
      };
      final stats = DashboardStats.fromJson(json);
      expect(stats.todayCollectionsPesewas, 0);
      expect(stats.monthCollectionsPesewas, 0);
      expect(stats.totalCollectionsPesewas, 0);
      expect(stats.outstandingDuesPesewas, 0);
      expect(stats.paidStudents, 0);
      expect(stats.unpaidStudents, 0);
      expect(stats.pendingPayments, 0);
      expect(stats.failedPayments, 0);
    });
  });

  group('DailyCollection', () {
    test('fromJson', () {
      final json = {'date': '2025-09-01', 'total_pesewas': 10000};
      final dc = DailyCollection.fromJson(json);
      expect(dc.date, '2025-09-01');
      expect(dc.totalPesewas, 10000);
    });
  });

  group('ChannelData', () {
    test('fromJson', () {
      final json = {'channel': 'momo', 'count': 50, 'total_pesewas': 75000};
      final cd = ChannelData.fromJson(json);
      expect(cd.channel, 'momo');
      expect(cd.count, 50);
      expect(cd.totalPesewas, 75000);
    });
  });

  group('ClassCollection', () {
    test('fromJson', () {
      final json = {'class_name': 'JHS 1', 'total_pesewas': 30000, 'count': 15};
      final cc = ClassCollection.fromJson(json);
      expect(cc.className, 'JHS 1');
      expect(cc.totalPesewas, 30000);
      expect(cc.count, 15);
    });
  });

  group('PaidVsOutstanding', () {
    test('fromJson', () {
      final json = {'paid_pesewas': 500000, 'outstanding_pesewas': 200000};
      final pvo = PaidVsOutstanding.fromJson(json);
      expect(pvo.paidPesewas, 500000);
      expect(pvo.outstandingPesewas, 200000);
    });
  });

  group('DashboardCharts', () {
    test('fromJson with empty lists', () {
      final json = <String, dynamic>{};
      final charts = DashboardCharts.fromJson(json);
      expect(charts.collectionsOverTime, isEmpty);
      expect(charts.paymentChannels, isEmpty);
      expect(charts.classCollections, isEmpty);
      expect(charts.paidVsOutstanding.paidPesewas, 0);
      expect(charts.paidVsOutstanding.outstandingPesewas, 0);
    });

    test('fromJson with data', () {
      final json = {
        'collections_over_time': [
          {'date': '2025-09-01', 'total_pesewas': 5000},
          {'date': '2025-09-02', 'total_pesewas': 8000},
        ],
        'payment_channels': [
          {'channel': 'momo', 'count': 30, 'total_pesewas': 45000},
        ],
        'class_collections': [
          {'class_name': 'JHS 2', 'total_pesewas': 20000, 'count': 10},
        ],
        'paid_vs_outstanding': {
          'paid_pesewas': 300000,
          'outstanding_pesewas': 100000,
        },
      };
      final charts = DashboardCharts.fromJson(json);
      expect(charts.collectionsOverTime, hasLength(2));
      expect(charts.collectionsOverTime[0].date, '2025-09-01');
      expect(charts.paymentChannels, hasLength(1));
      expect(charts.classCollections, hasLength(1));
      expect(charts.paidVsOutstanding.paidPesewas, 300000);
    });
  });

  group('DashboardData', () {
    test('fromJson with nested stats and charts', () {
      final json = {
        'stats': {'today_collections_pesewas': 1000, 'paid_students': 50},
        'charts': {
          'collections_over_time': [
            {'date': '2025-09-01', 'total_pesewas': 2000},
          ],
          'paid_vs_outstanding': {
            'paid_pesewas': 100000,
            'outstanding_pesewas': 50000,
          },
        },
      };
      final data = DashboardData.fromJson(json);
      expect(data.stats.todayCollectionsPesewas, 1000);
      expect(data.stats.paidStudents, 50);
      expect(data.charts.collectionsOverTime, hasLength(1));
      expect(data.charts.paidVsOutstanding.paidPesewas, 100000);
    });

    test('fromJson with missing stats and charts defaults', () {
      final data = DashboardData.fromJson({});
      expect(data.stats.todayCollectionsPesewas, 0);
      expect(data.charts.collectionsOverTime, isEmpty);
    });
  });

  group('PaymentRow', () {
    test('fromJson with student and parent', () {
      final json = {
        'id': 1,
        'internal_reference': 'INT-001',
        'gateway_reference': 'GW-001',
        'channel': 'momo',
        'state': 'successful',
        'amounts': {
          'pta_pesewas': 10000,
          'platform_fee_pesewas': 500,
          'gateway_fee_pesewas': 200,
          'customer_total_pesewas': 10700,
        },
        'paid_at': '2025-09-01T10:30:00Z',
        'student': {
          'id': 10,
          'full_name': 'Kwame Mensah',
          'admission_number': 'ADM-001',
          'class_name': 'JHS 3',
        },
        'parent': {'id': 20, 'full_name': 'Ama Mensah'},
      };
      final row = PaymentRow.fromJson(json);
      expect(row.id, 1);
      expect(row.internalReference, 'INT-001');
      expect(row.gatewayReference, 'GW-001');
      expect(row.channel, 'momo');
      expect(row.state, 'successful');
      expect(row.ptaPesewas, 10000);
      expect(row.platformFeePesewas, 500);
      expect(row.gatewayFeePesewas, 200);
      expect(row.customerTotalPesewas, 10700);
      expect(row.paidAt, '2025-09-01T10:30:00Z');
      expect(row.student, isNotNull);
      expect(row.student!.fullName, 'Kwame Mensah');
      expect(row.parent, isNotNull);
      expect(row.parent!.fullName, 'Ama Mensah');
    });

    test('fromJson without student and parent returns null', () {
      final json = {
        'id': 2,
        'internal_reference': 'INT-002',
        'channel': 'card',
        'state': 'pending',
        'amounts': <String, dynamic>{},
      };
      final row = PaymentRow.fromJson(json);
      expect(row.student, isNull);
      expect(row.parent, isNull);
      expect(row.id, 2);
      expect(row.ptaPesewas, 0);
    });
  });

  group('PaginatedPayments', () {
    test('fromJson with meta', () {
      final json = {
        'data': [
          {
            'id': 1,
            'internal_reference': 'INT-001',
            'channel': 'momo',
            'state': 'successful',
            'amounts': {'pta_pesewas': 5000},
          },
        ],
        'meta': {
          'current_page': 2,
          'per_page': 10,
          'total': 45,
          'last_page': 5,
        },
      };
      final pag = PaginatedPayments.fromJson(json);
      expect(pag.data, hasLength(1));
      expect(pag.currentPage, 2);
      expect(pag.perPage, 10);
      expect(pag.total, 45);
      expect(pag.lastPage, 5);
    });

    test('fromJson with empty data', () {
      final pag = PaginatedPayments.fromJson({});
      expect(pag.data, isEmpty);
      expect(pag.currentPage, 1);
      expect(pag.perPage, 25);
      expect(pag.total, 0);
      expect(pag.lastPage, 1);
    });
  });

  group('StudentDetails', () {
    test('fromJson with invoices and payments', () {
      final json = {
        'student': {
          'id': 5,
          'full_name': 'Abena Osei',
          'admission_number': 'ADM-010',
          'class_name': 'JHS 1',
          'status': 'active',
        },
        'balance': {
          'total_billed_pesewas': 200000,
          'total_paid_pesewas': 150000,
          'outstanding_pesewas': 50000,
          'currency': 'GHS',
        },
        'invoices': [
          {
            'invoice_number': 'INV-001',
            'total_pesewas': 100000,
            'paid_pesewas': 75000,
            'outstanding_pesewas': 25000,
            'status': 'partial',
          },
        ],
        'payments': [
          {
            'internal_reference': 'INT-010',
            'channel': 'momo',
            'state': 'successful',
            'customer_total_pesewas': 75000,
          },
        ],
      };
      final details = StudentDetails.fromJson(json);
      expect(details.student.fullName, 'Abena Osei');
      expect(details.balance.outstandingPesewas, 50000);
      expect(details.invoices, hasLength(1));
      expect(details.payments, hasLength(1));
    });
  });

  group('ReceiptDetail', () {
    test('fromJson with nested school and student', () {
      final json = {
        'id': 100,
        'receipt_number': 'RCP-001',
        'school': {'name': 'Accra Academy', 'logo_path': '/img/logo.png'},
        'student': {
          'full_name': 'Kofi Asante',
          'admission_number': 'ADM-020',
          'class_name': 'JHS 3',
        },
        'parent_name': 'Akua Asante',
        'amounts': {
          'pta_pesewas': 20000,
          'platform_fee_pesewas': 1000,
          'gateway_fee_pesewas': 500,
          'total_paid_pesewas': 21500,
        },
        'payment_channel': 'momo',
        'internal_reference': 'INT-100',
        'gateway_reference': 'GW-100',
        'currency': 'GHS',
        'payment_date': '2025-09-01',
        'payment_status': 'successful',
        'created_at': '2025-09-01T12:00:00Z',
      };
      final receipt = ReceiptDetail.fromJson(json);
      expect(receipt.id, 100);
      expect(receipt.receiptNumber, 'RCP-001');
      expect(receipt.schoolName, 'Accra Academy');
      expect(receipt.schoolLogoPath, '/img/logo.png');
      expect(receipt.studentFullName, 'Kofi Asante');
      expect(receipt.studentAdmissionNumber, 'ADM-020');
      expect(receipt.studentClassName, 'JHS 3');
      expect(receipt.parentName, 'Akua Asante');
      expect(receipt.ptaAmountPesewas, 20000);
      expect(receipt.platformFeePesewas, 1000);
      expect(receipt.gatewayFeePesewas, 500);
      expect(receipt.totalPaidPesewas, 21500);
      expect(receipt.paymentChannel, 'momo');
      expect(receipt.internalReference, 'INT-100');
      expect(receipt.gatewayReference, 'GW-100');
      expect(receipt.currency, 'GHS');
      expect(receipt.paymentDate, '2025-09-01');
      expect(receipt.paymentStatus, 'successful');
    });
  });
}
