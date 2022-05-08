import 'package:avito_parser/data/models/ad_model.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as cm;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class AvitoParser {
  final String baseUrl = "https://m.avito.ru";
  late DioClient _dioClient;
  late final cm.CookieManager aa;
  late final Dio dio;
  final BaseOptions dioBaseOptions =
      BaseOptions(followRedirects: true, contentType: 'text/html', headers: {
    'authority': 'm.avito.ru',
    'pragma': 'no-cache',
    'cache-control': 'no-cache',
    'upgrade-insecure-requests': '1',
    'cookie': 'u=2ke1k54c.1hbejms.nwr5mf8q7100; buyer_laas_location=653240; buyer_location_id=653240; buyer_selected_search_radius4=0_general; showedStoryIds=128-125-124-122-121-120-116-115-113-112-111-108-105-104-103-99-98-97-96-94-88-83-78-71; lastViewingTime=1648304091752; buyer_selected_search_radius2=0_job; buyer_local_priority_v2=0; buyer_selected_search_radius0=200; buyer_index_tooltip=1; _gcl_au=1.1.491734324.1649507158; sx=H4sIAAAAAAAC%2F1zQSY7iQBBA0bvkmkVkxpAR3CZHBmMbMFTblLh7qxZIXX2Bp6%2F%2F7XwFBfLdDFGDglI1iUiA0lrO1e2%2F3Zfbu4LzbZn4eGU%2BBDOeMl3W6VBv6XW%2FBHY719zeCwNLAOT3zgWk7DOFlkysc%2FVEEk0pCYdMvX3k5wVNr3EBg2GcwvrajgeNZ1Adt3SPv%2BUQ3zuHbB2StdSFfbKGDbxKCcyIEkP%2ByDzX8TRPbbmf77fzLeGhxlSKf%2FGc56%2F0r%2ByJ8Eeu0LNR5NS01FZiCtAQxDipMulHHoJs2NdLXgb%2FWGYeifpzedh5Oj2Trr%2FkyD%2FNIiKlRukmxkJiLeaGViNDKbHaR95e4%2BM6BdZ1ZTqtrSyBH3zc%2FkCxYcD%2Fbvj3%2B28AAAD%2F%2Fwuk5fTDAQAA; v=1650474393; luri=sankt-peterburg; f=5.3936a10c3d9034ffa5124a30bf9971d647e1eada7172e06c47e1eada7172e06c47e1eada7172e06c47e1eada7172e06cb59320d6eb6303c1b59320d6eb6303c1b59320d6eb6303c147e1eada7172e06c8a38e2c5b3e08b898a38e2c5b3e08b890df103df0c26013a7b0d53c7afc06d0b2ebf3cb6fd35a0ac7b0d53c7afc06d0b0df103df0c26013a1772440e04006defc7cea19ce9ef44010f7bd04ea141548c956cdff3d4067aa559b49948619279110df103df0c26013a2ebf3cb6fd35a0ac2da10fb74cac1eabf0c77052689da50d03c77801b122405c268a7bf63aa148d22da10fb74cac1eab2da10fb74cac1eab2da10fb74cac1eab2da10fb74cac1eab91e52da22a560f553c2821b535207287de87ad3b397f946b4c41e97fe93686ad407e90ca253680a7d2c6fa8e1dbd053302c730c0109b9fbb1ef6e77b994771b7ecad4a27389d318fd21ab7cd585086e079c85f6db60e5ed79962d994edbc0bffe2415097439d404746b8ae4e81acb9fa786047a80c779d5146b8ae4e81acb9fa5c6a03abe4837df0a291fc3f0bfffdd52da10fb74cac1eabd1d953d27484fd817ed5998d424268d242675c392d3f8418; ft="pT8xuJ/U7fHc5f1Ai7lipn7YtO6ho5V1F2xZvlN44KuTE6t1Ac7EGdwEVJOR3B+FH8lS+L3Cs+TrWRX35HS4xVuTAsMPNUxk5Gd2B59NHOOaZYV8P8f/utDKEfrDS/YcKzph3+5QqJEHwRzLlNScfxo8raONf8PlRiJeH0O7O8GchedsApPyTqJjJ3LA1j5c"; SEARCH_HISTORY_IDS=1%2C4%2C%2C0%2C2; dfp_group=32; buyer_from_page=catalog',
    'user-agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Mobile Safari/537.36',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'sec-fetch-site': 'none',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-user': '?1',
    'sec-fetch-dest': 'document',
    'accept-language': 'ru-RU,ru;q=0.9',
  });

  Document? doc;
  bool isLoadStop = false;

  AvitoParser() {
    getTemporaryDirectory().then((dir) {
      dio = Dio(dioBaseOptions);
      var cj = PersistCookieJar(
          ignoreExpires: true, storage: FileStorage(dir.path + '/tmp_data'));
      aa = cm.CookieManager(cj);
      dio.interceptors.add(aa);
      _dioClient = DioClient(dio);
    });
  }

  Future<List<Ad>> getAdsListFromMainUrl(String url) async {
    await Future.delayed(Duration(milliseconds: 100));
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
