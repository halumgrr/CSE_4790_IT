# Local AI Chatbot

A beautiful, animated Flutter chatbot powered by local AI (Qwen2.5) with interactive Rive avatar and persistent chat history.

## Features
- Animated sidebar with chat history
- Interactive Rive cat avatar (idle, thinking, celebration)
- Markdown and LaTeX rendering for AI responses
- Local chat history persistence
- Modern, responsive UI

## Screenshots

### Main Chat Screen
![Main Chat Screen](screenshots/Screenshot%202025-10-19%20113706.png)

### Sidebar Animation
![Sidebar Animation](screenshots/Screenshot%202025-10-19%20113711.png)

### Rive Avatar (Idle)
![Rive Avatar Idle](screenshots/Screenshot%202025-10-19%20113922.png)

### Rive Avatar (Celebration)
![Rive Avatar Celebration](screenshots/Screenshot%202025-10-19%20113940.png)

## Getting Started
1. Clone this repo
2. Run `flutter pub get`
3. Start with `flutter run`

## Customization
- Replace `assets/animations/ai_cat.riv` with your own Rive file for custom avatar animations
- Edit `lib/widgets/rive_avatar_widget.dart` to configure state machine names and triggers

---
Made with ❤️ using Flutter and Rive
