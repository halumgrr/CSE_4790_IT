import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIService {
  // LM Studio default endpoint - change port if you're using a different one
  static const String _baseUrl = 'http://localhost:1234';
  static const String _chatEndpoint = '/v1/chat/completions';
  
  // Timeout for API requests
  static const Duration _timeout = Duration(seconds: 30);

  /// Send a message to the AI model and get a response
  Future<String> sendMessage(String message) async {
    try {
      final url = Uri.parse('$_baseUrl$_chatEndpoint');
      
      // Prepare the request body in OpenAI format
      final requestBody = {
        'model': 'qwen2.5-0.5b', // Adjust model name if needed
        'messages': [
          {
            'role': 'user',
            'content': message,
          }
        ],
        'temperature': 0.7,
        'max_tokens': 500,
        'stream': false,
      };

      // Make the HTTP POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(_timeout);

      // Check if the request was successful
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Extract the AI's response from the JSON
        if (jsonResponse['choices'] != null && 
            jsonResponse['choices'].isNotEmpty) {
          return jsonResponse['choices'][0]['message']['content'] ?? 
                 'No response received';
        } else {
          return 'Invalid response format';
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } on SocketException {
      return 'Connection error: Make sure LM Studio is running on localhost:1234';
    } on HttpException {
      return 'HTTP error occurred';
    } on FormatException {
      return 'Invalid response format';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Send a message and get a streaming response (word by word)
  Stream<String> sendMessageStream(String message, List<Map<String, String>> conversationHistory) async* {
    try {
      final url = Uri.parse('$_baseUrl$_chatEndpoint');
      
      // Build the full conversation context
      final messages = <Map<String, String>>[];
      
      // Add conversation history
      for (final msg in conversationHistory) {
        messages.add(msg);
      }
      
      // Add the current user message
      messages.add({
        'role': 'user',
        'content': message,
      });
      
      // Prepare the request body with streaming enabled
      final requestBody = {
        'model': 'qwen2.5-0.5b',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 500,
        'stream': true, // Enable streaming
      };

      // Make the streaming HTTP POST request
      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      });
      request.body = json.encode(requestBody);

      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        String buffer = '';
        
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;
          
          // Process complete lines
          while (buffer.contains('\n')) {
            final lineEnd = buffer.indexOf('\n');
            final line = buffer.substring(0, lineEnd).trim();
            buffer = buffer.substring(lineEnd + 1);
            
            // Skip empty lines and comments
            if (line.isEmpty || line.startsWith(':')) continue;
            
            // Handle data lines
            if (line.startsWith('data: ')) {
              final dataContent = line.substring(6);
              
              // Check for end of stream
              if (dataContent == '[DONE]') {
                break;
              }
              
              try {
                final jsonData = json.decode(dataContent);
                final choices = jsonData['choices'] as List?;
                
                if (choices != null && choices.isNotEmpty) {
                  final delta = choices[0]['delta'];
                  final content = delta['content'];
                  
                  if (content != null && content is String) {
                    yield content; // Yield each word/token as it arrives
                  }
                }
              } catch (e) {
                // Skip malformed JSON chunks
                continue;
              }
            }
          }
        }
      } else {
        yield 'Error: ${streamedResponse.statusCode} - ${streamedResponse.reasonPhrase}';
      }
    } on SocketException {
      yield 'Connection error: Make sure LM Studio is running on localhost:1234';
    } on HttpException {
      yield 'HTTP error occurred';
    } on FormatException {
      yield 'Invalid response format';
    } catch (e) {
      yield 'Unexpected error: $e';
    }
  }

  /// Test if LM Studio is running and accessible
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/v1/models');
      final response = await http.get(url).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available models from LM Studio
  Future<List<String>> getAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/v1/models');
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((model) => model['id'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}