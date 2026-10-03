import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProviderClass extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProviderClass() {
    _authService.authState.listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
     UserCredential credential = await _authService.signUp(email, password);
     final userModel = UserModel(
         uid: credential.user!.uid,
         email: credential.user!.email!,
         createdAt: DateTime.now().toString(),
         isOnline: true,
     );
     await _databaseService.saveUser(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'This email is already in use, try another.';
      } else if (e.code =='weak-password') {
        _errorMessage = 'Weak password, make it the strongest.';
      } else {
        _errorMessage = 'Sign up failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong.';
    }
    _isLoading = false;
    notifyListeners();


  }

  Future<void> logIn(String email, String password) async {
    _isLoading = true; // show loading spinner
    _errorMessage = null; // clear old errors
    notifyListeners(); // update ui

    try {
      await _authService.logIn(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Incorrect password.';
      } else if (e.code =='invalid-email') {
        _errorMessage = 'Invalid email address.';
      } else {
        _errorMessage ='Login failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong.';
    }

    _isLoading = false; // spinner disappears
    notifyListeners();
  }

  Future<void> logOut() async {
    await _authService.logOut();
  }
}