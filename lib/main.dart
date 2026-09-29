import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin_dashboard_page.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// Main screen demonstrating the two distinct security concepts:
/// 1. AUTHENTICATION: Verifying identity (Who are you?) -> via /login
/// 2. AUTHORIZATION: Verifying permissions (What can you access?) -> via /admin-dashboard
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Stores the Bearer token issued by the backend after successful authentication.
  String? authtoken;

  // Controls whether the username and password input fields are editable.
  bool textfield = true;

  // Displays status, feedback, or error messages returned by the server.
  String serverResponse = "Waiting for server response...";

  // Text editing controllers to capture user credentials.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Backend server address (pointing to the Go backend running on port 8080).
  final String baseUrl = "http://192.168.1.98:8080";

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed to prevent memory leaks (KISS).
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// DRY Helper: Generates consistent input decoration for text fields
  /// while keeping the visual styling 100% identical.
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 20.0,
      ),
    );
  }

  /// STEP 1: AUTHENTICATION
  ///
  /// Sends user credentials (username and password) to the server via POST /login.
  /// - If the credentials are valid, the server returns HTTP 200 OK along with an access token.
  /// - The client stores this token (`authtoken`) in memory to prove identity for subsequent requests.
  /// - If invalid, the server responds with HTTP 401 Unauthorized.
  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": nameController.text,
          "password": passwordController.text,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Authentication succeeded: save the token and lock input fields.
        setState(() {
          authtoken = data["token"];
          textfield = false;
          serverResponse = data["message"] ?? "Login successful";
        });
      } else {
        // Authentication failed: display the HTTP status code and server error message.
        setState(() {
          serverResponse =
              "Error code : ${response.statusCode}\n ${data['message'] ?? 'Authentication failed'}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        serverResponse = "Error during login: $e";
      });
    }
  }

  /// STEP 2: AUTHORIZATION
  ///
  /// Requests access to a protected resource (GET /admin-dashboard).
  /// - To prove permission, the client sends the stored token in the HTTP Authorization header:
  ///   `Authorization: Bearer <authtoken>`
  /// - The server verifies whether the token has the required permissions to access the resource.
  /// - If authorized (HTTP 200 OK), navigation to AdminDashboardPage occurs with the protected data.
  /// - If unauthorized/forbidden (HTTP 403 Forbidden), access is denied.
  Future<void> fetchAdminData() async {
    // Guard clause (KISS): If the user hasn't authenticated yet, no token is available.
    if (authtoken == null) {
      setState(() {
        serverResponse = "No token";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin-dashboard"),
        headers: {"Authorization": "Bearer $authtoken"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Authorization granted: parse the protected data and navigate to the dashboard.
        final data = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardPage(data: data),
          ),
        );
      } else {
        // Authorization denied: user does not have permission to view this resource.
        setState(() {
          serverResponse = "Failed to fetch admin data";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        serverResponse = "Error fetching admin data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username field
            TextField(
              enabled: textfield,
              controller: nameController,
              decoration: _buildInputDecoration("Username"),
            ),
            // Password field
            TextField(
              enabled: textfield,
              controller: passwordController,
              decoration: _buildInputDecoration("Password"),
            ),
            const SizedBox(height: 30),
            // Server response display area
            Text(
              "Server Response:\n$serverResponse",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Button 1: Triggers Authentication
            ElevatedButton(
              onPressed: login,
              child: const Text("1.Login in (Authentication)"),
            ),
            const SizedBox(height: 15),
            // Button 2: Triggers Authorization & Data Access
            ElevatedButton(
              onPressed: fetchAdminData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "2.request data Access the data (Authorization)",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
