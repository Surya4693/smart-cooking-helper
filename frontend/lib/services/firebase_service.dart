import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import '../models/user_model.dart' as user_model;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '144360324029-g2237i65n8br6clkok1t9m3at89j623b.apps.googleusercontent.com',
);

  // Authentication Methods
  Future<user_model.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Create or update user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'display_name': userCredential.user!.displayName ?? googleUser.displayName,
          'photo_url': userCredential.user!.photoURL ?? googleUser.photoUrl,
          'dietary_preferences': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        return await _getUserData(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<user_model.User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await _getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Email sign-in failed: $e');
    }
  }

  Future<user_model.User?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'display_name': displayName,
          'dietary_preferences': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return await _getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Email sign-up failed: $e');
    }
  }

  Future<user_model.User?> signInAsGuest() async {
    try {
      final UserCredential credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        return await _getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Guest sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // User Profile Methods
  Future<user_model.User?> _getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return user_model.User(
          id: uid,
          email: data['email'] as String,
          displayName: data['display_name'] as String?,
          photoUrl: data['photo_url'] as String?,
          dietaryPreferences: List<String>.from(data['dietary_preferences'] as List? ?? []),
          createdAt: DateTime.parse(data['created_at'] as String),
          updatedAt: DateTime.parse(data['updated_at'] as String),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserProfile(String uid, user_model.User user) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'display_name': user.displayName,
        'dietary_preferences': user.dietaryPreferences,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String> uploadProfilePhoto(String uid, String imagePath) async {
    try {
      final Reference ref = _storage.ref().child('profile_photos').child('$uid.jpg');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Storage Methods
  Future<String> uploadFile(String filePath, String path, String fileName) async {
    try {
      final Reference ref = _storage.ref().child(path).child(fileName);
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Dietary Preferences
  Future<void> updateDietaryPreferences(String uid, List<String> preferences) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'dietary_preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update dietary preferences: $e');
    }
  }

  Stream<user_model.User?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return user_model.User(
          id: uid,
          email: data['email'] as String,
          displayName: data['display_name'] as String?,
          photoUrl: data['photo_url'] as String?,
          dietaryPreferences: List<String>.from(data['dietary_preferences'] as List? ?? []),
          createdAt: DateTime.parse(data['created_at'] as String),
          updatedAt: DateTime.parse(data['updated_at'] as String),
        );
      }
      return null;
    });
  }
}
