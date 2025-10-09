import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/animation_tracker.dart';
import 'message_renderer.dart';

class AnimatedMessageBubble extends StatefulWidget {
  final Message message;
  final int index;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.index,
    this.shouldAnimate = false,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)), // Staggered timing
      vsync: this,
    );

    // Different slide directions for user vs AI
    final slideDirection = widget.message.isUser 
        ? const Offset(1.0, 0.0)  // Slide from right for user
        : const Offset(-1.0, 0.0); // Slide from left for AI

    _slideAnimation = Tween<Offset>(
      begin: widget.shouldAnimate ? slideDirection : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: widget.shouldAnimate ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Start animation with delay based on index, but only if shouldAnimate is true
    if (widget.shouldAnimate) {
      Future.delayed(Duration(milliseconds: widget.index * 150), () {
        if (mounted) {
          _controller.forward().then((_) {
            // Mark this message as animated globally
            AnimationTracker.markAsAnimated(widget.message.id);
            // Notify parent that animation is complete
            if (widget.onAnimationComplete != null) {
              widget.onAnimationComplete!();
            }
          });
        }
      });
    } else {
      // If not animating, set to completed state immediately
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: widget.message.isUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.message.isUser) ...[
                // AI Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Message Content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: widget.message.isUser
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: widget.message.isUser
                        ? null
                        : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: widget.message.isUser 
                          ? const Radius.circular(20) 
                          : const Radius.circular(6),
                      bottomRight: widget.message.isUser 
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
                  child: MessageRenderer(
                    text: widget.message.text,
                    isUser: widget.message.isUser,
                  ),
                ),
              ),
              if (widget.message.isUser) ...[
                const SizedBox(width: 12),
                // User Avatar
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
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}