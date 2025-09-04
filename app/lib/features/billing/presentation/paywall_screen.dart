import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:habit_it/features/billing/providers/billing_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final billingActions = ref.read(billingActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          if (offerings?.current == null) {
            return const _NoOfferingsView();
          }
          
          final offering = offerings!.current!;
          final packages = offering.availablePackages;
          
          if (packages.isEmpty) {
            return const _NoOfferingsView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unlock Pro Features',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get unlimited habits, cloud sync, advanced stats, and more',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Features list
                const _FeaturesList(),

                const SizedBox(height: 24),

                // Packages
                ...packages.map((package) => _PackageCard(
                  package: package,
                  isSelected: _selectedPackageId == package.identifier,
                  isLoading: _isLoading,
                  onTap: () => setState(() => _selectedPackageId = package.identifier),
                  onPurchase: () => _purchasePackage(package, billingActions),
                )),

                const SizedBox(height: 24),

                // Restore purchases
                TextButton(
                  onPressed: _isLoading ? null : () => _restorePurchases(billingActions),
                  child: const Text('Restore Purchases'),
                ),

                const SizedBox(height: 8),

                // Manage subscriptions
                TextButton(
                  onPressed: () => _openManageSubscriptions(billingActions),
                  child: const Text('Manage Subscriptions'),
                ),

                const SizedBox(height: 16),

                // Terms and privacy
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _openUrl('https://habitit.app/terms'),
                      child: const Text('Terms of Service'),
                    ),
                    const Text(' • '),
                    TextButton(
                      onPressed: () => _openUrl('https://habitit.app/privacy'),
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error.toString()),
      ),
    );
  }

  Future<void> _purchasePackage(Package package, BillingActions actions) async {
    setState(() => _isLoading = true);

    try {
      final success = await actions.purchasePackage(package);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome to Pro! 🎉')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases(BillingActions actions) async {
    setState(() => _isLoading = true);

    try {
      final success = await actions.restorePurchases();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored successfully!')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No purchases found to restore.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring purchases: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openManageSubscriptions(BillingActions actions) {
    final url = actions.getManagementUrl();
    if (url.isNotEmpty) {
      _openUrl(url);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onPurchase;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isAnnual = package.packageType == PackageType.annual;
    final isPopular = isAnnual;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<String>(
                    value: package.identifier,
                    groupValue: isSelected ? package.identifier : null,
                    onChanged: (_) => onTap(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPackageTitle(package.packageType),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPackageDescription(package.packageType),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isAnnual)
                        Text(
                          'Save 40%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPackageTitle(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Annual';
      default:
        return 'Pro';
    }
  }

  String _getPackageDescription(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Billed monthly';
      case PackageType.annual:
        return 'Billed annually';
      default:
        return 'Pro features';
    }
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList();

  @override
  Widget build(BuildContext context) {
    final features = [
      'Unlimited habits',
      'Cloud sync across devices',
      'Advanced scheduling (Mon/Wed/Fri, every N days)',
      'Detailed statistics (7/30/90 days)',
      'CSV export',
      'Premium themes',
      'Priority support',
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _NoOfferingsView extends StatelessWidget {
  const _NoOfferingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No offerings available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading offerings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
