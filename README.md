# Flutter & Go: Authentication and Authorization Demo

An educational full-stack demonstration illustrating the core differences between **Authentication** and **Authorization** using **Flutter** for the mobile/web client and **Go** for the backend server.

---

## 💡 Concepts: Authentication vs. Authorization

| Concept | Question Answered | Implementation in this Project | HTTP Status Code |
| :--- | :--- | :--- | :--- |
| **Authentication** | *"Who are you?"* | Validates username and password via `POST /login` and issues an access token. | `200 OK` (success) / `401 Unauthorized` (failed) |
| **Authorization** | *"What are you allowed to do?"* | Inspects the `Authorization: Bearer <token>` header on `GET /admin-dashboard` to verify permissions. | `200 OK` (granted) / `403 Forbidden` (denied) |

---

## 🛠️ Software Principles Applied

- **YAGNI (You Aren't Gonna Need It)**: Stripped redundant abstractions, dead code, and unused boilerplate. Converted stateless presentation widgets (`AdminDashboardPage`) to `StatelessWidget`.
- **KISS (Keep It Simple, Stupid)**: Plain, readable standard library Go server and clean Flutter lifecycle handling (`dispose()`, safe navigation).
- **DRY (Don't Repeat Yourself)**: Unified text field styling (`_buildInputDecoration`), shared response helpers (`sendJSON`), and standardized constants.

---

## 📂 Project Structure

```text
├── go_backend/
│   └── main.go                  # Go HTTP server with /login and /admin-dashboard endpoints
├── lib/
│   ├── main.dart                # Flutter home page handling login and token access
│   └── admin_dashboard_page.dart # Protected screen rendered upon successful authorization
└── pubspec.yaml                 # Flutter project configuration and dependencies
```

---

## 🚀 Getting Started

### 1. Run the Go Backend
Ensure [Go](https://go.dev/) is installed, then run:
```bash
cd go_backend
go run main.go
```
The server will start listening on port `8080`.

### 2. Configure & Run the Flutter App
Ensure the `baseUrl` in [lib/main.dart](lib/main.dart) points to your backend IP or `localhost`:
```dart
final String baseUrl = "http://10.0.2.2:8080"; // Android Emulator
// or
final String baseUrl = "http://localhost:8080"; // Web / Desktop / iOS Simulator
```

Run the application:
```bash
flutter run
```

---

## 🔑 Demo Credentials
- **Username**: `john`
- **Password**: `1122334455`
- **Role**: Admin
