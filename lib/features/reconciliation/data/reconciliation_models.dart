class ReconciliationRecord {
  final int id;
  final int schoolId;
  final String? schoolName;
  final int? paymentId;

  // Student/invoice context.
  final int? studentId;
  final String? studentName;
  final int? invoiceId;

  // Internal snapshot.
  final String internalReference;
  final String internalState;
  final int internalAmountPesewas;
  final String internalCurrency;
  final String? internalPaidAt;
  final int? internalPlatformFeePesewas;
  final int? internalGatewayFeePesewas;
  final int? internalSchoolEntitlementPesewas;

  // Gateway snapshot.
  final String? gatewayReference;
  final String? gatewayState;
  final int? gatewayAmountPesewas;
  final String? gatewayCurrency;
  final String? gatewayPaidAt;
  final int? gatewayPlatformFeePesewas;
  final int? gatewayGatewayFeePesewas;

  // Settlement.
  final String? settlementStatus;
  final String? settlementBatchRef;
  final String? settlementDate;

  // Reconciliation result.
  final String status;
  final String? discrepancyNotes;
  final String? reviewedAt;
  final int? reviewedBy;
  final String? createdAt;

  const ReconciliationRecord({
    required this.id,
    required this.schoolId,
    this.schoolName,
    this.paymentId,
    this.studentId,
    this.studentName,
    this.invoiceId,
    required this.internalReference,
    required this.internalState,
    required this.internalAmountPesewas,
    required this.internalCurrency,
    this.internalPaidAt,
    this.internalPlatformFeePesewas,
    this.internalGatewayFeePesewas,
    this.internalSchoolEntitlementPesewas,
    this.gatewayReference,
    this.gatewayState,
    this.gatewayAmountPesewas,
    this.gatewayCurrency,
    this.gatewayPaidAt,
    this.gatewayPlatformFeePesewas,
    this.gatewayGatewayFeePesewas,
    this.settlementStatus,
    this.settlementBatchRef,
    this.settlementDate,
    required this.status,
    this.discrepancyNotes,
    this.reviewedAt,
    this.reviewedBy,
    this.createdAt,
  });

  factory ReconciliationRecord.fromJson(Map<String, dynamic> json) {
    final school = json['school'] as Map<String, dynamic>?;
    return ReconciliationRecord(
      id: json['id'] as int? ?? 0,
      schoolId: json['school_id'] as int? ?? 0,
      schoolName: school?['name'] as String?,
      paymentId: json['payment_id'] as int?,
      studentId: json['student_id'] as int?,
      studentName: json['student_name'] as String?,
      invoiceId: json['invoice_id'] as int?,
      internalReference: json['internal_reference'] as String? ?? '',
      internalState: json['internal_state'] as String? ?? '',
      internalAmountPesewas: json['internal_amount_pesewas'] as int? ?? 0,
      internalCurrency: json['internal_currency'] as String? ?? 'GHS',
      internalPaidAt: json['internal_paid_at'] as String?,
      internalPlatformFeePesewas: json['internal_platform_fee_pesewas'] as int?,
      internalGatewayFeePesewas: json['internal_gateway_fee_pesewas'] as int?,
      internalSchoolEntitlementPesewas:
          json['internal_school_entitlement_pesewas'] as int?,
      gatewayReference: json['gateway_reference'] as String?,
      gatewayState: json['gateway_state'] as String?,
      gatewayAmountPesewas: json['gateway_amount_pesewas'] as int?,
      gatewayCurrency: json['gateway_currency'] as String?,
      gatewayPaidAt: json['gateway_paid_at'] as String?,
      gatewayPlatformFeePesewas: json['gateway_platform_fee_pesewas'] as int?,
      gatewayGatewayFeePesewas: json['gateway_gateway_fee_pesewas'] as int?,
      settlementStatus: json['settlement_status'] as String?,
      settlementBatchRef: json['settlement_batch_ref'] as String?,
      settlementDate: json['settlement_date'] as String?,
      status: json['status'] as String? ?? 'pending_review',
      discrepancyNotes: json['discrepancy_notes'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      reviewedBy: json['reviewed_by'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  bool get isException => !['matched', 'pending_review'].contains(status);
  bool get isSettled => settlementStatus == 'settled';
}

class ReconciliationSummary {
  final int totalRecords;
  final Map<String, int> statusCounts;
  final Map<String, int> settlementCounts;
  final int exceptionCount;
  final double exceptionRate;

  const ReconciliationSummary({
    required this.totalRecords,
    required this.statusCounts,
    required this.settlementCounts,
    required this.exceptionCount,
    required this.exceptionRate,
  });

  factory ReconciliationSummary.fromJson(Map<String, dynamic> json) {
    final statusCounts = (json['status_counts'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as int? ?? 0));
    final settlementCounts =
        (json['settlement_counts'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, v as int? ?? 0),
        );
    return ReconciliationSummary(
      totalRecords: json['total_records'] as int? ?? 0,
      statusCounts: statusCounts,
      settlementCounts: settlementCounts,
      exceptionCount: json['exception_count'] as int? ?? 0,
      exceptionRate: (json['exception_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReconciliationRunResult {
  final Map<String, int> summary;

  const ReconciliationRunResult({required this.summary});

  factory ReconciliationRunResult.fromJson(Map<String, dynamic> json) {
    final summary = (json['summary'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, v as int? ?? 0),
    );
    return ReconciliationRunResult(summary: summary);
  }
}

class PaginatedReconciliation {
  final List<ReconciliationRecord> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginatedReconciliation({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginatedReconciliation.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ReconciliationRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedReconciliation(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
      perPage: meta['per_page'] as int? ?? 25,
    );
  }
}
