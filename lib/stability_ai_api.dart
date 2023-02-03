import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stability_ai_issue/global_variables.dart';
import 'construct_request_message.dart';

enum ApiMapVars {
  success,
  statusCode,
  predictionUrl,
  cancelUrl,
  responseBody,
  resultUrl,
  error,
  cancelled,
}

class StabilityAiApi {
  static Future<Map<ApiMapVars, dynamic>> generateImage({
    required XFile sourceImage,
  }) async {
    String genImageEndpoint =
        "$stabilityAiApiEndpoint/generation/$currentStabilityAiApiEngine/image-to-image";

    Response<dynamic>? response;
    var dio = Dio(BaseOptions(receiveDataWhenStatusError: true))
      ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    var formData = await stabilityAiConstructGenerateRequestMessage(
        sourceImage: sourceImage);
    try {
      response = await dio
          .post(
            genImageEndpoint,
            data: formData,
            options: Options(
              // responseType: ResponseType.bytes,
              headers: {
                "Content-Type": "multipart/form-data",
                "Authorization": 'Token $apiKey',
                "accept": "image/png",
              },
            ),
          )
          .timeout(const Duration(minutes: 1));
      debugPrint(
          "StabilityAiApi: generateImage: RESPONSE STATUS CODE: ${response.statusCode}");
      return {
        ApiMapVars.success: true,
        ApiMapVars.statusCode: response.statusCode ?? 0,
        ApiMapVars.responseBody: response.data
      };
    } on DioError catch (e) {
      Map<ApiMapVars, dynamic> resultMap = {ApiMapVars.success: false};
      switch (e.type) {
        case DioErrorType.cancel:
          resultMap[ApiMapVars.cancelled] = true;
          break;
        case DioErrorType.response:
          resultMap[ApiMapVars.statusCode] = e.response?.statusCode ?? 0;
          resultMap[ApiMapVars.responseBody] = e.response?.data ?? '';
          break;
        case DioErrorType.connectTimeout:
          resultMap[ApiMapVars.error] = "Connection timeout";
          break;
        case DioErrorType.receiveTimeout:
          resultMap[ApiMapVars.error] = "Receiving data timeout";
          break;
        default:
          resultMap[ApiMapVars.error] = "Misc error";
      }
      debugPrint("StabilityAiApi: generateImage: ERROR: $resultMap");
      return resultMap;
    } on TimeoutException catch (e) {
      debugPrint("StabilityAiApi: generateImage: TIMEOUT: $e");
      return {
        ApiMapVars.success: false,
        ApiMapVars.error: "Connection timeout"
      };
    } catch (e) {
      debugPrint("StabilityAiApi: generateImage: ERROR: $e");
      return {ApiMapVars.success: false, ApiMapVars.error: "Misc error"};
    }
  }
}
