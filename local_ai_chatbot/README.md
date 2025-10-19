# Local AI Chatbot

A beautiful, animated Flutter chatbot powered by local AI (Qwen2.5) with interactive Rive avatar and persistent chat history.

## Features
- Animated sidebar with chat history
- Interactive Rive cat avatar (idle, thinking, celebration)
- Markdown and LaTeX rendering for AI responses
- Local chat history persistence
- Modern, responsive UI

## Screenshots

### UI + Splash Screen
<img src="screenshots/Screenshot%202025-10-19%20113706.png" alt="Main Chat Screen" width="500"/>

### Main Chat Screen
<img src="screenshots/Screenshot%202025-10-19%20113711.png" alt="Sidebar Animation" width="500"/>

### Chat History
<img src="screenshots/Screenshot%202025-10-19%20113922.png" alt="Rive Avatar Idle" width="350"/>

### Riv Chat BubbleS
<img src="screenshots/Screenshot%202025-10-19%20113940.png" alt="Rive Avatar Celebration" width="350"/>

## Getting Started
1. Clone this repo
2. Run `flutter pub get`
3. Start with `flutter run`

## Customization
- Replace `assets/animations/ai_cat.riv` with your own Rive file for custom avatar animations
- Edit `lib/widgets/rive_avatar_widget.dart` to configure state machine names and triggers

---
Made with ❤️ using Flutter and Rive
