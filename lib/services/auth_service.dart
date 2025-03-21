// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/user_model.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   // Get current user
//   User? get currentUser => _auth.currentUser;
  
//   // Listen to auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
  
//   // Sign in with email and password
//   Future<UserCredential> signInWithEmailAndPassword(
//     String email, 
//     String password,
//   ) async {
//     try {
//       return await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//     } catch (e) {
//       throw _handleAuthException(e);
//     }
//   }
  
//   // Register with email and password
//   Future<UserCredential> registerWithEmailAndPassword(
//     String email, 
//     String password, 
//     String name,
//   ) async {
//     try {
//       // Create user in Firebase Auth
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Create user document in Firestore
//       await _createUserDocument(userCredential.user!, name);
      
//       return userCredential;
//     } catch (e) {
//       throw _handleAuthException(e);
//     }
//   }
  
//   // Create user document in Firestore
//   Future<void> _createUserDocument(User user, String name) async {
//     final userDoc = _firestore.collection('users').doc(user.uid);
    
//     // Check if user document already exists
//     final docSnapshot = await userDoc.get();
//     if (!docSnapshot.exists) {
//       // Create new user document
//       await userDoc.set({
//         'name': name,
//         'email': user.email,
//         'role': 'teacher', // Default role is teacher
//         'photoUrl': user.photoURL,
//         'classIds': [], // Initially no classes
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }
  
//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
  
//   // Get user details from Firestore
//   Future<UserModel?> getUserDetails(String userId) async {
//     try {
//       final docSnapshot = await _firestore.collection('users').doc(userId).get();
//       if (docSnapshot.exists) {
//         return UserModel.fromMap(
//           docSnapshot.data() as Map<String, dynamic>, 
//           docSnapshot.id,
//         );
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user details: $e');
//       return null;
//     }
//   }
  
//   // Update user profile
//   Future<void> updateUserProfile(UserModel updatedUser) async {
//     try {
//       await _firestore.collection('users').doc(updatedUser.id).update(
//         updatedUser.toMap(),
//       );
//     } catch (e) {
//       print('Error updating user profile: $e');
//       throw Exception('Failed to update user profile');
//     }
//   }
  
//   // Reset password
//   Future<void> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       throw _handleAuthException(e);
//     }
//   }
  
//   // Handle authentication exceptions
//   Exception _handleAuthException(dynamic e) {
//     if (e is FirebaseAuthException) {
//       switch (e.code) {
//         case 'user-not-found':
//           return Exception('No user found with this email.');
//         case 'wrong-password':
//           return Exception('Incorrect password.');
//         case 'email-already-in-use':
//           return Exception('Email is already in use.');
//         case 'weak-password':
//           return Exception('Password is too weak.');
//         case 'invalid-email':
//           return Exception('Invalid email format.');
//         default:
//           return Exception('Authentication error: ${e.message}');
//       }
//     }
//     return Exception('Authentication error occurred');
//   }
// }