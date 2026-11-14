import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UpgradePlanSheet extends ConsumerStatefulWidget {
  const UpgradePlanSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UpgradePlanSheet(),
    );
  }

  @override
  ConsumerState<UpgradePlanSheet> createState() => _UpgradePlanSheetState();
}

class _UpgradePlanSheetState extends ConsumerState<UpgradePlanSheet> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoadingPlans = true;
  String? _selectedPriceId;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _fetchPlansFromStripe();
  }

  Future<void> _fetchPlansFromStripe() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get(ApiEndpoints.paymentPlans);

      if (response is Map<String, dynamic> && response['plans'] is List) {
        final list = (response['plans'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _plans = list;
          _isLoadingPlans = false;
          if (_plans.isNotEmpty) {
            _selectedPriceId = _plans.first['priceId']?.toString();
          }
        });
      } else {
        setState(() => _isLoadingPlans = false);
      }
    } catch (_) {
      setState(() => _isLoadingPlans = false);
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPriceId == null) {
      AppSnackbar.warning(context, 'Please select a plan first.');
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final client = ref.read(apiClientProvider);

      // 1. Create PaymentIntent on Stripe via backend
      final intentResponse = await client.post(
        ApiEndpoints.createPaymentIntent,
        data: {'priceId': _selectedPriceId},
      );

      final paymentIntentId = intentResponse['paymentIntentId']?.toString();

      if (paymentIntentId == null) {
        throw Exception('Could not initialize Stripe payment intent.');
      }

      // 2. Confirm payment intent with backend
      final confirmResponse = await client.post(
        ApiEndpoints.confirmPayment,
        data: {'paymentIntentId': paymentIntentId},
      );

      // 3. Refresh user state in Riverpod
      await ref.read(authNotifierProvider.notifier).checkAuth();

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(
          context,
          confirmResponse['message']?.toString() ??
              'Payment succeeded! Pro membership activated.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.78,
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.screenWidth * 0.05),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.05,
              vertical: context.screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.screenWidth * 0.05),
              ),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recharge Resume & ATS Credits',
                      style: AppTextStyles.cardHeading.copyWith(
                        fontSize: context.screenWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.003),
                    Text(
                      'Pay once • Credits never expire',
                      style: AppTextStyles.metadata,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.secondaryText,
                    size: context.screenWidth * 0.055,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Body: Plan Cards List
          Expanded(
            child: _isLoadingPlans
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : _plans.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(context.screenWidth * 0.05),
                          child: Text(
                            'No active plans found on Stripe Dashboard.\nPlease create products/prices in your Stripe test dashboard.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.supporting,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(context.screenWidth * 0.05),
                        itemCount: _plans.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: context.screenHeight * 0.015),
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final priceId = plan['priceId']?.toString() ?? '';
                          final isSelected = _selectedPriceId == priceId;
                          final name = plan['name']?.toString() ?? 'Pro Plan';
                          final formattedPrice =
                              plan['formattedPrice']?.toString() ?? '\$19.99/mo';
                          final description = plan['description']?.toString() ??
                              'Full access to ATS audits & AI resume tailoring';
                          final resumeCredits = plan['resumeCredits'] ?? 50;
                          final atsCredits = plan['atsCredits'] ?? 30;

                          return InkWell(
                            onTap: () => setState(() => _selectedPriceId = priceId),
                            borderRadius: BorderRadius.circular(
                              context.screenWidth * 0.035,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(context.screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  context.screenWidth * 0.035,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: Offset(
                                        0,
                                        context.screenHeight * 0.004,
                                      ),
                                    ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.mutedText,
                                    size: context.screenWidth * 0.05,
                                  ),
                                  SizedBox(width: context.screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: AppTextStyles.cardHeading
                                                    .copyWith(
                                                  fontSize:
                                                      context.screenWidth *
                                                          0.038,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              formattedPrice,
                                              style: AppTextStyles.cardHeading
                                                  .copyWith(
                                                color: AppColors.primary,
                                                fontSize:
                                                    context.screenWidth *
                                                        0.04,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height:
                                                context.screenHeight * 0.005),
                                        Text(
                                          description,
                                          style: AppTextStyles.supporting
                                              .copyWith(
                                            fontSize:
                                                context.screenWidth * 0.03,
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                context.screenHeight * 0.01),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    context.screenWidth * 0.02,
                                                vertical: context.screenHeight *
                                                    0.003,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  context.screenWidth * 0.015,
                                                ),
                                              ),
                                              child: Text(
                                                '+$resumeCredits Resumes • +$atsCredits Audits',
                                                style: AppTextStyles.metadata
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                        },
                      ),
          ),

          // Checkout Action Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.05,
              vertical: context.screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: CustomButton(
              text: _isProcessingPayment
                  ? 'Processing with Stripe...'
                  : 'Pay with Stripe Card',
              onPressed: _plans.isNotEmpty ? _handlePurchase : null,
              isLoading: _isProcessingPayment,
              icon: Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: context.screenWidth * 0.045,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
