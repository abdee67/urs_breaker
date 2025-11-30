# urs_breaker 🚀  
**AI-Powered Goal Breaker — From Big Dream → Actionable Steps**

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-Language-blue?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/AI-Gemini%202.5--Flash-orange?logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/UI-Shadcn%20UI-black" />
  <img src="https://img.shields.io/badge/State%20Management-Provider-purple" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
  <img src="https://img.shields.io/badge/Platforms-Mobile%20%7C%20Web%20%7C%20Desktop-success" />
</p>

`urs_breaker` helps you take a large goal and instantly break it into smaller, structured, and achievable tasks using AI.  
Built with **Flutter + Shadcn UI**, it delivers a clean, intuitive, and modern cross-platform experience.

---

## ✨ What is this?

`urs_breaker` is a cross-platform application that converts your big ideas into step-by-step actionable plans using **Gemini 2.5-Flash AI**.  
Whether you're planning a business, learning a new skill, or organizing your personal goals — this app gives you a clear roadmap.

---

## 🌟 Features

- 🤖 **AI-powered goal breakdown** via Gemini 2.5-Flash  
- 🎨 **Modern UI** built with Shadcn UI Flutter  
- 📱 **Works on all platforms**: Android, iOS, Web, Windows, macOS, Linux  
- ✏️ **Editable tasks** — refine, reorder, and customize  
- 🧠 **Provider state management**  
- ⚡ Fast, simple, clean, and minimal  
- 🔌 Easy to customize and extend

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)  
- **UI Components:** Shadcn UI Flutter  
- **AI Logic:** Gemini 2.5-Flash  
- **State Management:** Provider  
- **Platforms:** Android, iOS, Web, Windows, macOS, Linux  
- **Additional Tools:** Reusable components, animations, custom services

---

## 🧑‍💻 Getting Started — Run Locally

### 1️⃣ Clone the repository
```bash
git clone https://github.com/abdee67/urs_breaker.git
cd urs_breaker
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```

### 3️⃣ (Optional) Run build runner
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4️⃣ Set up environment variables
```bash
Create a `.env` file in the root directory and add your Gemini API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 5️⃣ Run on a specific platform
```bash
flutter run -d chrome      # Web  
flutter run -d android     # Android  
flutter run -d ios         # iOS  
flutter run -d windows     # Windows  
flutter run -d macos       # macOS  
flutter run -d linux       # Linux
```

---

## 🚀 Usage
1. Open the app
2. Type your goal (Example: “Start a clothing brand”)
3. Tap Break It Down
4. AI generates structured, actionable steps
5. Edit, customize, fine-tune

Super simple. Super fast. Super productive.
---
🖼️ Screenshots
 
 

---
### 📂 Project Structure

```
urs_breaker/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── goal.dart
│   │   ├── milestone.dart
│   │   ├── task.dart
│   │   ├── assumption.dart
│   │   └── risk.dart
│   |   ├── providers/
│   │   |── goal_provider.dart
│   ├── services/
│   │   ├── ai_service.dart
│   │   ├── database_service.dart
│   ├── ui/
│   │   ├── widgets/
│   │   │   ├── goal_card_wrapper.dart
│   │   │   └── goal_card.dart
|   |   |──home_screen.dart
├── pubspec.yaml
└── README.md
```
---

### 🗺️ Roadmap
✔️ Current Features

AI breakdown engine

Clean UI with Shadcn components

Multi-platform support

Editable tasks

---


### 📝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) for more information.

---

### 📄 Acknowledgments

- [Flutter](https://flutter.dev/)
- [Shadcn UI](https://ui.shadcn.com/)
- [Provider](https://pub.dev/packages/provider)
- [Google Generative AI](https://cloud.google.com/ai-platform/generative-ai)

---

### 📝 Contact
GitHub: https://github.com/abdee67
Project Repo: https://github.com/abdee67/urs_breaker
Email: [alaziizz67@gmail.com](mailto:alaziizz67@gmail.com)

---

### 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
