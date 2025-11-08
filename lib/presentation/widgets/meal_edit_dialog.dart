import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/database_provider.dart';

class MealEditDialog extends ConsumerStatefulWidget {
  final MealPlan? meal;
  final int dayNumber;

  const MealEditDialog({
    super.key,
    this.meal,
    required this.dayNumber,
  });

  @override
  ConsumerState<MealEditDialog> createState() => _MealEditDialogState();
}

class _MealEditDialogState extends ConsumerState<MealEditDialog> {
  late TextEditingController _mealNameController;
  late TextEditingController _descriptionController;
  late MealType _selectedMealType;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _mealNameController = TextEditingController(text: widget.meal?.mealName ?? '');
    _descriptionController = TextEditingController(text: widget.meal?.description ?? '');
    _selectedMealType = widget.meal?.mealType ?? MealType.lunch;
    _isActive = widget.meal?.isActive ?? true;
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _mealNameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name *',
                hintText: 'e.g., Grilled Salmon',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MealType>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Meal Type *',
                border: OutlineInputBorder(),
              ),
              items: MealType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getMealTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMealType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Rich in Omega-3, 350 calories',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                ),
                const Text('Active'),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inactive meals are hidden from your daily plan'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Day: ${widget.dayNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.meal != null)
          TextButton(
            onPressed: _deleteMeal,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMeal,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getMealTypeLabel(MealType type) {
    switch (type) {
      case MealType.lunch:
        return 'Lunch';
      case MealType.snack:
        return 'Snack';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  Future<void> _saveMeal() async {
    final mealName = _mealNameController.text.trim();

    if (mealName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal name')),
      );
      return;
    }

    try {
      final database = ref.read(databaseProvider);

      if (widget.meal == null) {
        // Create new meal
        await database.into(database.mealPlanTable).insert(
          MealPlanTableCompanion.insert(
            dayNumber: widget.dayNumber,
            mealType: _selectedMealType,
            mealName: mealName,
            description: _descriptionController.text.trim().isEmpty
                ? const drift.Value.absent()
                : drift.Value(_descriptionController.text.trim()),
            isActive: drift.Value(_isActive),
          ),
        );
      } else {
        // Update existing meal
        await (database.update(database.mealPlanTable)
              ..where((t) => t.id.equals(widget.meal!.id)))
            .write(
          MealPlanTableCompanion(
            mealName: drift.Value(mealName),
            mealType: drift.Value(_selectedMealType),
            description: _descriptionController.text.trim().isEmpty
                ? const drift.Value(null)
                : drift.Value(_descriptionController.text.trim()),
            isActive: drift.Value(_isActive),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e')),
        );
      }
    }
  }

  Future<void> _deleteMeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${widget.meal?.mealName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.meal != null) {
      try {
        final database = ref.read(databaseProvider);
        await (database.delete(database.mealPlanTable)
              ..where((t) => t.id.equals(widget.meal!.id)))
            .go();

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting meal: $e')),
          );
        }
      }
    }
  }
}
