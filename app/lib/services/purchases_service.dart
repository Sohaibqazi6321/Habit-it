import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  return PurchasesService();
});

class PurchasesService {
  static bool _isInitialized = false;
  
  // TODO: Replace with your actual RevenueCat API keys
  static const String _iosApiKey = 'your_ios_api_key_here';
  static const String _androidApiKey = 'goog_NcUYsSWYTmrPvxLkCMeBZmGWeXl';
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      String apiKey;
      if (Platform.isIOS) {
        apiKey = _iosApiKey;
      } else if (Platform.isAndroid) {
        apiKey = _androidApiKey;
      } else {
        // For development/testing on other platforms
        apiKey = _androidApiKey;
      }
      
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('RevenueCat initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize RevenueCat: $e');
      }
      rethrow;
    }
  }
  
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get offerings: $e');
      }
      return null;
    }
  }
  
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get customer info: $e');
      }
      rethrow;
    }
  }
  
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to purchase package: $e');
      }
      rethrow;
    }
  }
  
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to restore purchases: $e');
      }
      rethrow;
    }
  }
  
  bool isProUser(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all['pro']?.isActive == true;
  }
  
  String getManagementUrl() {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/account/subscriptions';
    } else if (Platform.isAndroid) {
      return 'https://play.google.com/store/account/subscriptions';
    }
    return '';
  }
}
