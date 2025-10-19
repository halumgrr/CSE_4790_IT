# Local AI Chatbot

A beautiful, animated Flutter chatbot powered by local AI (Qwen2.5) with interactive Rive avatar and persistent chat history.

## Screenshots

| Main Chat Screen | Sidebar Animation | Rive Avatar (Idle) | Rive Avatar (Celebration) |
|------------------|------------------|--------------------|---------------------------|
| ![Splash Screen](screenshots/Screenshot%202025-10-19%20113706.png) | ![Chat Landing Page](screenshots/Screenshot%202025-10-19%20113711.png) | ![Sidebar History](screenshots/Screenshot%202025-10-19%20113922.png) | ![Rive Chatbubble + Markdown](screenshots/Screenshot%202025-10-19%20113940.png) |

## Features
- Animated sidebar with chat history
- Interactive Rive cat avatar (idle, thinking, celebration)
- Markdown and LaTeX rendering for AI responses
- Local chat history persistence
- Modern, responsive UI

## Getting Started
1. Clone this repo
2. Run `flutter pub get`
3. Start with `flutter run`

## Customization
- Replace `assets/animations/ai_cat.riv` with your own Rive file for custom avatar animations
- Edit `lib/widgets/rive_avatar_widget.dart` to configure state machine names and triggers

---
Made with ❤️ using Flutter and Rive
