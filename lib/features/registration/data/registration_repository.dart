import '../../../networking/api_client.dart';
import '../../super_admin/data/super_admin_models.dart';
import 'registration_models.dart';

/// Data access for the Registration module: regions, schools, students and
/// school users (individual create + bulk import + paged listings).
class RegistrationRepository {
  RegistrationRepository(this._api);
  final ApiClient _api;

  // ------------------------------------------------------------------- Regions

  Future<List<Region>> fetchRegions() async {
    final response = await _api.get('/regions');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => Region.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Region> createRegion({
    required String name,
    String? code,
    int sortOrder = 0,
  }) async {
    final response = await _api.post(
      '/regions',
      data: {
        'name': name,
        if (code != null && code.isNotEmpty) 'code': code,
        'sort_order': sortOrder,
      },
    );
    return Region.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Region> updateRegion({
    required int id,
    required String name,
    String? code,
    int sortOrder = 0,
  }) async {
    final response = await _api.put(
      '/regions/$id',
      data: {
        'name': name,
        if (code != null && code.isNotEmpty) 'code': code,
        'sort_order': sortOrder,
      },
    );
    return Region.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<ImportResult> importRegions(List<Map<String, dynamic>> rows) async {
    final response = await _api.post(
      '/regions/import',
      data: {'regions': rows},
    );
    return ImportResult.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------ Schools

  Future<void> createSchool({
    required String name,
    required String code,
    String? region,
    String? district,
    String? contactEmail,
    String? contactPhone,
    String? address,
    bool active = true,
  }) async {
    await _api.post(
      '/schools',
      data: {
        'name': name,
        'code': code,
        if (region != null && region.isNotEmpty) 'region': region,
        if (district != null && district.isNotEmpty) 'district': district,
        if (contactEmail != null && contactEmail.isNotEmpty)
          'contact_email': contactEmail,
        if (contactPhone != null && contactPhone.isNotEmpty)
          'contact_phone': contactPhone,
        if (address != null && address.isNotEmpty) 'address': address,
        'active': active,
      },
    );
  }

  Future<ImportResult> importSchools(List<Map<String, dynamic>> rows) async {
    final response = await _api.post(
      '/schools/import',
      data: {'schools': rows},
    );
    return ImportResult.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateSchoolActive({
    required int id,
    required bool active,
  }) async {
    await _api.post('/schools/$id/${active ? 'activate' : 'deactivate'}');
  }

  Future<PaginatedRecords<SchoolListItem>> fetchSchools({
    int page = 1,
    int perPage = 100,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _api.get('/schools', queryParameters: params);
    return PaginatedRecords.fromJson(
      response.data['data'] as Map<String, dynamic>,
      SchoolListItem.fromJson,
    );
  }

  // ---------------------------------------------------------------- Students

  Future<void> createStudent({
    int? schoolId,
    required String admissionNumber,
    String? firstName,
    String? middleName,
    String? lastName,
    String? className,
    String? guardianName,
    String? guardianPhone,
  }) async {
    final payload = <String, dynamic>{
      'school_id': ?schoolId,
      'admission_number': admissionNumber,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
      if (middleName != null && middleName.isNotEmpty)
        'middle_name': middleName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      if (className != null && className.isNotEmpty) 'class_name': className,
      if (guardianName != null && guardianName.isNotEmpty)
        'guardian_name': guardianName,
      if (guardianPhone != null && guardianPhone.isNotEmpty)
        'guardian_phone': guardianPhone,
    };
    await _api.post('/students', data: payload);
  }

  Future<PaginatedRecords<StudentRecord>> fetchStudents({
    int page = 1,
    int perPage = 25,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _api.get('/students', queryParameters: params);
    return PaginatedRecords.fromJson(
      response.data['data'] as Map<String, dynamic>,
      StudentRecord.fromJson,
    );
  }

  Future<ImportResult> importStudents({
    int? schoolId,
    required List<Map<String, dynamic>> rows,
  }) async {
    final response = await _api.post(
      '/students/import',
      data: {'school_id': ?schoolId, 'students': rows},
    );
    return ImportResult.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateStudent({
    required int id,
    String? admissionNumber,
    String? firstName,
    String? middleName,
    String? lastName,
    String? className,
    String? guardianName,
    String? guardianPhone,
  }) async {
    final payload = <String, dynamic>{
      if (admissionNumber != null && admissionNumber.isNotEmpty)
        'admission_number': admissionNumber,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
      if (middleName != null && middleName.isNotEmpty)
        'middle_name': middleName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      if (className != null && className.isNotEmpty) 'class_name': className,
      if (guardianName != null && guardianName.isNotEmpty)
        'guardian_name': guardianName,
      if (guardianPhone != null && guardianPhone.isNotEmpty)
        'guardian_phone': guardianPhone,
    };
    await _api.put('/students/$id', data: payload);
  }

  // ------------------------------------------------------------- School users

  Future<void> createSchoolUser({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? password,
  }) async {
    await _api.post(
      '/school-users',
      data: {
        'name': name,
        'email': email,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
  }

  Future<PaginatedRecords<SchoolUserRecord>> fetchSchoolUsers({
    int page = 1,
    int perPage = 25,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _api.get('/school-users', queryParameters: params);
    return PaginatedRecords.fromJson(
      response.data['data'] as Map<String, dynamic>,
      SchoolUserRecord.fromJson,
    );
  }

  Future<void> updateSchoolUser({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? password,
  }) async {
    await _api.put(
      '/school-users/$id',
      data: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
  }

  Future<void> activateSchoolUser({required int id}) async {
    await _api.post('/school-users/$id/activate');
  }

  Future<void> deactivateSchoolUser({required int id}) async {
    await _api.post('/school-users/$id/deactivate');
  }
}
