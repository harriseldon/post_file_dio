import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

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

class UltraPlainHttpUploadRepository extends UploadRepository {
  UltraPlainHttpUploadRepository({required this.client});

  final http.Client client;

  @override
  Future<int> uploadFile(XFile file) async {
    var uri =
        Uri.parse('http://localhost:25478/upload?token=f9403fc5f537b4ab332d');
    final boundary = const Uuid().v4();
    //const boundary = '----------------------c39ace087dfe7437';

    final body = '''--$boundary
Content-Disposition: form-data; name="file"; filename="${file.name}"
Content-Type: ${file.mimeType ?? 'application/octet-stream'}

${base64Encode(await file.readAsBytes())}
--$boundary
Content-Disposition: form-data; name="key"
Content-Type: text/plain;charset=UTF-8

text encoded in UTF-8
--$boundary--
       ''';

    print(body);
    final header = {'Content-Type': 'multipart/form-data;boundary="$boundary"'};
    print(header);
    var request = http.Request('POST', uri)
      ..headers.addAll(header)
      ..body = body;

    var response = await client.send(request);
    return response.statusCode;
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UltraPlainHttpUploadRepository(client: http.Client());
});
