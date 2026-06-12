import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

/// Upload d'images vers Cloudinary (preset non signé, via `http`).
///
/// Best-effort et NON bloquant : si Cloudinary n'est pas configuré, si l'appareil
/// est hors ligne, ou si l'upload échoue, la méthode renvoie `null` et l'appelant
/// poursuit sans média. (Le logo d'entité est optionnel.)
class CloudinaryService {
  const CloudinaryService();

  /// Renvoie l'URL sécurisée du média uploadé, ou `null` en cas d'échec.
  Future<String?> uploadImage(File file, {required String folder}) async {
    if (!CloudinaryConfig.isConfigured) return null;

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      if (streamed.statusCode != 200) return null;

      final body = jsonDecode(await streamed.stream.bytesToString())
          as Map<String, dynamic>;
      return body['secure_url'] as String?;
    } catch (_) {
      return null; // best-effort — jamais d'exception remontée à l'UI
    }
  }
}
