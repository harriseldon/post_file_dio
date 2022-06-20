import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_file_dio/src/features/upload_file/presentation/upload_screen_controller.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> state = ref.watch(uploadScreenControllerProvider);
    print(state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload a file'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            padding: EdgeInsets.all(12),
            textStyle: TextStyle(fontSize: 22),
          ),
          onPressed: () {
            state.maybeWhen(
                loading: null,
                orElse: () {
                  _uploadFile(ref);
                });
          },
          child: state.maybeWhen(
            loading: () => const CircularProgressIndicator(),
            orElse: () => const Text('Upload File'),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile(WidgetRef ref) async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );

    print('Opening the file');
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file != null) {
      ref.read(uploadScreenControllerProvider.notifier).uploadFile(file: file);
    }
  }
}
