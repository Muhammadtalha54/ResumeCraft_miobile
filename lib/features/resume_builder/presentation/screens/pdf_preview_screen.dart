import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String pdfUrl;
  final String resumeTitle;

  const PdfPreviewScreen({
    super.key,
    required this.pdfUrl,
    required this.resumeTitle,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isDownloading = false;

  Future<void> _downloadAndOpenPdf() async {
    final url = Uri.parse(widget.pdfUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Unable to download PDF. Please try again.');
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: _downloadAndOpenPdf,
              tooltip: 'Download PDF',
            ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
