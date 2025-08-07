
import 'api_service.dart';

class TransactionsService {
  final ApiService _apiService = ApiService();

  // Create a new transaction
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> transactionData) async {
    return await _apiService.post('/transactions', transactionData);
  }

  // Get all transactions
  Future<Map<String, dynamic>> getAllTransactions() async {
    return await _apiService.get('/transactions');
  }

  // Get transaction stats
  Future<Map<String, dynamic>> getTransactionStats() async {
    return await _apiService.get('/transactions/stats');
  }
  // Create a new transaction

  // Get transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    return await _apiService.get('/transactions/$transactionId');
  }
}
