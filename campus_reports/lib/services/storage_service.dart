import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class StorageService {
  static const maxBytes = 5 * 1024 * 1024; // 5 MB

  Future<String> uploadImage(Uint8List bytes, String filename) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Upload failed (${response.statusCode}): $body');
    }
    return jsonDecode(body)['secure_url'] as String;
  }
}
