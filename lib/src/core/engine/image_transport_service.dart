import 'dart:io';
import 'package:dio/dio.dart';
import '../logging/logger_service.dart';

class ImageTransportService {
  static ImageTransportService? _instance;
  late Dio _dio;

  ImageTransportService._();

  static ImageTransportService get instance {
    _instance ??= ImageTransportService._();
    return _instance!;
  }

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ));
  }

  Future<File?> downloadPageImage(String imageUrl, Map<String, String> headers, String savePath) async {
    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data == null || response.data!.isEmpty) {
        return null;
      }
      final file = File(savePath);
      await file.create(recursive: true);
      await file.writeAsBytes(response.data!);
      return file;
    } catch (e, stack) {
      await LoggerService.instance.logError('Image download failed for $imageUrl: $e', exception: e, stackTrace: stack, category: 'ImageTransport');
      return null;
    }
  }
}
