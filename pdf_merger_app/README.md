# File Merger Pro - Android App
## Designed by Muhammad Usman

---

## APP FEATURES
- ✅ Splash Screen with "Designed By: Muhammad Usman" branding
- ✅ Merge multiple PDF files into one
- ✅ Merge Excel/CSV files (as sheets or rows)
- ✅ View & Edit PDF files (page navigation, zoom, share)
- ✅ View & Edit Excel/CSV files (cell editing, add/delete rows)
- ✅ Dark gradient UI - Professional design
- ✅ Lightweight - Won't hang your phone
- ✅ Share merged files via WhatsApp, Email etc.

---

## HOW TO BUILD APK (Free Method)

### OPTION 1: Using FlutterFlow / Codemagic (Easiest - Online)
1. Go to https://codemagic.io and sign up FREE
2. Upload this project as ZIP to GitHub
3. Connect GitHub repo to Codemagic
4. Click "Start Build" → APK is ready in ~5 minutes!

### OPTION 2: Using Android Studio (Local Build)
1. Download & Install:
   - Flutter SDK: https://flutter.dev/docs/get-started/install
   - Android Studio: https://developer.android.com/studio
   
2. Open Terminal and run:
   ```
   cd pdf_merger_app
   flutter pub get
   flutter build apk --release
   ```
   
3. APK will be at:
   `build/app/outputs/flutter-apk/app-release.apk`

### OPTION 3: Using GitHub Actions (Free CI/CD)
1. Upload project to GitHub
2. Go to Actions tab
3. APK builds automatically!

---

## PROJECT STRUCTURE
```
pdf_merger_app/
├── lib/
│   ├── main.dart                    (App entry point)
│   ├── screens/
│   │   ├── splash_screen.dart       (Designed By Muhammad Usman screen)
│   │   ├── home_screen.dart         (Main dashboard)
│   │   ├── pdf_merger_screen.dart   (PDF merge feature)
│   │   ├── excel_merger_screen.dart (Excel merge feature)
│   │   ├── pdf_editor_screen.dart   (PDF viewer/editor)
│   │   └── excel_editor_screen.dart (Excel viewer/editor)
│   └── theme/
│       └── app_theme.dart           (App styling)
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/...MainActivity.kt
└── pubspec.yaml                     (Dependencies)
```

---

## REQUIREMENTS
- Flutter 3.x or higher
- Android SDK 21+ (Android 5.0+)
- Kotlin 1.9.0

---

## DESIGNER
**Muhammad Usman**
File Merger Pro - v1.0.0
