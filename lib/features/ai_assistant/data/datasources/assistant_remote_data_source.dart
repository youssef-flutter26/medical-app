import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AssistantRemoteDataSource {
  AssistantRemoteDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const String _baseUrl = 'http://192.168.1.3:3000';

  Future<List<Map<String, dynamic>>> getDoctors() async {
    final snapshot = await _firestore.collection('doctors').get();

    return snapshot.docs.map((doc) {
      return <String, dynamic>{
        ...doc.data(),
        'id': doc.id,
      };
    }).toList();
  }

  Future<String> sendMessage({
    required String message,
    required double latitude,
    required double longitude,
    required List<Map<String, dynamic>> nearbyDoctors,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in to use the assistant.');
    }

    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Could not verify your account. Please sign in again.',
      );
    }

    final uri = Uri.parse('$_baseUrl/api/assistant/chat');

    final requestBody = <String, dynamic>{
      'message': message,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      // إرسال بيانات الدكاترة والتقييمات التي تم جلبها من Firestore.
      'nearbyDoctors': nearbyDoctors,
    };

    debugPrint(
      '🩺 Sending ${nearbyDoctors.length} nearby doctors to assistant server',
    );

    for (final doctor in nearbyDoctors) {
      debugPrint(
        '⭐ ${doctor['name']}: '
            'rating=${doctor['rating']}, '
            'reviewsCount=${doctor['reviewsCount']}',
      );
    }

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(requestBody),
    )
        .timeout(const Duration(seconds: 60));

    final Map<String, dynamic> data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response format.');
      }

      data = decoded;
    } on FormatException {
      throw Exception(
        'The assistant server returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['error'] is String
            ? data['error'] as String
            : 'The assistant request failed (${response.statusCode}).',
      );
    }

    final reply = data['reply'];

    if (reply is! String || reply
        .trim()
        .isEmpty) {
      throw Exception('The assistant returned an empty response.');
    }

    return reply.trim();
  }
}
