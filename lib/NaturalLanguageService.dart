import 'dart:convert';
import 'package:http/http.dart' as http;

class NaturalLanguageService {
  final String apiKey = 'AIzaSyB5UkVsme5DhJOxGPCpc2SysCUueNYeGIY';

  Future<double> analyzeSentiment(String text) async {
    final url = 'https://language.googleapis.com/v1/documents:analyzeSentiment?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'document': {
          'type': 'PLAIN_TEXT',
          'content': text,
        },
        'encodingType': 'UTF8',
      }),


    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final sentimentScore = result['documentSentiment']['score'];
      return sentimentScore;


    } else {
      throw Exception('Failed to analyze sentiment: ${response.body}');
    }
  }
}
