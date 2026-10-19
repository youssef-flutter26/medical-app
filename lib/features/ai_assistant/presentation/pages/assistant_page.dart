import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/assistant_doctor.dart';
import '../cubit/assistant_cubit.dart';
import '../cubit/assistant_state.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AssistantCubit>().initialize();
      }
    });
  }

  String _formatDoctorSchedule(AssistantDoctor doctor) {
    const days = {
      'sunday': 'الأحد',
      'monday': 'الإثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
    };

    if (doctor.schedule.isEmpty) {
      final availableTime = doctor.availableTime?.trim();

      return availableTime == null || availableTime.isEmpty
          ? 'مواعيد العمل غير مسجلة'
          : availableTime;
    }

    final lines = <String>[];

    for (final entry in days.entries) {
      final raw = doctor.schedule[entry.key];

      if (raw is! Map) continue;

      final enabled = raw['enabled'] == true;
      final start = raw['startTime']?.toString() ?? '';
      final end = raw['endTime']?.toString() ?? '';

      if (enabled && start.isNotEmpty && end.isNotEmpty) {
        lines.add('${entry.value}: $start - $end');
      } else {
        lines.add('${entry.value}: إجازة');
      }
    }

    if (lines.isEmpty) {
      return doctor.availableTime?.trim().isNotEmpty == true
          ? doctor.availableTime!.trim()
          : 'مواعيد العمل غير مسجلة';
    }

    return lines.join('\n');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    _controller.clear();

    context.read<AssistantCubit>().sendMessage(message);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Assistant',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh location',
            onPressed: () {
              context.read<AssistantCubit>().refreshLocation();
            },
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Location status.
            BlocBuilder<AssistantCubit, AssistantState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.errorMessage != current.errorMessage ||
                  previous.hasLocation != current.hasLocation,
              builder: (context, state) {
                if (state.status == AssistantStatus.gettingLocation &&
                    !state.hasLocation) {
                  return const LinearProgressIndicator();
                }

                if (!state.hasLocation &&
                    state.status == AssistantStatus.failure) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade50,
                    child: Column(
                      children: [
                        Text(
                          state.errorMessage ?? 'Unable to get your location.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<AssistantCubit>().refreshLocation();
                          },
                          icon: const Icon(Icons.location_on),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.hasLocation) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    color: Colors.green.shade50,
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Searching based on your current location',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // Chat messages.
            Expanded(
              child: BlocBuilder<AssistantCubit, AssistantState>(
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 60,
                              color: Colors.black,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'How can I help you?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try: Find a cardiologist near me',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        state.messages.length +
                        (state.status == AssistantStatus.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final message = state.messages[index];

                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.black
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Nearby doctors cards.
            BlocBuilder<AssistantCubit, AssistantState>(
              buildWhen: (previous, current) =>
                  previous.nearbyDoctors != current.nearbyDoctors,
              builder: (context, state) {
                if (state.nearbyDoctors.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.nearbyDoctors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _DoctorCard(
                        doctor: state.nearbyDoctors[index],
                        formatSchedule: _formatDoctorSchedule,
                      );
                    },
                  ),
                );
              },
            ),

            // Error message.
            BlocBuilder<AssistantCubit, AssistantState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.errorMessage != current.errorMessage ||
                  previous.messages.length != current.messages.length,
              builder: (context, state) {
                if (state.status != AssistantStatus.failure ||
                    state.messages.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),

            // Message input.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask about nearby doctors...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.formatSchedule});

  final AssistantDoctor doctor;
  final String Function(AssistantDoctor doctor) formatSchedule;

  @override
  Widget build(BuildContext context) {
    final scheduleText = formatSchedule(doctor);

    return SizedBox(
      width: 270,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor name.
              Text(
                doctor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // Specialty.
              Text(
                doctor.specialty ?? 'Specialty unavailable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 5),

              // Distance.
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.distanceInKm == null
                          ? 'Distance unavailable'
                          : '${doctor.distanceInKm!.toStringAsFixed(1)} km away',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Rating and reviews count.
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.rating == null
                          ? 'No rating'
                          : '${doctor.rating!.toStringAsFixed(1)}'
                                ' (${doctor.reviewsCount == null ? 'reviews count unavailable' : '${doctor.reviewsCount} reviews'})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Divider(height: 14),

              // Working hours.
              const Row(
                children: [
                  Icon(Icons.access_time, size: 17, color: Colors.teal),
                  SizedBox(width: 5),
                  Text(
                    'Working hours',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    scheduleText,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // Address.
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.address ?? 'Address unavailable',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
