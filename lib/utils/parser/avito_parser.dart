import 'package:avito_parser/data/models/ad_model.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class AvitoParser {
  final String baseUrl = "https://www.avito.ru";
  DioClient _dioClient = DioClient(Dio());

  Future<List<Ad>> getAdsListFromMainUrl(String url) async {
    List<Ad> adsList = [];

    try {
      var res = await _dioClient.get(url);

      Document doc = parse(res);
      List<Element> bodies = doc.querySelectorAll(
          "div[class^='iva-item-root'] div[class^='iva-item-body']");
      if (bodies != null && bodies.isNotEmpty) {
        bodies.forEach((element) {
          Element link = element.querySelector("a[class^='link-link']");
          String title = link?.text;

          String price =
              element.querySelector("span[class^='price-text']")?.text ?? "";

          String description =
              element.querySelector("div[class^='iva-item-text']")?.text ?? "";

          String date = element.querySelector("div[class^='date-text']").text;

          String url = baseUrl + link.attributes["href"];

          Ad ad = Ad(
              title: title,
              description: description,
              url: url,
              time: date,
              price: price);

          adsList.add(ad);
        });
      }
    } catch (e) {
      print(e);
    }

    return adsList;
  }
}

class DioClient {
  // dio instance
  final Dio _dio;

  // injecting dio instance
  DioClient(this._dio);

  // Get:-----------------------------------------------------------------------
  Future<dynamic> get(
    String uri, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  // Post:----------------------------------------------------------------------
  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
