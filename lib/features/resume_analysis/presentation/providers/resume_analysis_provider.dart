import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/resume_analysis_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../data/repositories/resume_repository_impl.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ResumeRepositoryImpl(client);
});

class ResumeAnalysisState {
  final bool isAnalyzing;
  final File? selectedFile;
  final String? selectedFileName;
  final ResumeAnalysisEntity? currentAnalysis;
  final List<Map<String, dynamic>> recentResumes;
  final bool isLoadingHistory;
  final String? errorMessage;

  const ResumeAnalysisState({
    this.isAnalyzing = false,
    this.selectedFile,
    this.selectedFileName,
    this.currentAnalysis,
    this.recentResumes = const [],
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  ResumeAnalysisState copyWith({
    bool? isAnalyzing,
    File? selectedFile,
    String? selectedFileName,
    ResumeAnalysisEntity? currentAnalysis,
    List<Map<String, dynamic>>? recentResumes,
    bool? isLoadingHistory,
    String? errorMessage,
    bool clearFile = false,
  }) {
    return ResumeAnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      selectedFile: clearFile ? null : (selectedFile ?? this.selectedFile),
      selectedFileName: clearFile ? null : (selectedFileName ?? this.selectedFileName),
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      recentResumes: recentResumes ?? this.recentResumes,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

class ResumeAnalysisNotifier extends StateNotifier<ResumeAnalysisState> {
  final ResumeRepository _repository;
  final Ref _ref;

  ResumeAnalysisNotifier(this._repository, this._ref) : super(const ResumeAnalysisState());

  Future<void> pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        final sizeBytes = await file.length();

        // 10 MB maximum limit
        if (sizeBytes > 10 * 1024 * 1024) {
          state = state.copyWith(errorMessage: 'Selected file exceeds maximum 10 MB limit.');
          return;
        }

        state = state.copyWith(
          selectedFile: file,
          selectedFileName: result.files.single.name,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to access file picker: $e');
    }
  }

  void clearSelectedFile() {
    state = state.copyWith(clearFile: true);
  }

  Future<ResumeAnalysisEntity?> analyzeResume({
    String? targetTitle,
    String? jobDescription,
  }) async {
    if (state.selectedFile == null) {
      state = state.copyWith(errorMessage: 'Please select a resume file first.');
      return null;
    }

    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final analysis = await _repository.uploadAndAnalyze(
        file: state.selectedFile!,
        targetTitle: targetTitle,
        jobDescription: jobDescription,
      );

      state = state.copyWith(
        isAnalyzing: false,
        currentAnalysis: analysis,
        clearFile: true,
      );

      _ref.read(authNotifierProvider.notifier).updateCredits(
        atsCredits: analysis.remainingAtsCredits,
      );

      // Refresh recent resumes
      await fetchHistory();

      return analysis;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoadingHistory: true);
    try {
      final history = await _repository.getHistory();
      state = state.copyWith(
        recentResumes: history,
        isLoadingHistory: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingHistory: false);
    }
  }
}

final resumeAnalysisProvider =
    StateNotifierProvider<ResumeAnalysisNotifier, ResumeAnalysisState>((ref) {
  final repo = ref.watch(resumeRepositoryProvider);
  return ResumeAnalysisNotifier(repo, ref);
});
