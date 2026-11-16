import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../resume_analysis/presentation/providers/resume_analysis_provider.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String resumeTitle;

  const PdfPreviewScreen({
    super.key,
    required this.pdfUrl,
    required this.resumeTitle,
  });

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(resumeRepositoryProvider);
      final bytes = await repo.exportResumePdfBytes(widget.pdfUrl);
      if (mounted) {
        setState(() {
          _pdfBytes = Uint8List.fromList(bytes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _downloadAndOpenPdf() async {
    if (_pdfBytes == null) {
      AppSnackbar.error(context, 'PDF is still loading. Please wait.');
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedTitle = widget.resumeTitle.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final fileName = 'Resume_$sanitizedTitle.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(_pdfBytes!, flush: true);

      if (mounted) {
        AppSnackbar.success(context, 'PDF downloaded successfully! Opening...');
      }

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        AppSnackbar.info(context, 'Saved to: ${file.path}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Unable to open file: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text(widget.resumeTitle),
        actions: [
          if (_isDownloading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          else if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: _downloadAndOpenPdf,
              tooltip: 'Save & Open PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Rendering ATS Resume PDF...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Unable to load PDF preview',
                style: AppTextStyles.cardHeading,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.supporting,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchPdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_pdfBytes != null) {
      return SfPdfViewer.memory(
        _pdfBytes!,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      );
    }

    return const SizedBox.shrink();
  }
}
