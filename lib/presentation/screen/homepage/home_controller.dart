import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:inpay_app/data/services/api_services.dart";
import "package:inpay_app/presentation/screen/login/login_screen.dart";

class HomeController extends GetxController {
  final ApiService _apiservice = ApiService();

  // Data variables
  var balance = "0.00".obs;
  var currency = "Rupees".obs;
  var isLoading = true.obs;

  // Automated fetching
  @override
  void onReady() {
    super.onReady();
    fetchBalance(); // Fetch data when the page is fully visible
  }

  // API Communication
  Future<void> fetchBalance() async {
    try {
      isLoading(true);
      final data = await _apiservice.fetchBalance();
      if (data != null) {
        balance.value = data['balance'].toString();
        currency.value = data['currency'] ?? "Rupees";
      }
    } catch (e) {
      Get.snackbar("Error", ("Server connection failed"));
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _apiservice.logout();
    balance.value = "0.00";

    // Manually delete the controller so it "re-runs" onInit next time
    Get.delete<HomeController>();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
