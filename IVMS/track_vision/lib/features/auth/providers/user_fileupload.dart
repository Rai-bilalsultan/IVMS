import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/legacy.dart';

class FileUploadState {
  final PlatformFile? file;
  final bool isLoading;
  final String? error;

  const FileUploadState({this.file, this.isLoading = false, this.error});

  FileUploadState copyWith({
    PlatformFile? file,
    bool? isLoading,
    String? error,
  }) {
    return FileUploadState(
      file: file ?? this.file,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FileUploadNotifier extends StateNotifier<FileUploadState> {
  FileUploadNotifier() : super(const FileUploadState());

  Future<void> pickImage() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = FileUploadState(file: result.files.single, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to pic image: $e',
      );
    }
  }

  void clear() {
    state = const FileUploadState();
  }
}

// Provider

final fileUploadProvider =
    StateNotifierProvider<FileUploadNotifier, FileUploadState>(
      (ref) => FileUploadNotifier(),
    );
