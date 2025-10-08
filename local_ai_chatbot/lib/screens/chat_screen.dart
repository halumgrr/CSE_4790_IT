import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/ai_service.dart';
import '../services/chat_storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  bool _isLoading = false;
  bool _sidebarOpen = false;
  
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  Future<void> _loadSavedChats() async {
    try {
      final savedSessions = await ChatStorageService.loadChatSessions();
      final currentSessionId = await ChatStorageService.loadCurrentSessionId();
      
      if (savedSessions.isNotEmpty) {
        setState(() {
          _chatSessions = savedSessions;
          
          // Try to restore the current session
          if (currentSessionId != null) {
            _currentSession = _chatSessions.firstWhere(
              (session) => session.id == currentSessionId,
              orElse: () => _chatSessions.first,
            );
          } else {
            _currentSession = _chatSessions.first;
          }
        });
      } else {
        // No saved chats, create a new one
        _createNewChat();
      }
    } catch (e) {
      print('Error loading saved chats: $e');
      // If there's an error, create a new chat
      _createNewChat();
    }
  }

  void _createNewChat() {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      messages: [
        Message(text: "Hello! I'm Sage, your AI companion powered by Qwen2.5. How can I help you today?", isUser: false),
      ],
    );

    setState(() {
      _chatSessions.insert(0, newSession);
      _currentSession = newSession;
      _isLoading = false;
    });
    _messageController.clear();
    _scrollToBottom();
    
    // Save to storage
    _saveChatsToStorage();
  }

  Future<void> _saveChatsToStorage() async {
    await ChatStorageService.saveChatSessions(_chatSessions);
    await ChatStorageService.saveCurrentSessionId(_currentSession?.id);
  }

  void _selectChat(ChatSession session) {
    setState(() {
      _currentSession = session;
      _sidebarOpen = false;
    });
    _scrollToBottom();
    
    // Save current session to storage
    ChatStorageService.saveCurrentSessionId(session.id);
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
    });
  }

  void _deleteChat(ChatSession session) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: Text(
            'Are you sure you want to delete this conversation?\n\n"${session.preview}"\n\nThis action cannot be undone.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _chatSessions.removeWhere((s) => s.id == session.id);
      
      // If we deleted the current session, select another one or create new
      if (_currentSession?.id == session.id) {
        if (_chatSessions.isNotEmpty) {
          _currentSession = _chatSessions.first;
        } else {
          // No chats left, create a new one
          _createNewChat();
          return;
        }
      }
    });
    
    // Save to storage after deletion
    _saveChatsToStorage();
  }

  void _showChatContextMenu(BuildContext context, ChatSession session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chat Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[600]),
                title: const Text('Delete Chat'),
                subtitle: const Text('This action cannot be undone'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteChat(session);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentSession == null) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message to current session
    setState(() {
      _currentSession!.messages.add(Message(text: userMessage, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Build conversation history for context
      final conversationHistory = <Map<String, String>>[];
      
      // Add previous messages (excluding the current user message we just added)
      for (int i = 0; i < _currentSession!.messages.length - 1; i++) {
        final msg = _currentSession!.messages[i];
        conversationHistory.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      // Add placeholder for AI response
      setState(() {
        _currentSession!.messages.add(Message(text: '', isUser: false));
        _isLoading = false;
      });

      String accumulatedResponse = '';
      final aiMessageIndex = _currentSession!.messages.length - 1;

      // Listen to the streaming response
      await for (final chunk in _aiService.sendMessageStream(userMessage, conversationHistory)) {
        accumulatedResponse += chunk;
        
        // Update the AI message with accumulated text
        setState(() {
          _currentSession!.messages[aiMessageIndex] = Message(text: accumulatedResponse, isUser: false);
          // Update the session in the list
          final sessionIndex = _chatSessions.indexWhere((s) => s.id == _currentSession!.id);
          if (sessionIndex != -1) {
            _chatSessions[sessionIndex] = _currentSession!.copyWith(messages: _currentSession!.messages);
          }
        });
        
        _scrollToBottom();
      }
    } catch (e) {
      // Handle errors
      setState(() {
        if (_currentSession!.messages.isNotEmpty && !_currentSession!.messages.last.isUser) {
          // Update the last AI message with error
          _currentSession!.messages[_currentSession!.messages.length - 1] = Message(
            text: "Sorry, I couldn't process your message. Please make sure LM Studio is running and try again.",
            isUser: false,
          );
        } else {
          // Add new error message
          _currentSession!.messages.add(Message(
            text: "Sorry, I couldn't process your message. Please make sure LM Studio is running and try again.",
            isUser: false,
          ));
        }
        _isLoading = false;
      });
    }
    
    _scrollToBottom();
    
    // Save conversation after sending message
    _saveChatsToStorage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (_sidebarOpen)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Sidebar Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Chat History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _createNewChat,
                          tooltip: 'New Chat',
                        ),
                      ],
                    ),
                  ),
                  // Chat List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        final isActive = _currentSession?.id == session.id;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              // Show context menu on long press
                              if (_chatSessions.length > 1) {
                                _showChatContextMenu(context, session);
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(
                                session.preview,
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                session.timeAgo,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () => _selectChat(session),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isActive)
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  if (isActive) const SizedBox(width: 8),
                                  // Only show delete button if there's more than one chat
                                  if (_chatSessions.length > 1)
                                    GestureDetector(
                                      onTap: () => _deleteChat(session),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Main Chat Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // App Bar
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: _toggleSidebar,
                            tooltip: 'Toggle Sidebar',
                          ),
                          const Expanded(
                            child: Text(
                              'Sage',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
                            onPressed: _createNewChat,
                            tooltip: 'New Chat',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Chat Messages
                  Expanded(
                    child: _currentSession == null 
                      ? const Center(
                          child: Text(
                            'Select a chat to start conversation',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _currentSession!.messages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _currentSession!.messages.length && _isLoading) {
                              return _buildLoadingIndicator();
                            }
                            final message = _currentSession!.messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
                  ),
                  
                  // Message Input
                  if (_currentSession != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Ask Sage anything...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _isLoading ? null : _sendMessage(),
                              textInputAction: TextInputAction.send,
                              enabled: !_isLoading,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              onPressed: _isLoading ? null : _sendMessage,
                              icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                    : null,
                color: message.isUser
                    ? null
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(20) 
                      : const Radius.circular(6),
                  bottomRight: message.isUser 
                      ? const Radius.circular(6) 
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sage is thinking...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}