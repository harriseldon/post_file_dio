import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

abstract class UploadRepository {
  Future<int> uploadFile(XFile file);
}

class HttpUploadRepository extends UploadRepository {
  HttpUploadRepository({required this.client});

  final Dio client;

  @override
  Future<int> uploadFile(XFile file) async {
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.name,
        contentType:
            MediaType.parse(file.mimeType ?? 'application/octet-stream'),
      ),
    });
    var response = await client.post(
        'http://localhost:25478/upload?token=f9403fc5f537b4ab332d',
        data: formData);

    return response.statusCode!;
  }
}

class PlainHttpUploadRepository extends UploadRepository {
  PlainHttpUploadRepository({required this.client});

  final http.Client client;

  @override
  Future<int> uploadFile(XFile file) async {
    var uri =
        Uri.parse('http://localhost:25478/upload?token=f9403fc5f537b4ab332d');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path,
          filename: file.name, contentType: MediaType('application', 'x-tar')));
    var response = await request.send();
    return response.statusCode;
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return PlainHttpUploadRepository(client: http.Client());
});
