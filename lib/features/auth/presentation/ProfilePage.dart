import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/AuthController.dart';
import '../../../core/utils/SnackbarHelper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _authController.currentUser;
      if (user == null) throw Exception("No user logged in");

      final userDoc = await FirebaseFirestore.instance.collection("User").doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _firstNameController.text = data["firstName"] ?? "";
        _lastNameController.text = data["lastName"] ?? "";
        _usernameController.text = data["username"] ?? "";
      } else {
        SnackbarHelper.showError(context, "User data not found.");
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Failed to load user data: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    final user = _authController.currentUser;
    if (user == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      SnackbarHelper.showError(context, "All fields are required.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("User").doc(user.uid).update({
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
      });
      SnackbarHelper.showSuccess(context, "Profile updated successfully!");
    } catch (e) {
      SnackbarHelper.showError(context, "Failed to update profile: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Basic Information",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: "First Name"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: "Last Name"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text("Update Profile"),
              ),
              const SizedBox(height: 32),
              Text(
                "Danger Zone",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  _showDeleteConfirmation(context);
                },
                child: const Text("Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _authController.deleteAccount().then((_) {
                Get.offAllNamed('/login');
              }).catchError((e) {
                SnackbarHelper.showError(context, e.toString());
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
