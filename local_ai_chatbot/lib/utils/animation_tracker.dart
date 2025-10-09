class AnimationTracker {
  static final Set<String> _animatedMessages = <String>{};
  
  static bool shouldAnimate(String messageId) {
    return !_animatedMessages.contains(messageId);
  }
  
  static void markAsAnimated(String messageId) {
    _animatedMessages.add(messageId);
  }
  
  static void clearAll() {
    _animatedMessages.clear();
  }
}