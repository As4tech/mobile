class DashboardStats {
  final int todayCollectionsPesewas;
  final int monthCollectionsPesewas;
  final int totalCollectionsPesewas;
  final int outstandingDuesPesewas;
  final int paidStudents;
  final int unpaidStudents;
  final int pendingPayments;
  final int failedPayments;

  const DashboardStats({
    required this.todayCollectionsPesewas,
    required this.monthCollectionsPesewas,
    required this.totalCollectionsPesewas,
    required this.outstandingDuesPesewas,
    required this.paidStudents,
    required this.unpaidStudents,
    required this.pendingPayments,
    required this.failedPayments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayCollectionsPesewas: json['today_collections_pesewas'] as int? ?? 0,
      monthCollectionsPesewas: json['month_collections_pesewas'] as int? ?? 0,
      totalCollectionsPesewas: json['total_collections_pesewas'] as int? ?? 0,
      outstandingDuesPesewas: json['outstanding_dues_pesewas'] as int? ?? 0,
      paidStudents: json['paid_students'] as int? ?? 0,
      unpaidStudents: json['unpaid_students'] as int? ?? 0,
      pendingPayments: json['pending_payments'] as int? ?? 0,
      failedPayments: json['failed_payments'] as int? ?? 0,
    );
  }
}

class DailyCollection {
  final String date;
  final int totalPesewas;

  const DailyCollection({required this.date, required this.totalPesewas});

