import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/widgets/custom_card.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sleep Logging Screen for Garmin data entry
/// Tracks: Duration, Stress, Light Sleep, Deep Sleep, and REM Sleep
class SleepLoggingScreen extends ConsumerStatefulWidget {
  const SleepLoggingScreen({super.key});

  @override
  ConsumerState<SleepLoggingScreen> createState() => _SleepLoggingScreenState();
}

class _SleepLoggingScreenState extends ConsumerState<SleepLoggingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Garmin sleep data
  final _durationController = TextEditingController();
  final _stressController = TextEditingController();
  final _lightSleepController = TextEditingController();
  final _deepSleepController = TextEditingController();
  final _remSleepController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _stressController.dispose();
    _lightSleepController.dispose();
    _deepSleepController.dispose();
    _remSleepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSleepData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = ref.read(databaseProvider);

      await db.into(db.sleepTrackingTable).insert(
        SleepTrackingTableCompanion.insert(
          sleepDate: _selectedDate,
          durationMinutes: Value.ofNullable(int.tryParse(_durationController.text)),
          stress: Value.ofNullable(int.tryParse(_stressController.text)),
          lightSleepMinutes: Value.ofNullable(int.tryParse(_lightSleepController.text)),
          deepSleepMinutes: Value.ofNullable(int.tryParse(_deepSleepController.text)),
          remSleepMinutes: Value.ofNullable(int.tryParse(_remSleepController.text)),
          notes: Value.ofNullable(_notesController.text.isEmpty ? null : _notesController.text),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving sleep data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Sleep Data'),
        backgroundColor: Colors.indigo[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              CustomCard(
                child: Column(
                  children: [
                    Icon(Icons.bedtime, size: 48, color: Colors.indigo[700]),
                    const SizedBox(height: 8),
                    Text(
                      'Garmin Sleep Tracker',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your sleep data from Garmin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Date picker
              CustomCard(
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.indigo[700]),
                  title: const Text('Sleep Date'),
                  subtitle: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Duration
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Total sleep duration',
                        suffixText: 'minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration < 0) {
                          return 'Please enter a valid duration';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stress
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stress',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0-100 scale',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stressController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Stress level',
                        suffixText: '0-100',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stress level';
                        }
                        final stress = int.tryParse(value);
                        if (stress == null || stress < 0 || stress > 100) {
                          return 'Stress must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sleep Stages
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Stages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Light Sleep
                    const Text(
                      'Light Sleep',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lightSleepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Light sleep duration',
                        suffixText: 'minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final light = int.tryParse(value);
                          if (light == null || light < 0) {
                            return 'Please enter a valid duration';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Deep Sleep
                    const Text(
                      'Deep Sleep',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deepSleepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Deep sleep duration',
                        suffixText: 'minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final deep = int.tryParse(value);
                          if (deep == null || deep < 0) {
                            return 'Please enter a valid duration';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // REM Sleep
                    const Text(
                      'REM Sleep',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _remSleepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'REM sleep duration',
                        suffixText: 'minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final rem = int.tryParse(value);
                          if (rem == null || rem < 0) {
                            return 'Please enter a valid duration';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add any additional notes...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSleepData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Sleep Data'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
