import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import 'login.dart';
import '../services/users_services.dart';

final FirebaseService _firebaseService = FirebaseService();

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final Set<String> _selectedClassifications = {};
  final List<String> _classifications = ['Student', 'Business owner', 'Employee', 'Other'];

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  double? _selectedAge = 18; // Default age set to 18

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  void _signUp() async {
    if (_formKey.currentState!.validate() &&
        _selectedClassifications.isNotEmpty &&
        _selectedAge != null) {
      try {
        await _firebaseService.createUser(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          classifications: _selectedClassifications.toList(),
          age: _selectedAge!.toInt(),
          profileImage: _profileImage,
        );

        String fullName = '${_firstNameController.text} ${_lastNameController.text}';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please log in.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(fullName: fullName)),
        );
      } catch (e) {
        final errorMessage = e.toString().contains('email-already-in-use')
            ? 'An account with this email already exists.'
            : 'Signup failed: $e';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      if (_selectedClassifications.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one classification')),
        );
      }
      if (_selectedAge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your age')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageProfile(),
                const SizedBox(height: 40),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    color: AppConstants.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: inputDecoration('Enter your first name'),
                  style: TextStyle(color: AppConstants.textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    if (value.length < 2) {
                      return 'First name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: inputDecoration('Enter your last name'),
                  style: TextStyle(color: AppConstants.textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    if (value.length < 2) {
                      return 'Last name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration('Enter your email'),
                  style: TextStyle(color: AppConstants.textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: inputDecoration('Enter your password'),
                  style: TextStyle(color: AppConstants.textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (!_isValidPassword(value)) {
                      return 'Password must be at least 8 characters, with 1 letter \n and 1 number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: inputDecoration('Confirm your password'),
                  style: TextStyle(color: AppConstants.textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your classification(s):",
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._classifications.map((classification) {
                      return CheckboxListTile(
                        title: Text(classification, style: TextStyle(color: AppConstants.textColor)),
                        value: _selectedClassifications.contains(classification),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedClassifications.add(classification);
                            } else {
                              _selectedClassifications.remove(classification);
                            }
                          });
                        },
                        activeColor: Colors.cyan,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                    if (_selectedClassifications.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: Text(
                          "Please select at least one classification",
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your age:",
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _selectedAge != null ? '${_selectedAge!.toInt()}' : '18',
                        style: TextStyle(
                          color: AppConstants.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Slider(
                      value: _selectedAge ?? 18,
                      min: 18,
                      max: 65,
                      divisions: 47, // 65 - 18
                      onChanged: (value) {
                        setState(() {
                          _selectedAge = value;
                        });
                      },
                      activeColor: Colors.purple[700],
                      inactiveColor: Colors.purple[200],
                    ),
                    if (_selectedAge == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: Text(
                          "Please select your age",
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(color: AppConstants.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppConstants.textColor.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : AssetImage("assets/images/profile.png") as ImageProvider,
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => bottomSheet(),
                );
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.teal,
                size: 28.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 120.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.camera, color: Colors.teal),
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                label: const Text("Camera", style: TextStyle(color: Colors.teal)),
              ),
              const SizedBox(width: 20),
              TextButton.icon(
                icon: const Icon(Icons.image, color: Colors.teal),
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                label: const Text("Gallery", style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}