# ResumeCraft AI (OptimizAI) Mobile Application

A production-quality Flutter mobile application for an AI-powered resume and job platform. Built with a minimalist, premium, light-mode modern SaaS UI with smooth interactions, clear visual hierarchy, refined typography, and responsive sizing.

---

## 🎨 Design System & Theme
- **Color Palette**: Sophisticated dark-green & warm-cream design direction
  - Primary: `#174D3A`
  - Primary Dark: `#103B2C`
  - Primary Light: `#E5F0E9`
  - Main Background: `#FAF9F6`
  - Card & Surface: `#FFFFFF`
  - Secondary Surface: `#F3F1EB`
  - Main Text: `#202923`
  - Secondary Text: `#6D776F`
  - Border: `#E6E8E3`
- **Typography**: Inter hierarchy with predefined font weights and sizes in `AppTextStyles`.
- **Responsive Sizing**: `context.screenHeight * value` and `context.screenWidth * value` via `size_extensions.dart`.
- **Localization-ready**: Centralized text system via `Lang` constants.

---

## 🏗 Architecture & Stack
- **State Management**: Flutter Riverpod (`StateNotifierProvider`)
- **Routing & Navigation**: GoRouter with `StatefulShellRoute` for 4 persistent bottom tabs (`AppNavigation` facade)
- **Networking**: Dio with `AuthInterceptor`, automated token refresh queue, and typed domain error mapping
- **Local Storage**: `FlutterSecureStorage` for sensitive JWT tokens & `SharedPreferences` for onboarding flags
- **Clean Architecture Pattern**:
  - `Presentation`: Screens, Widgets, Riverpod Notifiers & States
  - `Domain`: Entities, Value Objects, Repository Interfaces
  - `Data`: DTO Models, Remote Data Sources, Repository Implementations

---

## 📱 Core Features & Screens
1. **Bootstrap & Splash**: Auto-checks session validity, refresh tokens, and onboarding status.
2. **Onboarding**: 3-step high-converting onboarding carousel with persistent completion flag.
3. **Authentication**: Login, Registration, and Forgot Password (supporting both 6-digit OTP and reset link).
4. **Home & ATS Analysis**:
   - Live resume upload (`.pdf`, `.docx`)
   - Custom ATS score gauge widget
   - Breakdown of match scores, strengths, improvement areas, and missing keywords
5. **AI Resume Studio**:
   - Real dynamic templates fetched from backend (`/api/templates`)
   - Template carousel with real thumbnails (`ats.png`, `modern.png`, `resume-template.png`, `basic.png`, `enterprise.png`, `pro.png`)
   - Strategy selection (ATS Optimized, Executive, Creative, Technical)
   - Real-time AI resume tailoring and PDF preview/export
6. **Live Job Search**:
   - Real-time job scraper integration (`/api/jobs/search`)
   - Filter by query, location, and job type (Full-time, Remote, Contract, Part-time)
   - Direct external application tracking and browser launching
7. **Profile & Account**:
   - User credentials, AI credit counter, and plan badges
   - Navigation to Resume History archive, Support tickets, and Legal terms
   - Secure sign-out with token purging

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.24+ (Tested on Flutter 3.47.4 / Dart 3.13.3)
- ResumeCraft Backend running on port 5000 (`d:\resumecraft\resume-craft-backend`)

### Running the Application
```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit & widget tests
flutter test

# Launch on Android Emulator or Connected Device
flutter run
```

### Network Configuration
- **Android Emulator**: Automatically routes to `http://10.0.2.2:5000/api`
- **iOS Simulator / Desktop**: Automatically routes to `http://localhost:5000/api`
- Modify `lib/core/network/api_endpoints.dart` if testing on a physical mobile device over LAN.
