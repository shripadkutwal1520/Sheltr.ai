import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum UserRole { staff, user }

// IMPORTANT: Replace with your actual email before running
const STAFF_EMAIL = 'mayureshnehere44@gmail.com';

class RoleService {
  Future<UserRole> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[RoleService] No user logged in → UserRole.user');
      return UserRole.user;
    }

    debugPrint('[RoleService] Current user email: ${user.email}');

    // Check staff email (case-insensitive)
    if (user.email?.toLowerCase() == STAFF_EMAIL.toLowerCase()) {
      debugPrint('[RoleService] Email matched STAFF_EMAIL → UserRole.staff');
      return UserRole.staff;
    }

    // Fetch role from Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final role = doc.data()?['role'];
        if (role == 'staff') {
          debugPrint('[RoleService] Firestore role=staff → UserRole.staff');
          return UserRole.staff;
        }
      }
    } catch (e) {
      debugPrint('[RoleService] Firestore error, using fallback: $e');
    }

    debugPrint('[RoleService] No match → UserRole.user');
    return UserRole.user;
  }
}