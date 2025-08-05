import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace with your Cloudinary details
  static const String cloudName = 'dpojtbeve';
  // You must set your unsigned upload preset from your Cloudinary dashboard
  static const String uploadPreset = 'revamain'; // <-- Set this value

  static Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return data['secure_url'] as String?;
    } else {
      return null;
    }
  }
}
