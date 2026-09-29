import 'package:flutter/material.dart';

/// AdminDashboardPage demonstrates AUTHORIZATION in practice.
///
/// Authorization is the process of verifying what resources or actions an authenticated user
/// is permitted to access.
///
/// This screen is displayed only after the client presents a valid Bearer token to the
/// protected backend endpoint (/admin-dashboard) and receives the secret admin data.
class AdminDashboardPage extends StatelessWidget {
  /// The protected payload returned by the server upon successful authorization.
  final Map<String, dynamic> data;

  const AdminDashboardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Admin Dashboard ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              "${data['message']} \n ${data['data']}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
