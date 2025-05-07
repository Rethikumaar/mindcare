import 'dart:convert';
import 'package:http/http.dart' as http;

class PHQ9Service {
  static const String _baseUrl = 'https://akash297-mindcare.hf.space';

  Future<bool> submitResponses(String userId, List<int?> responses) async {
    final Uri submitUrl = Uri.parse('$_baseUrl/api/submit_phq9/');
    try {
      final response = await http.post(
        submitUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': userId,
          'responses': responses,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Submit error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchLatestResult(String userId) async {
    final Uri resultUrl = Uri.parse('$_baseUrl/api/phq9_results/?user_id=$userId');
    try {
      final response = await http.get(resultUrl);
      if (response.statusCode != 200) {
        print('Fetch failed: ${response.statusCode}');
        return null;
      }

      final List<dynamic> resultList = jsonDecode(response.body);
      if (resultList.isEmpty) return null;

      final result = resultList[0];
      return {
        'responses': result['responses'],
        'score': result['score'],
        'prediction': result['prediction'],
        'timestamp': result['timestamp'],
      };
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }
}
