import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:habit_it/services/purchases_service.dart';

// Customer info provider
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final purchasesService = ref.watch(purchasesServiceProvider);
  return await purchasesService.getCustomerInfo();
});

// Pro status provider
final isProUserProvider = Provider<bool>((ref) {
  final customerInfoAsync = ref.watch(customerInfoProvider);
  return customerInfoAsync.when(
    data: (customerInfo) {
      final purchasesService = ref.read(purchasesServiceProvider);
      return purchasesService.isProUser(customerInfo);
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

// Offerings provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final purchasesService = ref.watch(purchasesServiceProvider);
  return await purchasesService.getOfferings();
});

// Billing actions notifier
final billingActionsProvider = Provider<BillingActions>((ref) {
  return BillingActions(ref);
});

class BillingActions {
  final Ref _ref;
  
  BillingActions(this._ref);
  
  PurchasesService get _purchasesService => _ref.read(purchasesServiceProvider);
  
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await _purchasesService.purchasePackage(package);
      if (customerInfo != null) {
        // Refresh customer info after purchase
        _ref.invalidate(customerInfoProvider);
        return _purchasesService.isProUser(customerInfo);
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await _purchasesService.restorePurchases();
      // Refresh customer info after restore
      _ref.invalidate(customerInfoProvider);
      return _purchasesService.isProUser(customerInfo);
    } catch (e) {
      rethrow;
    }
  }
  
  String getManagementUrl() {
    return _purchasesService.getManagementUrl();
  }
}
