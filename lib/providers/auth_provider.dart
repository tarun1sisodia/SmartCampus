// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../services/auth_service.dart';

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService;
//   UserModel? _user;
//   bool _isLoading = false;
//   String? _error;
  
//   AuthProvider(this._authService) {
//     _initializeAuth();
//   }
  
//   // Getters
//   UserModel? get user => _user;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isAuthenticated => _user != null;
  
//   // Initialize authentication state
//   Future<void> _initializeAuth() async {
//     _setLoading(true);
    
//     // Listen to auth state changes
//     _authService.authStateChanges.listen((User? firebaseUser) async {
//       if (firebaseUser != null) {
//         // User is signed in, get user details from Firestore
//         final userDetails = await _authService.getUserDetails(firebaseUser.uid);
//         _user = userDetails;
//       } else {
//         // User is signed out
//         _user = null;
//       }
      
//       _setLoading(false);
//       notifyListeners();
//     });
//   }
  
//   // Sign in with email and password
//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       // Sign in with Firebase Auth
//       final userCredential = await _authService.signInWithEmailAndPassword(
//         email, 
//         password,
//       );
      
//       // Get user details from Firestore
//       if (userCredential.user != null) {
//         _user = await _authService.getUserDetails(userCredential.user!.uid);
//       }
      
//       _setLoading(false);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Register with email and password
//   Future<bool> registerWithEmailAndPassword(
//     String email, 
//     String password, 
//     String name,
//   ) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       // Register with Firebase Auth
//       final userCredential = await _authService.registerWithEmailAndPassword(
//         email, 
//         password, 
//         name,
//       );
      
//       // Get user details from Firestore
//       if (userCredential.user != null) {
//         _user = await _authService.getUserDetails(userCredential.user!.uid);
//       }
      
//       _setLoading(false);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Sign out
//   Future<void> signOut() async {
//     _setLoading(true);
    
//     try {
//       await _authService.signOut();
//       _user = null;
//     } catch (e) {
//       _setError(e.toString());
//     }
    
//     _setLoading(false);
//     notifyListeners();
//   }
  
//   // Update user profile
//   Future<bool> updateUserProfile(UserModel updatedUser) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       await _authService.updateUserProfile(updatedUser);
//       _user = updatedUser;
//       _setLoading(false);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Reset password
//   Future<bool> resetPassword(String email) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       await _authService.resetPassword(email);
//       _setLoading(false);
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Helper methods
//   void _setLoading(bool isLoading) {
//     _isLoading = isLoading;
//     notifyListeners();
//   }
  
//   void _setError(String error) {
//     _error = error;
//     notifyListeners();
//   }
  
//   void _clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }