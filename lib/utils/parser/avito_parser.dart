import 'package:avito_parser/data/models/ad_model.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as cm;
import 'package:cookie_jar/cookie_jar.dart';

class AvitoParser {
  final String baseUrl = "https://www.avito.ru";
  late DioClient _dioClient;
  late final cm.CookieManager aa;
  late final Dio dio;
  final BaseOptions dioBaseOptions = BaseOptions(
    followRedirects: true,
    contentType: 'text/html',
    headers: {
      'Host': "www.avito.ru",
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-User': '?1',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Cookie':
          'u=2ke1k54c.1hbejms.nwr5mf8q7100; buyer_laas_location=653240; buyer_location_id=653240; buyer_selected_search_radius4=0_general; showedStoryIds=116-113-112-111-108-105-104-103-99-98-97-96-94-88-83-78-71; lastViewingTime=1648304091752; buyer_selected_search_radius2=0_job; buyer_local_priority_v2=0; buyer_selected_search_radius0=200; buyer_index_tooltip=1; luri=sankt-peterburg; sx=H4sIAAAAAAAC%2FwTAQQrCMBAF0Lv8tYu0Nn%2Fycxs7k6IgRLIIaOndfSdI0sN4iMrcqGZ7uyssJ3cLoZ6YqJie%2B3d99sc%2B2u%2Fwkdbe413GJxJfZeKGhrpwU16KTNf1DwAA%2F%2F9AOHlkWwAAAA%3D%3D; f=5.3936a10c3d9034ffa5124a30bf9971d647e1eada7172e06c47e1eada7172e06c47e1eada7172e06c47e1eada7172e06cb59320d6eb6303c1b59320d6eb6303c1b59320d6eb6303c147e1eada7172e06c8a38e2c5b3e08b898a38e2c5b3e08b890df103df0c26013a7b0d53c7afc06d0b2ebf3cb6fd35a0ac7b0d53c7afc06d0b0df103df0c26013a1772440e04006defc7cea19ce9ef44010f7bd04ea141548c956cdff3d4067aa559b49948619279110df103df0c26013a2ebf3cb6fd35a0ac2da10fb74cac1eabf0c77052689da50d03c77801b122405c268a7bf63aa148d22da10fb74cac1eab2da10fb74cac1eab2da10fb74cac1eab2da10fb74cac1eab91e52da22a560f55dc5322845a0cba1a868aff1d7654931c9d8e6ff57b051a585da44bb4fa6070e8d737cef9e2f634b4938bf52c98d70e5cfad662c77e9fe3b0ff909d26121dfd199154f4aaf0a7b4f445149f3017e6f96b3ede44a7da2aee9a2ebf3cb6fd35a0ac0df103df0c26013a28a353c4323c7a3a140a384acbddd74864680d782f3408043de19da9ed218fe23de19da9ed218fe2aa6f746d757dff059427383f0d84727c52d24b309942366a; ft="k+wzl6UxNn6cBogS6Pq0iXBUzkwQw0v06pqJ/kks8nHBeiREul19sS1hgEJEwYn7gzRgbhbRcZcaGgiBa5zX+BzISEyV02Nj5qd/6geKkoVhlVeyctu1lOyj9LWXv2SVkEmmW4lFg8/ruos6HtWqmzMUhRVt+EE4inMuRiH2sDoH215uqQEKsFFiLqbTKOm8',
      'User-Agent':
          'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Pragma': 'no-cache',
      'Cache-Control': 'no-cache'
    },
  );

  Document? doc;
  bool isLoadStop = false;

  AvitoParser() {
    dio = Dio(dioBaseOptions);
    final cookieJar = CookieJar();
    aa = cm.CookieManager(cookieJar);
    dio.interceptors.add(aa);
    _dioClient = DioClient(dio);
  }

  Future<List<Ad>> getAdsListFromMainUrl(String url) async {
    List<Ad> adsList = [];
    try {
      final uri = Uri.parse(url);
      await aa.cookieJar.loadForRequest(uri);
      var res = await _dioClient.get(url);

      Document doc = parse(res);
      List<Element>? bodies = doc.querySelectorAll(
          "div[class^='iva-item-root'] div[class^='iva-item-content']");
      if (bodies.isNotEmpty) {
        bodies.forEach((element) {
          Element? link = element.querySelector("a[class^='link-link']");
          String? title = link?.text;

          String price =
              element.querySelector("span[class^='price-text']")?.text ?? "";

          String description =
              element.querySelector("div[class^='iva-item-text']")?.text ?? "";

          String? date = element.querySelector("div[class^='date-text']")?.text;

          String url = baseUrl + (link?.attributes["href"] ?? "");

          Ad ad = Ad(
              title: title ?? '',
              description: description,
              url: url,
              time: date ?? '',
              price: price,
              id: 0);

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
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
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
      throw e;
    }
  }

  // Post:----------------------------------------------------------------------
  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
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