  factory DailyCollection.fromJson(Map<String, dynamic> json) {
    return DailyCollection(
      date: json['date'] as String,
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

class ClassCollection {
  final String className;
  final int totalPesewas;
  final int count;

  const ClassCollection({
    required this.className,
    required this.totalPesewas,
    required this.count,
  });

  factory ClassCollection.fromJson(Map<String, dynamic> json) {
    return ClassCollection(
      className: json['class_name'] as String? ?? 'Unknown',
      totalPesewas: json['total_pesewas'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class PaidVsOutstanding {
  final int paidPesewas;
  final int outstandingPesewas;

  const PaidVsOutstanding({
    required this.paidPesewas,
    required this.outstandingPesewas,
  });

  factory PaidVsOutstanding.fromJson(Map<String, dynamic> json) {
    return PaidVsOutstanding(
      paidPesewas: json['paid_pesewas'] as int? ?? 0,
      outstandingPesewas: json['outstanding_pesewas'] as int? ?? 0,
    );
  }
}

class DashboardCharts {
  final List<DailyCollection> collectionsOverTime;
  final List<ChannelData> paymentChannels;
  final List<ClassCollection> classCollections;
  final PaidVsOutstanding paidVsOutstanding;

  const DashboardCharts({
    required this.collectionsOverTime,
    required this.paymentChannels,
    required this.classCollections,
    required this.paidVsOutstanding,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      collectionsOverTime:
          (json['collections_over_time'] as List<dynamic>? ?? [])
              .map((e) => DailyCollection.fromJson(e as Map<String, dynamic>))
              .toList(),
      paymentChannels: (json['payment_channels'] as List<dynamic>? ?? [])
          .map((e) => ChannelData.fromJson(e as Map<String, dynamic>))
          .toList(),
      classCollections: (json['class_collections'] as List<dynamic>? ?? [])
          .map((e) => ClassCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
      paidVsOutstanding: PaidVsOutstanding.fromJson(
        json['paid_vs_outstanding'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class DashboardData {
  final DashboardStats stats;
  final DashboardCharts charts;

  const DashboardData({required this.stats, required this.charts});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      charts: DashboardCharts.fromJson(
        json['charts'] as Map<String, dynamic>? ?? {},
      ),
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
  final String? paidAt;
  final PaymentStudent? student;
  final PaymentParent? parent;

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
    this.paidAt,
    this.student,
    this.parent,
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
      paidAt: json['paid_at'] as String?,
      student: json['student'] != null
          ? PaymentStudent.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      parent: json['parent'] != null
          ? PaymentParent.fromJson(json['parent'] as Map<String, dynamic>)
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
  final int id;
  final String fullName;

  const PaymentParent({required this.id, required this.fullName});

  factory PaymentParent.fromJson(Map<String, dynamic> json) {
    return PaymentParent(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
    );
  }
}

class PaginatedPayments {
  final List<PaymentRow> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedPayments({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedPayments.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => PaymentRow.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedPayments(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 25,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }
}

class StudentDetails {
  final StudentInfo student;
  final StudentBalance balance;
  final List<StudentInvoice> invoices;
  final List<StudentPayment> payments;

  const StudentDetails({
    required this.student,
    required this.balance,
    required this.invoices,
    required this.payments,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      student: StudentInfo.fromJson(
        json['student'] as Map<String, dynamic>? ?? {},
      ),
      balance: StudentBalance.fromJson(
        json['balance'] as Map<String, dynamic>? ?? {},
      ),
      invoices: (json['invoices'] as List<dynamic>? ?? [])
          .map((e) => StudentInvoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => StudentPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentInfo {
  final int id;
  final String fullName;
  final String admissionNumber;
  final String className;
  final String status;
  final String? guardianName;
  final String? guardianPhone;

  const StudentInfo({
    required this.id,
    required this.fullName,
    required this.admissionNumber,
    required this.className,
    required this.status,
    this.guardianName,
    this.guardianPhone,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      admissionNumber: json['admission_number'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      guardianName: json['guardian_name'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
    );
  }
}

class StudentBalance {
  final int totalBilledPesewas;
  final int totalPaidPesewas;
  final int outstandingPesewas;
  final String currency;

  const StudentBalance({
    required this.totalBilledPesewas,
    required this.totalPaidPesewas,
    required this.outstandingPesewas,
    required this.currency,
  });

  factory StudentBalance.fromJson(Map<String, dynamic> json) {
    return StudentBalance(
      totalBilledPesewas: json['total_billed_pesewas'] as int? ?? 0,
      totalPaidPesewas: json['total_paid_pesewas'] as int? ?? 0,
      outstandingPesewas: json['outstanding_pesewas'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'GHS',
    );
  }
}

class StudentInvoice {
  final String invoiceNumber;
  final int totalPesewas;
  final int paidPesewas;
  final int outstandingPesewas;
  final String status;
  final String? issuedAt;
  final String? dueAt;

  const StudentInvoice({
    required this.invoiceNumber,
    required this.totalPesewas,
    required this.paidPesewas,
    required this.outstandingPesewas,
    required this.status,
    this.issuedAt,
    this.dueAt,
  });

  factory StudentInvoice.fromJson(Map<String, dynamic> json) {
    return StudentInvoice(
      invoiceNumber: json['invoice_number'] as String? ?? '',
      totalPesewas: json['total_pesewas'] as int? ?? 0,
      paidPesewas: json['paid_pesewas'] as int? ?? 0,
      outstandingPesewas: json['outstanding_pesewas'] as int? ?? 0,
      status: json['status'] as String? ?? 'unpaid',
      issuedAt: json['issued_at'] as String?,
      dueAt: json['due_at'] as String?,
    );
  }
}

class StudentPayment {
  final String internalReference;
  final String? gatewayReference;
  final String channel;
  final String state;
  final int customerTotalPesewas;
  final String? paidAt;

  const StudentPayment({
    required this.internalReference,
    this.gatewayReference,
    required this.channel,
    required this.state,
    required this.customerTotalPesewas,
    this.paidAt,
  });

  factory StudentPayment.fromJson(Map<String, dynamic> json) {
    return StudentPayment(
      internalReference: json['internal_reference'] as String? ?? '',
      gatewayReference: json['gateway_reference'] as String?,
      channel: json['channel'] as String? ?? 'unknown',
      state: json['state'] as String? ?? 'pending',
      customerTotalPesewas: json['customer_total_pesewas'] as int? ?? 0,
      paidAt: json['paid_at'] as String?,
    );
  }
}

class ReceiptDetail {
  final int id;
  final String receiptNumber;
  final String schoolName;
  final String? schoolLogoPath;
  final String studentFullName;
  final String studentAdmissionNumber;
  final String studentClassName;
  final String parentName;
  final int ptaAmountPesewas;
  final int platformFeePesewas;
  final int gatewayFeePesewas;
  final int totalPaidPesewas;
  final String paymentChannel;
  final String internalReference;
  final String? gatewayReference;
  final String currency;
  final String? paymentDate;
  final String paymentStatus;
  final String? createdAt;

  const ReceiptDetail({
    required this.id,
    required this.receiptNumber,
    required this.schoolName,
    this.schoolLogoPath,
    required this.studentFullName,
    required this.studentAdmissionNumber,
    required this.studentClassName,
    required this.parentName,
    required this.ptaAmountPesewas,
    required this.platformFeePesewas,
    required this.gatewayFeePesewas,
    required this.totalPaidPesewas,
    required this.paymentChannel,
    required this.internalReference,
    this.gatewayReference,
    required this.currency,
    this.paymentDate,
    required this.paymentStatus,
    this.createdAt,
  });

  factory ReceiptDetail.fromJson(Map<String, dynamic> json) {
    final school = json['school'] as Map<String, dynamic>? ?? {};
    final student = json['student'] as Map<String, dynamic>? ?? {};
    final amounts = json['amounts'] as Map<String, dynamic>? ?? {};

    return ReceiptDetail(
      id: json['id'] as int? ?? 0,
      receiptNumber: json['receipt_number'] as String? ?? '',
      schoolName: school['name'] as String? ?? '',
      schoolLogoPath: school['logo_path'] as String?,
      studentFullName: student['full_name'] as String? ?? '',
      studentAdmissionNumber: student['admission_number'] as String? ?? '',
      studentClassName: student['class_name'] as String? ?? '',
      parentName: json['parent_name'] as String? ?? '',
      ptaAmountPesewas: amounts['pta_pesewas'] as int? ?? 0,
      platformFeePesewas: amounts['platform_fee_pesewas'] as int? ?? 0,
      gatewayFeePesewas: amounts['gateway_fee_pesewas'] as int? ?? 0,
      totalPaidPesewas: amounts['total_paid_pesewas'] as int? ?? 0,
      paymentChannel: json['payment_channel'] as String? ?? '',
      internalReference: json['internal_reference'] as String? ?? '',
      gatewayReference: json['gateway_reference'] as String?,
      currency: json['currency'] as String? ?? 'GHS',
      paymentDate: json['payment_date'] as String?,
      paymentStatus: json['payment_status'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }
}
