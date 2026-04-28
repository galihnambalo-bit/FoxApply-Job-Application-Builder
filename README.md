# 🦊 FoxApply – Smart Job Application Builder

[![Build APK](https://github.com/YOUR_USERNAME/foxapply/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/foxapply/actions/workflows/build.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-orange)](LICENSE)

> Create a complete job application package in **one PDF file** — in seconds.

---

## 📱 Features

| Feature | Description |
|---|---|
| 📝 **CV Builder** | Modern CV with photo (top-right), templates |
| ✉️ **Cover Letter** | Dynamic template, no AI needed |
| 📷 **Document Scanner** | Camera + auto-crop + B&W filter |
| 📦 **PDF Package** | Merge everything into 1 final PDF |
| 🌍 **Multi-language** | English (default) + Bahasa Indonesia |

## 🧱 Architecture

```
FoxApply
├── UI Layer          → Flutter Widgets
├── Controller Layer  → GetX Controllers  
├── Service Layer     → PDF, Scanner, Storage
├── Engine Layer      → CV Generator, Letter Generator, PDF Merger
└── Storage Layer     → SharedPreferences (local only)
```

## 🔄 User Flow

```
1. Input personal data & upload photo
2. Add education, experience, skills
3. Set target job & company
4. Scan supporting documents
5. Tap "Generate Package" 🦊
6. Download / Share final PDF
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10+
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Install & Run

```bash
# Clone
git clone https://github.com/YOUR_USERNAME/foxapply.git
cd foxapply

# ⬇️ Download font Poppins otomatis (WAJIB untuk build lokal)
mkdir -p assets/fonts
BASE="https://github.com/google/fonts/raw/main/ofl/poppins"
curl -fsSL "$BASE/Poppins-Regular.ttf"  -o assets/fonts/Poppins-Regular.ttf
curl -fsSL "$BASE/Poppins-Medium.ttf"   -o assets/fonts/Poppins-Medium.ttf
curl -fsSL "$BASE/Poppins-SemiBold.ttf" -o assets/fonts/Poppins-SemiBold.ttf
curl -fsSL "$BASE/Poppins-Bold.ttf"     -o assets/fonts/Poppins-Bold.ttf

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run
flutter run
```

> 💡 **Font otomatis di GitHub:** Saat build di GitHub Actions, font Poppins
> didownload **otomatis** — tidak perlu upload ke repository sama sekali.

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release
```

## 🏗️ GitHub Actions (Auto Build)

Every push to `main` automatically builds:
- ✅ Debug APK
- ✅ Release APK  
- ✅ Release AAB

Download from **Actions** tab → latest workflow run → **Artifacts**.

For releases, tag your commit:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## 📂 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── theme/app_theme.dart
│   └── utils/
│       ├── cv_generator.dart       ← generateCV()
│       ├── letter_generator.dart   ← generateSurat()
│       └── pdf_merger.dart         ← mergePDF() + generateFinalPackage()
├── data/
│   ├── models/user_profile.dart
│   └── repositories/storage_repository.dart
├── l10n/
│   ├── app_en.arb                  ← English strings
│   └── app_id.arb                  ← Indonesian strings
└── presentation/
    ├── controllers/app_controller.dart
    ├── screens/
    │   ├── home/home_screen.dart
    │   ├── cv_builder/cv_builder_screen.dart
    │   ├── cover_letter/cover_letter_screen.dart
    │   ├── scanner/scanner_screen.dart
    │   └── pdf_preview/pdf_preview_screen.dart
    └── widgets/
        ├── step_card.dart
        └── fox_button.dart
```

## 🌍 Localization

Switch language in: **Settings → Language**

Supported:
- 🇬🇧 English (default)
- 🇮🇩 Bahasa Indonesia

To add more languages:
1. Create `lib/l10n/app_XX.arb` (XX = locale code)
2. Add to `supportedLocales` in `main.dart`

## 🔐 Permissions

| Permission | Usage |
|---|---|
| `CAMERA` | Document scanning |
| `READ_MEDIA_IMAGES` | Photo picker |
| `READ/WRITE_EXTERNAL_STORAGE` | Save PDF output |

> **Privacy**: All data stays on your device. Nothing is uploaded to any server.

## 📦 Play Store Requirements

- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **Icon**: Replace `assets/images/icon_1024.png` with your 1024×1024 icon
- **Min SDK**: API 21 (Android 5.0)

## 🧪 Core Functions

```dart
// Generate CV PDF
CVGenerator.generateCV(profile, template, locale)

// Generate Cover Letter PDF  
LetterGenerator.generateCoverLetter(profile, job, locale)

// Convert scanned images to PDF
PdfMerger.imagesToPdf(docs)

// Generate final merged package
PackageGenerator.generateFinalPackage(pdfPages, fileName)
```

## 📄 License

MIT License — see [LICENSE](LICENSE)

---

**Made with 🦊 for job seekers everywhere**
