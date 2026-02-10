import 'package:vousvous/core/services/network_service.dart';

class PincodeService {
  static Future<Map<String, String>?> fetchCityState(String pincode) async {
    try {
      final result = await NetworkClient.instance.callApi(
        'https://api.postalpincode.in/pincode/$pincode',
        MethodType.get,
        baseUrlType: BaseUrl.none,
      );

      if (result.isSuccess && result.data != null) {
        final List<dynamic> data = result.data!.data;
        if (data.isNotEmpty) {
          final status = data[0]['Status'];
          if (status == 'Success') {
            final postOffices = data[0]['PostOffice'] as List<dynamic>;
            if (postOffices.isNotEmpty) {
              final postOffice = postOffices[0];
              return {
                'city': postOffice['District'] ?? '',
                'state': postOffice['State'] ?? '',
              };
            }
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
