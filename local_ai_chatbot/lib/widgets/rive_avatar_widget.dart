import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

enum AvatarState {
  idle,       // Default state - gentle breathing/blinking
  thinking,   // When AI is generating response - hand gestures
  celebrating // When response is complete - jumping/happy gesture
}

class RiveAvatarWidget extends StatefulWidget {
  final AvatarState state;
  final double size;
  final Duration transitionDuration;
  final VoidCallback? onTap;

  const RiveAvatarWidget({
    super.key,
    required this.state,
    this.size = 40.0,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  State<RiveAvatarWidget> createState() => _RiveAvatarWidgetState();
}

class _RiveAvatarWidgetState extends State<RiveAvatarWidget> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<bool>? _idleInput;
  SMIInput<bool>? _thinkingInput;
  SMIInput<bool>? _celebratingInput;
  SMITrigger? _celebrateTrigger;

  AvatarState _currentState = AvatarState.idle;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  void _loadRiveFile() async {
    try {
      final data = await RiveFile.asset('assets/animations/ai_cat.riv');
      final artboard = data.mainArtboard;
      
      // Try to get the state machine controller
      // Note: Replace 'State Machine 1' with your actual state machine name
      var controller = StateMachineController.fromArtboard(
        artboard, 
        'State Machine 1', // Replace with your state machine name
      );
      
      if (controller != null) {
        artboard.addController(controller);
        
        // Get inputs - replace these names with your actual input names
        _idleInput = controller.findInput<bool>('idle') as SMIBool?;
        _thinkingInput = controller.findInput<bool>('thinking') as SMIBool?;
        _celebratingInput = controller.findInput<bool>('celebrating') as SMIBool?;
        _celebrateTrigger = controller.findSMI('celebrate') as SMITrigger?;
      } else {
        print('State machine controller not found. Available state machines: ${artboard.stateMachines.map((sm) => sm.name).toList()}');
      }

      if (mounted) {
        setState(() {
          _riveArtboard = artboard;
          _controller = controller;
        });
        
        // Set initial state
        _updateAnimationState(widget.state);
      }
    } catch (e) {
      print('Error loading Rive file: $e');
      // File doesn't exist or is invalid - widget will show fallback
      if (mounted) {
        setState(() {
          _riveArtboard = null;
          _controller = null;
        });
      }
    }
  }

  void _updateAnimationState(AvatarState newState) {
    if (_controller == null) return;
    
    // Reset all states
    _idleInput?.value = false;
    _thinkingInput?.value = false;
    _celebratingInput?.value = false;

    // Set the appropriate state
    switch (newState) {
      case AvatarState.idle:
        _idleInput?.value = true;
        break;
      case AvatarState.thinking:
        _thinkingInput?.value = true;
        break;
      case AvatarState.celebrating:
        _celebratingInput?.value = true;
        // Trigger celebration animation
        _celebrateTrigger?.fire();
        
        // Auto-return to idle after celebration
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _currentState == AvatarState.celebrating) {
            _updateAnimationState(AvatarState.idle);
            setState(() {
              _currentState = AvatarState.idle;
            });
          }
        });
        break;
    }
    
    _currentState = newState;
  }

  @override
  void didUpdateWidget(RiveAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimationState(widget.state);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.transitionDuration,
          width: widget.size,
          height: widget.size,
          transform: _isHovered 
              ? (Matrix4.identity()..scale(1.1))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size / 2),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor(),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: _riveArtboard == null
                ? _buildFallbackAvatar()
                : Rive(
                    artboard: _riveArtboard!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  Color _getShadowColor() {
    switch (widget.state) {
      case AvatarState.idle:
        return Colors.black.withOpacity(0.1);
      case AvatarState.thinking:
        return Colors.blue.withOpacity(0.3);
      case AvatarState.celebrating:
        return Colors.green.withOpacity(0.3);
    }
  }

  Widget _buildFallbackAvatar() {
    // Fallback widget when Rive file fails to load
    return Container(
      decoration: BoxDecoration(
        color: _getFallbackColor(),
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
      child: Icon(
        _getFallbackIcon(),
        color: Colors.white,
        size: widget.size * 0.6,
      ),
    );
  }

  Color _getFallbackColor() {
    switch (widget.state) {
      case AvatarState.idle:
        return Colors.grey[400]!;
      case AvatarState.thinking:
        return Colors.blue[400]!;
      case AvatarState.celebrating:
        return Colors.green[400]!;
    }
  }

  IconData _getFallbackIcon() {
    switch (widget.state) {
      case AvatarState.idle:
        return Icons.smart_toy;
      case AvatarState.thinking:
        return Icons.psychology;
      case AvatarState.celebrating:
        return Icons.celebration;
    }
  }
}

// Helper widget for easy state management in parent widgets
class AnimatedAIAvatar extends StatefulWidget {
  final bool isTyping;
  final bool justFinished;
  final double size;
  final VoidCallback? onTap;

  const AnimatedAIAvatar({
    super.key,
    this.isTyping = false,
    this.justFinished = false,
    this.size = 40.0,
    this.onTap,
  });

  @override
  State<AnimatedAIAvatar> createState() => _AnimatedAIAvatarState();
}

class _AnimatedAIAvatarState extends State<AnimatedAIAvatar> {
  AvatarState _currentState = AvatarState.idle;
  bool _celebrationShown = false;

  @override
  void didUpdateWidget(AnimatedAIAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isTyping && !oldWidget.isTyping) {
      // Started typing
      setState(() {
        _currentState = AvatarState.thinking;
        _celebrationShown = false;
      });
    } else if (!widget.isTyping && oldWidget.isTyping && widget.justFinished && !_celebrationShown) {
      // Just finished typing
      setState(() {
        _currentState = AvatarState.celebrating;
        _celebrationShown = true;
      });
      
      // Return to idle after celebration
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentState = AvatarState.idle;
          });
        }
      });
    } else if (!widget.isTyping && !widget.justFinished) {
      // Normal idle state
      setState(() {
        _currentState = AvatarState.idle;
        _celebrationShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiveAvatarWidget(
      state: _currentState,
      size: widget.size,
      onTap: widget.onTap,
    );
  }
}