import '../../../networking/api_client.dart';
import 'super_admin_models.dart';

class SuperAdminRepository {
  SuperAdminRepository(this._api);
  final ApiClient _api;

  Future<SuperAdminDashboardData> fetchDashboard() async {
    final response = await _api.get('/admin/dashboard');
    final data = response.data['data'] as Map<String, dynamic>;
    return SuperAdminDashboardData.fromJson(data);
  }

  Future<PaginatedSchools> fetchSchools({
    int page = 1,
    int perPage = 25,
    String? search,
    String? status,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _api.get('/schools', queryParameters: params);
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedSchools.fromJson(data);
  }

  Future<PaginatedAdminPayments> fetchPayments({
    int page = 1,
    int perPage = 25,
    String? state,
    String? channel,
    int? schoolId,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (state != null && state.isNotEmpty) params['state'] = state;
    if (channel != null && channel.isNotEmpty) params['channel'] = channel;
    if (schoolId != null) params['school_id'] = schoolId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;

    final response = await _api.get('/admin/payments', queryParameters: params);
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedAdminPayments.fromJson(data);
  }
}
