import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  List<dynamic> _tickets = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get(ApiEndpoints.supportTickets);
      if (res is Map<String, dynamic> && res['tickets'] is List) {
        setState(() {
          _tickets = res['tickets'];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);
      await client.post(
        ApiEndpoints.supportTickets,
        data: {
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );

      _subjectController.clear();
      _messageController.clear();

      if (mounted) {
        AppSnackbar.success(context, Lang.ticketSubmitted);
      }
      await _fetchTickets();
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.supportTitle,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: context.screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ticket Creation Card
              Container(
                padding: EdgeInsets.all(context.screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: Offset(0, context.screenHeight * 0.003),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Lang.openNewTicket,
                        style: AppTextStyles.cardHeading.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: context.screenHeight * 0.02),
                      CustomTextField(
                        label: Lang.ticketSubject,
                        hint: 'e.g. Question about ATS score calculation',
                        controller: _subjectController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? Lang.valRequired : null,
                      ),
                      SizedBox(height: context.screenHeight * 0.016),
                      CustomTextField(
                        label: Lang.ticketMessage,
                        hint: 'Provide details on your request or problem...',
                        controller: _messageController,
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().isEmpty) ? Lang.valRequired : null,
                      ),
                      SizedBox(height: context.screenHeight * 0.025),
                      CustomButton(
                        text: Lang.submitTicket,
                        onPressed: _handleSubmitTicket,
                        isLoading: _isSubmitting,
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: context.screenWidth * 0.045,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.035),

              // Existing Tickets List
              Text('Your Inquiries & Tickets', style: AppTextStyles.sectionHeading),
              SizedBox(height: context.screenHeight * 0.015),

              if (_isLoading)
                const LoadingWidget(message: 'Loading tickets...')
              else if (_tickets.isEmpty)
                Container(
                  padding: EdgeInsets.all(context.screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No support inquiries submitted yet.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tickets.length,
                  separatorBuilder: (_, index) => SizedBox(height: context.screenHeight * 0.012),
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    final subject = ticket['subject']?.toString() ?? 'Support Request';
                    final message = ticket['message']?.toString() ?? '';
                    final status = ticket['status']?.toString() ?? 'OPEN';
                    final isOpen = status == 'OPEN';

                    return Container(
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  subject,
                                  style: AppTextStyles.cardHeading.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.screenWidth * 0.02,
                                  vertical: context.screenHeight * 0.004,
                                ),
                                decoration: BoxDecoration(
                                  color: (isOpen ? AppColors.information : AppColors.success)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(context.screenWidth * 0.015),
                                ),
                                child: Text(
                                  status,
                                  style: AppTextStyles.metadata.copyWith(
                                    color: isOpen ? AppColors.information : AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.screenHeight * 0.008),
                          Text(
                            message,
                            style: AppTextStyles.supporting.copyWith(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
