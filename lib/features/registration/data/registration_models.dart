/// Wire models for the Registration module (regions, schools, students,
/// school users) plus bulk-import results.
library;

class Region {
  const Region({
    required this.id,
    required this.name,
    this.code,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final String? code;
  final int sortOrder;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    sortOrder: json['sort_order'] as int? ?? 0,
  );
}

class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.fullName,
    required this.admissionNumber,
    this.className,
    this.guardianName,
    required this.status,
  });

  final int id;
  final String fullName;
  final String admissionNumber;
  final String? className;
  final String? guardianName;
  final String status;

  factory StudentRecord.fromJson(Map<String, dynamic> json) => StudentRecord(
    id: json['id'] as int? ?? 0,
    fullName: json['full_name'] as String? ?? '',
    admissionNumber: json['admission_number'] as String? ?? '',
    className: json['class_name'] as String?,
    guardianName: json['guardian_name'] as String?,
    status: json['status'] as String? ?? 'active',
  );
}

class SchoolUserRecord {
  const SchoolUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.status,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String status;

  factory SchoolUserRecord.fromJson(Map<String, dynamic> json) =>
      SchoolUserRecord(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
        phone: json['phone'] as String?,
        status: json['status'] as String? ?? 'active',
      );
}

class ImportError {
  const ImportError({required this.index, required this.message});

  final int index;
  final String message;

  factory ImportError.fromJson(Map<String, dynamic> json) => ImportError(
    index: json['index'] as int? ?? 0,
    message: json['message'] as String? ?? 'Unknown error',
  );
}

class ImportResult {
  const ImportResult({required this.imported, required this.errors});

  final int imported;
  final List<ImportError> errors;

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
    imported: json['imported'] as int? ?? 0,
    errors: (json['errors'] as List<dynamic>? ?? [])
        .map((e) => ImportError.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class PaginatedRecords<T> {
  const PaginatedRecords({
    required this.data,
    required this.currentPage,
    required this.total,
    required this.lastPage,
  });

  final List<T> data;
  final int currentPage;
  final int total;
  final int lastPage;

  factory PaginatedRecords.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => itemFromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedRecords(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }

  /// Wraps a non-paginated payload (e.g. regions) in a single page.
  factory PaginatedRecords.plain(List<T> data) => PaginatedRecords(
    data: data,
    currentPage: 1,
    total: data.length,
    lastPage: 1,
  );
}
