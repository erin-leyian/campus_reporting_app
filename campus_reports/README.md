# Campus Reports 

> A mobile incident reporting and resolution tracking application for university campuses built with Flutter, Firebase, and Cloudinary.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com/)

---

## about the Project

On university campuses, students frequently face everyday infrastructure hazards such as electrical outages, water leaks, broken furniture, safety hazards, and facility breakdowns. Without a centralized reporting tool, students have no easy way to notify maintenance staff or monitor repair progress.

**Campus Reports** resolves this issue by providing:
- **For Students:** A simple interface to report issues with descriptions, categories, locations, and optional photos, track report lifecycles, and choose anonymous reporting when privacy is needed.
- **For Staff:** An administrative workflow to triage incoming issues, track urgent safety alerts, and advance report statuses from submission to resolution.

**Demo Video link **: https://drive.google.com/file/d/1nYPN6tKYeIiA8JmZReHNv9OraCaAiN00/view?usp=sharing `.

---

## Key Features

- **Domain-Restricted Authentication:** Student registration is validated exclusively for institutional accounts (`@alustudent.com`) with mandatory email verification before app access is granted.
- **Role-Based Access Control (RBAC):** Distinct roles for **Students** (submit, browse, edit own submitted reports) and **Staff** (status update controls). Staff accounts are created directly by administrators to prevent unauthorized privilege escalation.
- **Server-Side Security:** Access controls and editing permissions are enforced at the database layer via **Cloud Firestore Security Rules**, preventing unauthorized client-side updates.
- **Real-Time Updates:** Built with live Firestore streams so report progress updates instantly on the student's screen without needing manual refreshes.
- **Urgent Issue Prioritization:** Reports flagged under the `Safety` category are prioritized at the top of the feed for faster visibility.
- **Smart Photo Attachments:** Images are downscaled, checked against a 5 MB limit, and uploaded to Cloudinary, saving only the optimized image URL to Firestore.
- **Data Protection & Lock-in:** Students can edit or delete their reports only while in the `Submitted` state. Once staff begin reviewing, reports become read-only for students.

---

## Application Architecture

The project is structured using a clean 4-layer architecture to keep the UI strictly separated from backend services:

```text
lib/
├── screens/ & widgets/   # UI Layer: Renders screens, accepts input, calls providers
├── providers/            # State Layer: Manages app state (ChangeNotifier), search & filters
├── services/             # Service Layer: Exclusively talks to Firebase Auth, Firestore, and Cloudinary
├── models/               # Data Layer: Incident and user models with Firestore serializers
└── utils/                # Utility Layer: Input validators, constants, categories, and locations
```

### Data Flow
$$\text{Screen / Widget} \longrightarrow \text{Provider} \longrightarrow \text{Service} \longrightarrow \text{Firebase / Cloudinary}$$
$$\text{Firestore Live Stream} \longrightarrow \text{Provider} \longrightarrow \text{UI updates automatically}$$

### State Management
- **`Provider` (`ChangeNotifier`):** Handles cross-app shared state:
  - `AuthProvider`: Observes authentication state, checks verification, fetches user roles, and formats error codes.
  - `IncidentProvider`: Subscribes to live Firestore streams, manages search queries, and applies filters (category, status, personal reports).
- **`setState`:** Kept strictly for local, temporary UI state (form controllers, password visibility toggles, image picker state).

---

## Database Schema (Cloud Firestore)

### `users` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | Display name |
| `email` | `string` | ALU student / staff email |
| `role` | `string` | User role (`student` or `staff`) |
| `createdAt` | `timestamp` | Server timestamp when account was created |

### `incidents` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `string` | Brief title of the issue |
| `description` | `string` | Minimum 20 characters describing the incident |
| `category` | `string` | `Water`, `Electricity`, `Facilities`, `Furniture`, `Sanitation`, `Safety`, `Other` |
| `location` | `string` | Campus location chosen from a fixed list |
| `status` | `string` | `Submitted` ➔ `In Review` ➔ `In Progress` ➔ `Resolved` (or `Rejected`) |
| `reporterId` | `string` | UID of the submitting user |
| `reporterName` | `string` | Author name (masked in UI if `isAnonymous` is true) |
| `isAnonymous` | `boolean` | Flag to protect user identity |
| `photoUrl` | `string?` | Direct link to image hosted on Cloudinary |
| `createdAt` / `updatedAt` | `timestamp` | Server timestamps |

---

## Report Status Lifecycle

```text
               ┌──────────┐
               │Submitted │ (Owner can edit/delete only here)
               └────┬─────┘
                    │
         staff takes action
                    ▼
               ┌──────────┐
          ┌───►│In Review ├───────┐
          │    └────┬─────┘       │
          │         │             │
     staff rejects  ▼        staff rejects
          │    ┌───────────┐      │
          ├───►│In Progress├──────┤
          │    └────┬──────┘      │
          │         │             │
          │    staff resolves     │
          │         ▼             │
          │    ┌──────────┐       ▼
          │    │ Resolved │  ┌──────────┐
          │    └──────────┘  │ Rejected │
          └─────────────────►└──────────┘
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x recommended)
- Android Studio / VS Code with Flutter and Dart extensions
- An active Firebase project with **Authentication** and **Cloud Firestore** enabled
- A free [Cloudinary](https://cloudinary.com/) account for image uploads

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/erin-leyian/campus_reporting_app.git
   cd campus_reporting_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` file in `android/app/`.
   - If building for iOS, place your `GoogleService-Info.plist` in `ios/Runner/`.

4. **Configure Cloudinary:**
   - In `lib/services/storage_service.dart`, verify or update your `cloud_name` and unsigned `upload_preset`.

5. **Run the application:**
   ```bash
   flutter run
   ```

---

## Testing Summary

Testing was performed manually across critical app workflows using an Android emulator, alongside unit tests:

| Test Case | Expected Outcome | Status |
| :--- | :--- | :---: |
| Register with non-ALU email | Validation error (must be `@alustudent.com`) | Pass |
| Register with ALU email | Account created, verification email sent |  Pass |
| Login before email verification | Screen locked at `VerifyEmailScreen` |  Pass |
| Short description (< 20 chars) | Form validation blocks submission |  Pass |
| Report creation with photo | Image uploaded to Cloudinary, incident saved | Pass |
| Offline / Network failure | Clean error snackbar, no broken documents |  Pass |
| Search & multi-filter feed | Real-time query matches on local feed |  Pass |
| Staff updates report status | Student UI updates immediately without refresh | Pass |
| Student attempts staff action | Blocked server-side by Firestore rules |  Pass |
| Delete/edit non-submitted report | Restricted; editing disabled once status advances | Pass |


---

##  Future Improvements

- **Signed Image Uploads:** Move from unsigned Cloudinary presets to secure server-signed upload signatures.
- **Server Pagination:** Replace full-list client-side filtering with Firestore cursor pagination for scalability.
- **Push Notifications:** Alert students via Firebase Cloud Messaging (FCM) when a report's status changes.
- **Incident History Timeline:** Add audit logs showing timestamps and notes for each transition in the issue lifecycle.

---

##  References & Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Simple App State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- [Provider Package (`pub.dev`)](https://pub.dev/packages/provider)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Cloud Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloudinary Upload API](https://cloudinary.com/documentation/image_upload_api_reference)
- [Image Picker Package (`pub.dev`)](https://pub.dev/packages/image_picker)
