import 'dart:convert';
import 'dart:io';

class PhotoUtil {
  static final httpClient = HttpClient();

  static List list = [];
  static int currentPage = 0;
  static var year = DateTime.now().year;
  static var month = DateTime.now().month;

  static Future<List> queryPhoto({int pageNo, bool clear}) async {
    if (pageNo != null) {
      currentPage = pageNo;
    } else {
      currentPage++;
    }
    if (clear != null && clear) {
      list.clear();
    }

    try {
      var uri = Uri.https('photos.oneplus.com', '/cn/schedule', {
        'currentPage': currentPage.toString(),
        'month': '$year/${month.toString().padLeft(2, '0')}',
        '_': DateTime.now().millisecondsSinceEpoch.toString()
      });
      var request = await httpClient.getUrl(uri);
      request.headers.add('Host', 'photos.oneplus.com');
      request.headers.add('Referer', 'https://photos.oneplus.com/cn/gallery');
      request.headers.add('User-Agent',
          'Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30');
      var response = await request.close().timeout(const Duration(seconds: 5));
      var responseBody = await response.transform(utf8.decoder).join();
      Map data = json.decode(responseBody);
      List photos = data['data']['photos'];
      if (photos == null) {
        if (month == 1) {
          // 如果是1月，则设置为去年的12月
          year--;
          month = 12;
        } else {
          // 查询完成后，月份设置成上个月
          month--;
        }
        // 页码从头开始
        currentPage = 0;
        photos = await queryPhoto();
      }
      list.addAll(photos);
    } catch (e) {
      print(e);
    }
    return list;
  }
}
