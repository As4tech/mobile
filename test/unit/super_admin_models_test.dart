import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/features/super_admin/data/super_admin_models.dart';

void main() {
  group('SuperAdminStats', () {
    test('fromJson with all fields', () {
      final json = {
        'total_schools': 50,
        'active_schools': 45,
        'total_students': 5000,
        'total_parents': 3000,
        'total_transactions': 12000,
        'successful_transactions': 11500,
        'failed_transactions': 200,
        'pending_transactions': 300,
        'total_pta_collections_pesewas': 150000000,
        'total_platform_fees_pesewas': 7500000,
        'total_gateway_fees_pesewas': 3000000,
        'platform_revenue_pesewas': 4500000,
      };
      final stats = SuperAdminStats.fromJson(json);
      expect(stats.totalSchools, 50);
      expect(stats.activeSchools, 45);
      expect(stats.totalStudents, 5000);
      expect(stats.totalParents, 3000);
      expect(stats.totalTransactions, 12000);
      expect(stats.successfulTransactions, 11500);
      expect(stats.failedTransactions, 200);
      expect(stats.pendingTransactions, 300);
      expect(stats.totalPtaCollectionsPesewas, 150000000);
      expect(stats.totalPlatformFeesPesewas, 7500000);
      expect(stats.totalGatewayFeesPesewas, 3000000);
      expect(stats.platformRevenuePesewas, 4500000);
    });

    test('fromJson with empty map defaults to 0', () {
      final stats = SuperAdminStats.fromJson({});
      expect(stats.totalSchools, 0);
      expect(stats.activeSchools, 0);
      expect(stats.totalStudents, 0);
      expect(stats.totalParents, 0);
      expect(stats.totalTransactions, 0);
      expect(stats.successfulTransactions, 0);
      expect(stats.failedTransactions, 0);
      expect(stats.pendingTransactions, 0);
      expect(stats.totalPtaCollectionsPesewas, 0);
      expect(stats.totalPlatformFeesPesewas, 0);
      expect(stats.totalGatewayFeesPesewas, 0);
      expect(stats.platformRevenuePesewas, 0);
    });
  });

  group('SuperAdminCharts', () {
    test('fromJson with empty lists', () {
      final charts = SuperAdminCharts.fromJson({});
      expect(charts.dailyCollections, isEmpty);
      expect(charts.paymentChannels, isEmpty);
      expect(charts.schoolRanking, isEmpty);
      expect(charts.successRate, 0.0);
      expect(charts.monthlyCollections, isEmpty);
    });

    test('fromJson with data', () {
      final json = {
        'daily_collections': [
          {
            'date': '2025-09-01',
            'total_pesewas': 50000,
            'pta_pesewas': 45000,
            'platform_pesewas': 5000,
          },
        ],
        'payment_channels': [
          {'channel': 'momo', 'count': 100, 'total_pesewas': 200000},
        ],
        'school_ranking': [
          {
            'school_id': 1,
            'school_name': 'Accra Academy',
            'total_pesewas': 500000,
            'count': 50,
          },
        ],
        'success_rate': 95.5,
        'monthly_collections': [
          {'month': '2025-09', 'total_pesewas': 1500000},
        ],
      };
      final charts = SuperAdminCharts.fromJson(json);
      expect(charts.dailyCollections, hasLength(1));
      expect(charts.dailyCollections[0].ptaPesewas, 45000);
      expect(charts.paymentChannels, hasLength(1));
      expect(charts.schoolRanking, hasLength(1));
      expect(charts.schoolRanking[0].schoolName, 'Accra Academy');
      expect(charts.successRate, 95.5);
      expect(charts.monthlyCollections, hasLength(1));
    });
  });

  group('SuperAdminDashboardData', () {
    test('fromJson with nested stats and charts', () {
      final json = {
        'stats': {'total_schools': 10, 'active_schools': 8},
        'charts': {
          'daily_collections': [
            {
              'date': '2025-09-01',
              'total_pesewas': 10000,
              'pta_pesewas': 9000,
              'platform_pesewas': 1000,
            },
          ],
          'success_rate': 92.0,
        },
      };
      final data = SuperAdminDashboardData.fromJson(json);
      expect(data.stats.totalSchools, 10);
      expect(data.stats.activeSchools, 8);
      expect(data.charts.dailyCollections, hasLength(1));
      expect(data.charts.successRate, 92.0);
    });

    test('fromJson with missing stats and charts defaults', () {
      final data = SuperAdminDashboardData.fromJson({});
      expect(data.stats.totalSchools, 0);
      expect(data.charts.dailyCollections, isEmpty);
    });
  });

  group('SchoolListItem', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 1,
        'name': 'Accra Academy',
        'code': 'ACAD',
        'active': true,
        'region': 'Greater Accra',
        'district': 'Accra Metro',
        'contact_email': 'admin@acada.edu.gh',
      };
      final school = SchoolListItem.fromJson(json);
      expect(school.id, 1);
      expect(school.name, 'Accra Academy');
      expect(school.code, 'ACAD');
      expect(school.active, isTrue);
      expect(school.region, 'Greater Accra');
      expect(school.district, 'Accra Metro');
      expect(school.contactEmail, 'admin@acada.edu.gh');
    });

    test('fromJson with nulls', () {
      final school = SchoolListItem.fromJson({});
      expect(school.id, 0);
      expect(school.name, '');
      expect(school.code, '');
      expect(school.active, isFalse);
      expect(school.region, isNull);
      expect(school.district, isNull);
      expect(school.contactEmail, isNull);
    });
  });

  group('PaginatedSchools', () {
    test('fromJson', () {
      final json = {
        'data': [
          {'id': 1, 'name': 'School A', 'code': 'SA', 'active': true},
          {'id': 2, 'name': 'School B', 'code': 'SB', 'active': false},
        ],
        'meta': {
          'current_page': 1,
          'per_page': 25,
          'total': 50,
          'last_page': 2,
        },
      };
      final pag = PaginatedSchools.fromJson(json);
      expect(pag.data, hasLength(2));
      expect(pag.currentPage, 1);
      expect(pag.perPage, 25);
      expect(pag.total, 50);
      expect(pag.lastPage, 2);
    });
  });

  group('PaymentRow (super_admin)', () {
    test('fromJson with all nested objects', () {
      final json = {
        'id': 10,
        'internal_reference': 'INT-010',
        'gateway_reference': 'GW-010',
        'channel': 'card',
        'state': 'successful',
        'amounts': {
          'pta_pesewas': 15000,
          'platform_fee_pesewas': 750,
          'gateway_fee_pesewas': 300,
          'customer_total_pesewas': 16050,
          'school_entitlement_pesewas': 14250,
          'platform_entitlement_pesewas': 750,
        },
        'paid_at': '2025-09-01T14:00:00Z',
        'student': {
          'full_name': 'Ama Osei',
          'admission_number': 'ADM-050',
          'class_name': 'JHS 2',
        },
        'parent': {'full_name': 'Kweku Osei'},
        'school': {'id': 3, 'name': 'Ghana National College', 'code': 'GNC'},
      };
      final row = PaymentRow.fromJson(json);
      expect(row.id, 10);
      expect(row.internalReference, 'INT-010');
      expect(row.gatewayReference, 'GW-010');
      expect(row.channel, 'card');
      expect(row.state, 'successful');
      expect(row.ptaPesewas, 15000);
      expect(row.platformFeePesewas, 750);
      expect(row.gatewayFeePesewas, 300);
      expect(row.customerTotalPesewas, 16050);
      expect(row.schoolEntitlementPesewas, 14250);
      expect(row.platformEntitlementPesewas, 750);
      expect(row.paidAt, '2025-09-01T14:00:00Z');
      expect(row.student, isNotNull);
      expect(row.student!.fullName, 'Ama Osei');
      expect(row.parent, isNotNull);
      expect(row.parent!.fullName, 'Kweku Osei');
      expect(row.school, isNotNull);
      expect(row.school!.name, 'Ghana National College');
    });

    test('fromJson without nested objects returns null', () {
      final json = {
        'id': 11,
        'internal_reference': 'INT-011',
        'channel': 'momo',
        'state': 'pending',
        'amounts': <String, dynamic>{},
      };
      final row = PaymentRow.fromJson(json);
      expect(row.student, isNull);
      expect(row.parent, isNull);
      expect(row.school, isNull);
      expect(row.schoolEntitlementPesewas, 0);
      expect(row.platformEntitlementPesewas, 0);
    });
  });
}
