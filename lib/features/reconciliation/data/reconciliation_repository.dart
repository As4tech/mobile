import '../../../networking/api_client.dart';
import 'reconciliation_models.dart';

class ReconciliationRepository {
  ReconciliationRepository(this._api);
  final ApiClient _api;

  Future<ReconciliationSummary> fetchSummary({
    int? schoolId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, dynamic>{};
    if (schoolId != null) params['school_id'] = schoolId;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final response = await _api.get(
      '/reconciliation/summary',
      queryParameters: params,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ReconciliationSummary.fromJson(data);
  }

  Future<PaginatedReconciliation> fetchRecords({
    int page = 1,
    int perPage = 25,
    String? status,
    int? schoolId,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? settlementStatus,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (schoolId != null) params['school_id'] = schoolId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;
    if (settlementStatus != null && settlementStatus.isNotEmpty) {
      params['settlement_status'] = settlementStatus;
    }

    final response = await _api.get('/reconciliation', queryParameters: params);
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedReconciliation.fromJson(data);
  }

  Future<ReconciliationRunResult> runReconciliation({
    String? dateFrom,
    String? dateTo,
    int? schoolId,
  }) async {
    final body = <String, dynamic>{};
    if (dateFrom != null) body['date_from'] = dateFrom;
    if (dateTo != null) body['date_to'] = dateTo;
    if (schoolId != null) body['school_id'] = schoolId;

    final response = await _api.post('/reconciliation/run', data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    return ReconciliationRunResult.fromJson(data);
  }

  Future<void> reviewRecord(int id, String status, String? notes) async {
    final body = <String, dynamic>{'status': status};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    await _api.post('/reconciliation/$id/review', data: body);
  }

  Future<void> markSettlement({
    required List<String> references,
    required String batchRef,
    String? settlementDate,
  }) async {
    final body = <String, dynamic>{
      'references': references,
      'batch_ref': batchRef,
    };
    if (settlementDate != null) body['settlement_date'] = settlementDate;

    await _api.post('/reconciliation/settlement', data: body);
  }
}
