import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

Future<FormData> stabilityAiConstructGenerateRequestMessage({
  required XFile sourceImage,
}) async {
  Map<String, dynamic> msg = {
    "init_image": await MultipartFile.fromFile(sourceImage.path),
    "options": json.encode({
      "cfg_scale": 14,
      "width": 768,
      "height": 576,
      "samples": 1,
      "seed": 0,
      "step_schedule_start": 0.8,
      "steps": 30,
      "text_prompts": [
        {"text": "blue couch in late victorian style", "weight": 1}
      ],
    })
  };
  return FormData.fromMap(msg);
}
