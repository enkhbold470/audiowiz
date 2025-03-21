# AudioWiz

AudioWiz is a Flutter application that records audio from lectures or meetings, transcribes it, and generates concise summaries.

## Features

- Record audio from lectures, meetings, or any other spoken content
- Use local speech-to-text recognition for transcription
- Generate concise summaries of the transcribed content
- Browse, search, and organize your recordings
- Share transcriptions and summaries

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Android Studio / Xcode for mobile deployment
- A physical device (for recording functionality)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/audiowiz.git
cd audiowiz
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Project Structure

```
lib/
├── core/ # Core utilities, services, and models
│   ├── constants/ # App constants and theme configuration
│   ├── models/ # Data models
│   ├── services/ # Services for recording, transcription, database
│   └── utils/ # Utility functions
├── features/ # Feature modules
│   ├── recording/ # Recording feature
│   ├── transcription/ # Transcription feature
│   ├── summary/ # Summary feature
│   └── history/ # History and saved recordings feature
└── shared/ # Shared components
    ├── widgets/ # Reusable widgets
    └── providers/ # Global state providers
```

## Usage

1. Open the app and tap the microphone button to start recording
2. Speak clearly or place the device near the speaker
3. Tap the stop button when finished
4. Enter a title for your recording
5. Choose to transcribe now or later
6. View the transcription and generate a summary
7. Share or export your transcriptions and summaries

## Technical Details

AudioWiz uses the following technologies:

- **Flutter and Dart** for cross-platform app development
- **Riverpod** for state management
- **SQLite** for local database storage
- **Speech-to-text** for audio transcription
- **Natural language processing** for summarization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter and Dart team for the amazing framework
- Contributors to the open-source libraries used in this project
