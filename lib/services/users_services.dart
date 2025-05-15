import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/users.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File imageFile, String uid) async {
    final ref = _storage.ref().child('profileImages/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required List<String> classifications,
    required int age,
    File? profileImage,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    String imageUrl = '';
    if (profileImage != null) {
      imageUrl = await uploadProfileImage(profileImage, uid);
    }

    Users userModel = Users(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      profileImageUrl: imageUrl,
      classifications: classifications,
      age: age,
    );

    await _firestore.collection('Users').doc(uid).set(userModel.toMap());
  }

  Future<Users> getUser(String uid) async {
    final doc = await _firestore.collection('Users').doc(uid).get();
    return Users.fromMap(doc.data()!);
  }

  Future<Users> getUserbyEmail(String email) async {
    final doc = await _firestore.collection('Users').doc(email).get();
    return Users.fromMap(doc.data()!);
  }
}
