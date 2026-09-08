import '../../../networking/api_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._api);
  final ApiClient _api;

  Future<DashboardData> fetchDashboard() async {
    final response = await _api.get('/reports/dashboard');
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }

  Future<PaginatedPayments> fetchPayments({
    int page = 1,
    int perPage = 25,
    String? state,
    String? channel,
    String? className,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (state != null && state.isNotEmpty) params['state'] = state;
    if (channel != null && channel.isNotEmpty) params['channel'] = channel;
    if (className != null && className.isNotEmpty) {
      params['class_name'] = className;
    }
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;

    final response = await _api.get('/payments', queryParameters: params);
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedPayments.fromJson(data);
  }

  Future<StudentDetails> fetchStudentDetails(int studentId) async {
    final response = await _api.get('/students/$studentId/details');
    final data = response.data['data'] as Map<String, dynamic>;
    return StudentDetails.fromJson(data);
  }

  Future<ReceiptDetail> fetchReceipt(int receiptId) async {
    final response = await _api.get('/receipts/$receiptId');
    final data = response.data['data'] as Map<String, dynamic>;
    return ReceiptDetail.fromJson(data);
  }

  Future<ReceiptDetail> fetchReceiptByPayment(int paymentId) async {
    final response = await _api.get('/payments/$paymentId/receipt');
    final data = response.data['data'] as Map<String, dynamic>;
    return ReceiptDetail.fromJson(data);
  }
}
