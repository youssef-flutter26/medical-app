import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/assistant_message.dart';
import '../../domain/usecases/send_assistant_message.dart';
import 'assistant_state.dart';

class AssistantCubit extends Cubit<AssistantState> {
  AssistantCubit(this._sendAssistantMessage) : super(const AssistantState());

  final SendAssistantMessage _sendAssistantMessage;

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location is disabled. Please enable GPS and try again.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was denied. Please allow location access.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  Future<void> initialize() async {
    emit(
      state.copyWith(status: AssistantStatus.gettingLocation, clearError: true),
    );

    try {
      final position = await _getCurrentPosition();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: AssistantStatus.initial,
          latitude: position.latitude,
          longitude: position.longitude,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: AssistantStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> refreshLocation() async {
    await initialize();
  }

  Future<void> sendMessage(String message) async {
    final text = message.trim();

    if (text.isEmpty) return;

    final userMessage = AssistantMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      role: AssistantMessageRole.user,
      createdAt: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];

    emit(
      state.copyWith(
        messages: updatedMessages,
        status: AssistantStatus.gettingLocation,
        clearError: true,
      ),
    );

    try {
      final position = await _getCurrentPosition();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: AssistantStatus.loading,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      final doctors = await _sendAssistantMessage.searchNearbyDoctors(
        latitude: position.latitude,
        longitude: position.longitude,
        query: _extractSearchQuery(text),
        radiusInKm: 15,
      );

      if (isClosed) return;

      final reply = await _sendAssistantMessage(
        message: text,
        latitude: position.latitude,
        longitude: position.longitude,
        nearbyDoctors: doctors,
      );

      if (isClosed) return;

      final assistantMessage = AssistantMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: reply,
        role: AssistantMessageRole.assistant,
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          status: AssistantStatus.success,
          messages: [...updatedMessages, assistantMessage],
          nearbyDoctors: doctors,
          latitude: position.latitude,
          longitude: position.longitude,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: AssistantStatus.failure,
          messages: updatedMessages,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  String _extractSearchQuery(String message) {
    var query = message.toLowerCase();

    // إزالة بعض الكلمات الشائعة الخاصة بالقرب والموقع.
    const phrases = [
      'من حولي',
      'قريب مني',
      'قريب منى',
      'بالقرب مني',
      'جنب مني',
      'near me',
      'nearby',
      'closest to me',
    ];

    for (final phrase in phrases) {
      query = query.replaceAll(phrase, ' ');
    }

    return query.trim();
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('Location is disabled')) {
      return 'فعّل الموقع GPS على جهازك وحاول مرة تانية.';
    }

    if (message.contains('permission was denied')) {
      return 'لازم تسمح للتطبيق باستخدام موقعك عشان نبحث عن الأقرب ليك.';
    }

    if (message.contains('permanently denied')) {
      return 'إذن الموقع مرفوض بشكل دائم. افتح إعدادات التطبيق وفعّل الموقع.';
    }

    if (error is LocationServiceDisabledException) {
      return 'خدمة الموقع مقفولة. فعّل GPS وحاول تاني.';
    }

    if (error is TimeoutException) {
      return 'تحديد الموقع استغرق وقتًا طويلًا. حاول مرة تانية.';
    }

    return 'حصلت مشكلة أثناء البحث. حاول مرة تانية.';
  }
}
