import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:inpay_app/data/models/transaction_model.dart';
import 'package:inpay_app/data/services/api_services.dart';
import 'package:inpay_app/presentation/screen/login/login_screen.dart';

class HomeController extends GetxController {
  final ApiService _apiservice = ApiService();

  var balance = "0.00".obs;
  var currency = "Rupees".obs;
  var isLoading = true.obs;
  var transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshData(); // This handles everything at startup
  }

  Future<void> refreshData() async {
    try {
      isLoading(true);
      // Run both API calls in parallel to save time
      await Future.wait([fetchBalance(), fetchTransactions()]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBalance() async {
    try {
      final data = await _apiservice.fetchBalance();
      if (data != null) {
        // Since Go sends an integer (Paise), ensure you format it
        // if your fetchBalance API returns the raw integer.
        balance.value = data['balance'].toString();
        currency.value = data['currency'] ?? "Rupees";
      }
    } catch (e) {
      debugPrint("Balance Error: $e");
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final List<dynamic>? data = await _apiservice.fetchTransactions();
      if (data != null) {
        transactions.assignAll(
          data.map((json) => TransactionModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint("Transaction Error: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    await _apiservice.logout();
    balance.value = "0.00";
    transactions.clear(); // Clear history on logout

    Get.delete<HomeController>();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
