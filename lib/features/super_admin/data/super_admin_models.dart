class SuperAdminStats {
  final int totalSchools;
  final int activeSchools;
  final int totalStudents;
  final int totalParents;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final int pendingTransactions;
  final int totalPtaCollectionsPesewas;
  final int totalPlatformFeesPesewas;
  final int totalGatewayFeesPesewas;
  final int platformRevenuePesewas;

  const SuperAdminStats({
    required this.totalSchools,
    required this.activeSchools,
    required this.totalStudents,
    required this.totalParents,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.pendingTransactions,
    required this.totalPtaCollectionsPesewas,
    required this.totalPlatformFeesPesewas,
    required this.totalGatewayFeesPesewas,
    required this.platformRevenuePesewas,
  });

  factory SuperAdminStats.fromJson(Map<String, dynamic> json) {
    return SuperAdminStats(
      totalSchools: json['total_schools'] as int? ?? 0,
      activeSchools: json['active_schools'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
      totalParents: json['total_parents'] as int? ?? 0,
      totalTransactions: json['total_transactions'] as int? ?? 0,
      successfulTransactions: json['successful_transactions'] as int? ?? 0,
      failedTransactions: json['failed_transactions'] as int? ?? 0,
      pendingTransactions: json['pending_transactions'] as int? ?? 0,
      totalPtaCollectionsPesewas:
          json['total_pta_collections_pesewas'] as int? ?? 0,
      totalPlatformFeesPesewas:
          json['total_platform_fees_pesewas'] as int? ?? 0,
      totalGatewayFeesPesewas: json['total_gateway_fees_pesewas'] as int? ?? 0,
      platformRevenuePesewas: json['platform_revenue_pesewas'] as int? ?? 0,
    );
  }
}

class DailyCollection {
  final String date;
  final int totalPesewas;
  final int ptaPesewas;
  final int platformPesewas;

  const DailyCollection({
    required this.date,
    required this.totalPesewas,
    required this.ptaPesewas,
    required this.platformPesewas,
  });

  factory DailyCollection.fromJson(Map<String, dynamic> json) {
    return DailyCollection(
      date: json['date'] as String,
      totalPesewas: json['total_pesewas'] as int? ?? 0,
      ptaPesewas: json['pta_pesewas'] as int? ?? 0,
      platformPesewas: json['platform_pesewas'] as int? ?? 0,
    );
  }
}

class MonthlyCollection {
  final String month;
  final int totalPesewas;

  const MonthlyCollection({required this.month, required this.totalPesewas});

  factory MonthlyCollection.fromJson(Map<String, dynamic> json) {
    return MonthlyCollection(
      month: json['month'] as String,
      totalPesewas: json['total_pesewas'] as int? ?? 0,
    );
  }
}

class ChannelData {
  final String channel;
  final int count;
  final int totalPesewas;

  const ChannelData({
    required this.channel,
    required this.count,
    required this.totalPesewas,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    return ChannelData(
      channel: json['channel'] as String? ?? 'unknown',
      count: json['count'] as int? ?? 0,
      totalPesewas: json['total_pesewas'] as int? ?? 0,
    );
  }
}

class SchoolRanking {
  final int schoolId;
  final String schoolName;
  final int totalPesewas;
  final int count;

  const SchoolRanking({
    required this.schoolId,
    required this.schoolName,
    required this.totalPesewas,
    required this.count,
  });

  factory SchoolRanking.fromJson(Map<String, dynamic> json) {
    return SchoolRanking(
      schoolId: json['school_id'] as int? ?? 0,
      schoolName: json['school_name'] as String? ?? '',
      totalPesewas: json['total_pesewas'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class SuperAdminCharts {
  final List<DailyCollection> dailyCollections;
  final List<ChannelData> paymentChannels;
  final List<SchoolRanking> schoolRanking;
  final double successRate;
  final List<MonthlyCollection> monthlyCollections;

  const SuperAdminCharts({
    required this.dailyCollections,
    required this.paymentChannels,
    required this.schoolRanking,
    required this.successRate,
    required this.monthlyCollections,
  });

  factory SuperAdminCharts.fromJson(Map<String, dynamic> json) {
    return SuperAdminCharts(
      dailyCollections: (json['daily_collections'] as List<dynamic>? ?? [])
          .map((e) => DailyCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentChannels: (json['payment_channels'] as List<dynamic>? ?? [])
          .map((e) => ChannelData.fromJson(e as Map<String, dynamic>))
          .toList(),
      schoolRanking: (json['school_ranking'] as List<dynamic>? ?? [])
          .map((e) => SchoolRanking.fromJson(e as Map<String, dynamic>))
          .toList(),
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      monthlyCollections: (json['monthly_collections'] as List<dynamic>? ?? [])
          .map((e) => MonthlyCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SuperAdminDashboardData {
  final SuperAdminStats stats;
  final SuperAdminCharts charts;

  const SuperAdminDashboardData({required this.stats, required this.charts});

  factory SuperAdminDashboardData.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardData(
      stats: SuperAdminStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      charts: SuperAdminCharts.fromJson(
        json['charts'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class SchoolListItem {
  final int id;
  final String name;
  final String code;
  final bool active;
  final String? region;
  final String? district;
  final String? contactEmail;

  const SchoolListItem({
    required this.id,
    required this.name,
    required this.code,
    required this.active,
    this.region,
    this.district,
    this.contactEmail,
  });

  factory SchoolListItem.fromJson(Map<String, dynamic> json) {
    return SchoolListItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      region: json['region'] as String?,
      district: json['district'] as String?,
      contactEmail: json['contact_email'] as String?,
    );
  }
}

class PaginatedSchools {
  final List<SchoolListItem> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedSchools({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedSchools.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => SchoolListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedSchools(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 25,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }
}

class PaymentRow {
  final int id;
  final String internalReference;
  final String? gatewayReference;
  final String channel;
  final String state;
  final int ptaPesewas;
  final int platformFeePesewas;
  final int gatewayFeePesewas;
  final int customerTotalPesewas;
  final int schoolEntitlementPesewas;
  final int platformEntitlementPesewas;
  final String? paidAt;
  final PaymentStudent? student;
  final PaymentParent? parent;
  final PaymentSchool? school;

  const PaymentRow({
    required this.id,
    required this.internalReference,
    this.gatewayReference,
    required this.channel,
    required this.state,
    required this.ptaPesewas,
    required this.platformFeePesewas,
    required this.gatewayFeePesewas,
    required this.customerTotalPesewas,
    required this.schoolEntitlementPesewas,
    required this.platformEntitlementPesewas,
    this.paidAt,
    this.student,
    this.parent,
    this.school,
  });

  factory PaymentRow.fromJson(Map<String, dynamic> json) {
    final amounts = json['amounts'] as Map<String, dynamic>? ?? {};
    return PaymentRow(
      id: json['id'] as int? ?? 0,
      internalReference: json['internal_reference'] as String? ?? '',
      gatewayReference: json['gateway_reference'] as String?,
      channel: json['channel'] as String? ?? 'unknown',
      state: json['state'] as String? ?? 'pending',
      ptaPesewas: amounts['pta_pesewas'] as int? ?? 0,
      platformFeePesewas: amounts['platform_fee_pesewas'] as int? ?? 0,
      gatewayFeePesewas: amounts['gateway_fee_pesewas'] as int? ?? 0,
      customerTotalPesewas: amounts['customer_total_pesewas'] as int? ?? 0,
      schoolEntitlementPesewas:
          amounts['school_entitlement_pesewas'] as int? ?? 0,
      platformEntitlementPesewas:
          amounts['platform_entitlement_pesewas'] as int? ?? 0,
      paidAt: json['paid_at'] as String?,
      student: json['student'] != null
          ? PaymentStudent.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      parent: json['parent'] != null
          ? PaymentParent.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      school: json['school'] != null
          ? PaymentSchool.fromJson(json['school'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentStudent {
  final int id;
  final String fullName;
  final String admissionNumber;
  final String className;
  const PaymentStudent({
    required this.id,
    required this.fullName,
    required this.admissionNumber,
    required this.className,
  });
  factory PaymentStudent.fromJson(Map<String, dynamic> json) {
    return PaymentStudent(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      admissionNumber: json['admission_number'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
    );
  }
}

class PaymentParent {
  final String fullName;
  const PaymentParent({required this.fullName});
  factory PaymentParent.fromJson(Map<String, dynamic> json) {
    return PaymentParent(fullName: json['full_name'] as String? ?? '');
  }
}

class PaymentSchool {
  final int id;
  final String name;
  final String code;
  const PaymentSchool({
    required this.id,
    required this.name,
    required this.code,
  });
  factory PaymentSchool.fromJson(Map<String, dynamic> json) {
    return PaymentSchool(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class PaginatedAdminPayments {
  final List<PaymentRow> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedAdminPayments({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedAdminPayments.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => PaymentRow.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedAdminPayments(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 25,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }
}
