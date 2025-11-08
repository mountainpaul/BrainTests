import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/widgets/custom_card.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cycling Logging Screen for Garmin data entry
/// Tracks: Distance, Total Time, Avg Moving Speed, Avg Heart Rate, Max Heart Rate
class CyclingLoggingScreen extends ConsumerStatefulWidget {
  const CyclingLoggingScreen({super.key});

  @override
  ConsumerState<CyclingLoggingScreen> createState() => _CyclingLoggingScreenState();
}

class _CyclingLoggingScreenState extends ConsumerState<CyclingLoggingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Garmin cycling data
  final _distanceController = TextEditingController();
  final _totalTimeController = TextEditingController();
  final _avgSpeedController = TextEditingController();
  final _avgHeartRateController = TextEditingController();
  final _maxHeartRateController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _distanceController.dispose();
    _totalTimeController.dispose();
    _avgSpeedController.dispose();
    _avgHeartRateController.dispose();
    _maxHeartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCyclingData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = ref.read(databaseProvider);

      await db.into(db.cyclingTrackingTable).insert(
        CyclingTrackingTableCompanion.insert(
          rideDate: _selectedDate,
          distanceKm: Value.ofNullable(double.tryParse(_distanceController.text)),
          totalTimeSeconds: Value.ofNullable(int.tryParse(_totalTimeController.text)),
          avgMovingSpeedKmh: Value.ofNullable(double.tryParse(_avgSpeedController.text)),
          avgHeartRate: Value.ofNullable(int.tryParse(_avgHeartRateController.text)),
          maxHeartRate: Value.ofNullable(int.tryParse(_maxHeartRateController.text)),
          notes: Value.ofNullable(_notesController.text.isEmpty ? null : _notesController.text),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cycling data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving cycling data: $e'),
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
        title: const Text('Log Cycling Data'),
        backgroundColor: Colors.orange[700],
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
                    Icon(Icons.directions_bike, size: 48, color: Colors.orange[700]),
                    const SizedBox(height: 8),
                    Text(
                      'Garmin Cycling Tracker',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your cycling data from Garmin',
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
                  leading: Icon(Icons.calendar_today, color: Colors.orange[700]),
                  title: const Text('Ride Date'),
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

              // Distance
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: const InputDecoration(
                        hintText: 'Total distance',
                        suffixText: 'km',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter distance';
                        }
                        final distance = double.tryParse(value);
                        if (distance == null || distance < 0) {
                          return 'Please enter a valid distance';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total Time
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'In minutes',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _totalTimeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Total time',
                        suffixText: 'minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter total time';
                        }
                        final time = int.tryParse(value);
                        if (time == null || time < 0) {
                          return 'Please enter a valid time';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Avg Moving Speed
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avg Moving Speed',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _avgSpeedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: const InputDecoration(
                        hintText: 'Average speed',
                        suffixText: 'km/h',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final speed = double.tryParse(value);
                          if (speed == null || speed < 0) {
                            return 'Please enter a valid speed';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Heart Rate Section
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heart Rate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avg Heart Rate
                    const Text(
                      'Avg Heart Rate',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _avgHeartRateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Average heart rate',
                        suffixText: 'bpm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final hr = int.tryParse(value);
                          if (hr == null || hr < 0 || hr > 220) {
                            return 'Please enter a valid heart rate (0-220)';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Max Heart Rate
                    const Text(
                      'Max Heart Rate',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _maxHeartRateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Maximum heart rate',
                        suffixText: 'bpm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final hr = int.tryParse(value);
                          if (hr == null || hr < 0 || hr > 220) {
                            return 'Please enter a valid heart rate (0-220)';
                          }

                          // Check if max >= avg
                          final avgText = _avgHeartRateController.text;
                          if (avgText.isNotEmpty) {
                            final avgHr = int.tryParse(avgText);
                            if (avgHr != null && hr < avgHr) {
                              return 'Max HR must be >= Avg HR';
                            }
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
                onPressed: _isSaving ? null : _saveCyclingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Cycling Data'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
