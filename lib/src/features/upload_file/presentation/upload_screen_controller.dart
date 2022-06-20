import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_file_dio/src/features/upload_file/data/upload_respository.dart';

class UploadScreenController extends StateNotifier<AsyncValue<void>> {
  UploadScreenController({
    required this.repository,
  }) : super(const AsyncData<void>(null));

  final UploadRepository repository;

  Future<void> uploadFile({required XFile file}) async {
    // set the state to loading
    state = const AsyncLoading<void>();
    // call `authRepository.signInAnonymously` and await for the result
    state = await AsyncValue.guard<void>(
      () => repository.uploadFile(file),
    );
  }
}

final uploadScreenControllerProvider =
    // StateNotifierProvider takes the controller class and state class as type arguments
    StateNotifierProvider.autoDispose<UploadScreenController, AsyncValue<void>>(
        (ref) {
  return UploadScreenController(
    repository: ref.watch(uploadRepositoryProvider),
  );
});
