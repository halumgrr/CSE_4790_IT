import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

class ChatStorageService {
  static const String _chatSessionsKey = 'chat_sessions';
  static const String _currentSessionIdKey = 'current_session_id';

  // Save all chat sessions to SharedPreferences
  static Future<void> saveChatSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sessions.map((session) => session.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_chatSessionsKey, jsonString);
    } catch (e) {
      print('Error saving chat sessions: $e');
    }
  }

  // Load all chat sessions from SharedPreferences
  static Future<List<ChatSession>> loadChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_chatSessionsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((sessionJson) => ChatSession.fromJson(sessionJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading chat sessions: $e');
      return [];
    }
  }

  // Save the current session ID
  static Future<void> saveCurrentSessionId(String? sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (sessionId != null) {
        await prefs.setString(_currentSessionIdKey, sessionId);
      } else {
        await prefs.remove(_currentSessionIdKey);
      }
    } catch (e) {
      print('Error saving current session ID: $e');
    }
  }

  // Load the current session ID
  static Future<String?> loadCurrentSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentSessionIdKey);
    } catch (e) {
      print('Error loading current session ID: $e');
      return null;
    }
  }

  // Clear all stored data (useful for testing or reset)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatSessionsKey);
      await prefs.remove(_currentSessionIdKey);
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}