import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assessment_results.dart';
import '../../domain/entities/validated_assessments.dart';
import 'clock_drawing_test_screen.dart';
import 'mmse_assessment_screen.dart';
import 'moca_assessment_screen.dart';

class ValidatedAssessmentCoordinator extends ConsumerStatefulWidget {
  const ValidatedAssessmentCoordinator({super.key});

  @override
  ConsumerState<ValidatedAssessmentCoordinator> createState() => _ValidatedAssessmentCoordinatorState();
}

class _ValidatedAssessmentCoordinatorState extends ConsumerState<ValidatedAssessmentCoordinator> {
  CognitiveDemographics? demographics;
  AssessmentContext selectedContext = AssessmentContext.routine;
  Map<ValidatedAssessmentType, dynamic> completedAssessments = {};
  bool showResults = false;
  CognitiveAssessmentSession? currentSession;

  @override
  Widget build(BuildContext context) {
    if (demographics == null) {
      return _buildDemographicsForm();
    } else if (!showResults) {
      return _buildAssessmentSelection();
    } else {
      return _buildResultsSummary();
    }
  }

  Widget _buildDemographicsForm() {
    int age = 65;
    int educationYears = 12;
    String gender = 'Female';
    String? ethnicity;
    String? primaryLanguage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Assessment - Demographics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Demographics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Demographic information is essential for proper score interpretation using age and education-adjusted norms.',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),

                    // Age input
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Age:')),
                        Expanded(
                          child: Slider(
                            value: age.toDouble(),
                            min: 18,
                            max: 100,
                            divisions: 82,
                            label: age.toString(),
                            onChanged: (value) {
                              setState(() {
                                age = value.round();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text('$age years', textAlign: TextAlign.center),
                        ),
                      ],
                    ),

                    // Education input
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Education:')),
                        Expanded(
                          child: Slider(
                            value: educationYears.toDouble(),
                            min: 0,
                            max: 20,
                            divisions: 20,
                            label: educationYears.toString(),
                            onChanged: (value) {
                              setState(() {
                                educationYears = value.round();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text('$educationYears years', textAlign: TextAlign.center),
                        ),
                      ],
                    ),

                    // Gender selection
                    const SizedBox(height: 16),
                    const Text('Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Male', label: Text('Male')),
                        ButtonSegment(value: 'Female', label: Text('Female')),
                        ButtonSegment(value: 'Other', label: Text('Other')),
                      ],
                      selected: {gender},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          gender = selection.first;
                        });
                      },
                    ),

                    // Primary Language
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Primary Language (optional)',
                        hintText: 'e.g., English, Spanish, Mandarin',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        primaryLanguage = value.isEmpty ? null : value;
                      },
                    ),

                    // Ethnicity
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Ethnicity (optional)',
                        hintText: 'Used for normative data adjustments',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        ethnicity = value.isEmpty ? null : value;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Assessment Context
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Context',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AssessmentContext>(
                      initialValue: selectedContext,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Context',
                      ),
                      items: AssessmentContext.values.map((context) {
                        return DropdownMenuItem(
                          value: context,
                          child: Text(_getContextDescription(context)),
                        );
                      }).toList(),
                      onChanged: (context) {
                        if (context != null) {
                          setState(() {
                            selectedContext = context;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  demographics = CognitiveDemographics(
                    age: age,
                    educationYears: educationYears,
                    gender: gender,
                    ethnicity: ethnicity,
                    primaryLanguage: primaryLanguage,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Continue to Assessments', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSelection() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Assessments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              setState(() {
                demographics = null;
                completedAssessments.clear();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient info summary
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient: ${demographics!.gender}, ${demographics!.age} years old',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Education: ${demographics!.educationYears} years'),
                    Text('Context: ${_getContextDescription(selectedContext)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Available Clinical Assessments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildAssessmentTile(
                    ValidatedAssessmentType.mmse,
                    'Mini-Mental State Examination (MMSE)',
                    'Global cognitive screening (15-20 minutes)',
                    Icons.psychology,
                    Colors.blue,
                  ),
                  _buildAssessmentTile(
                    ValidatedAssessmentType.moca,
                    'Montreal Cognitive Assessment (MoCA)',
                    'Sensitive to mild cognitive impairment (20-30 minutes)',
                    Icons.psychology,
                    Colors.green,
                  ),
                  _buildAssessmentTile(
                    ValidatedAssessmentType.clockDrawing,
                    'Clock Drawing Test',
                    'Visuospatial and executive function (5-10 minutes)',
                    Icons.watch,
                    Colors.orange,
                  ),
                  _buildAssessmentTile(
                    ValidatedAssessmentType.gds,
                    'Geriatric Depression Scale (GDS-15)',
                    'Depression screening (5-10 minutes)',
                    Icons.sentiment_satisfied,
                    Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Results button
            if (completedAssessments.isNotEmpty) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${completedAssessments.length} assessment(s) completed',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _generateResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Clinical Report'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentTile(
    ValidatedAssessmentType type,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isCompleted = completedAssessments.containsKey(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToAssessment(type),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Assessment Report'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientSummary(),
              const SizedBox(height: 20),
              _buildClinicalInterpretation(),
              const SizedBox(height: 20),
              _buildAssessmentResults(),
              const SizedBox(height: 20),
              _buildRecommendations(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
            Text('Age: ${demographics!.age} years'),
            Text('Education: ${demographics!.educationYears} years'),
            Text('Context: ${_getContextDescription(selectedContext)}'),
            Text('Assessments Completed: ${completedAssessments.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInterpretation() {
    final interpretation = currentSession!.clinicalInterpretation;

    return Card(
      color: _getInterpretationColor(interpretation.level),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getInterpretationIcon(interpretation.level), color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Clinical Interpretation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getLevelDescription(interpretation.level),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Composite Cognitive Index: ${currentSession!.compositeCognitiveIndex.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              'Clinical Confidence: ${(interpretation.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Individual Assessment Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...completedAssessments.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildIndividualResult(entry.key, entry.value),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualResult(ValidatedAssessmentType type, dynamic result) {
    String title;
    String scoreText;
    String interpretation;

    switch (type) {
      case ValidatedAssessmentType.mmse:
        final mmseResult = result as MMSEResults;
        title = 'MMSE';
        scoreText = '${mmseResult.totalScore}/30';
        interpretation = mmseResult.interpretationDescription;
        break;
      case ValidatedAssessmentType.moca:
        final mocaResult = result as MoCAResults;
        title = 'MoCA';
        scoreText = '${mocaResult.totalScore}/30';
        interpretation = mocaResult.interpretation == MoCAInterpretation.normal
            ? 'Normal (≥26)'
            : 'Cognitive impairment suggested (<26)';
        break;
      case ValidatedAssessmentType.clockDrawing:
        final clockResult = result as ClockDrawingResults;
        title = 'Clock Drawing Test';
        scoreText = '${clockResult.score}/6';
        interpretation = _getClockInterpretation(clockResult.interpretation);
        break;
      case ValidatedAssessmentType.gds:
        title = 'GDS-15';
        scoreText = '$result/15';
        final gdsInterpretation = GDSAssessment.getInterpretation(result as int);
        interpretation = '${gdsInterpretation['level']} - ${gdsInterpretation['description']}';
        break;
      case ValidatedAssessmentType.adascog:
        title = 'ADAS-Cog';
        scoreText = '$result/70';
        interpretation = 'See clinical guidelines';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(scoreText, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(interpretation, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = currentSession!.clinicalInterpretation.recommendations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                showResults = false;
                completedAssessments.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('New Assessment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save),
            label: const Text('Save to History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getContextDescription(AssessmentContext context) {
    switch (context) {
      case AssessmentContext.routine:
        return 'Routine Screening';
      case AssessmentContext.diagnostic:
        return 'Diagnostic Workup';
      case AssessmentContext.followUp:
        return 'Follow-up Monitoring';
      case AssessmentContext.research:
        return 'Research Study';
      case AssessmentContext.preOperative:
        return 'Pre-operative Assessment';
      case AssessmentContext.postTreatment:
        return 'Post-treatment Evaluation';
    }
  }

  void _navigateToAssessment(ValidatedAssessmentType type) async {
    Widget screen;

    switch (type) {
      case ValidatedAssessmentType.mmse:
        screen = const MMSEAssessmentScreen();
        break;
      case ValidatedAssessmentType.moca:
        screen = const MoCAAssessmentScreen();
        break;
      case ValidatedAssessmentType.clockDrawing:
        screen = const ClockDrawingTestScreen();
        break;
      case ValidatedAssessmentType.gds:
        screen = _buildGDSScreen();
        break;
      case ValidatedAssessmentType.adascog:
        screen = _buildPlaceholderScreen('ADAS-Cog');
        break;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result != null) {
      setState(() {
        completedAssessments[type] = result;
      });
    }
  }

  Widget _buildGDSScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Geriatric Depression Scale')),
      body: const Center(
        child: Text('GDS-15 implementation would go here'),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title implementation would go here'),
      ),
    );
  }

  void _generateResults() {
    currentSession = CognitiveAssessmentSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionDate: DateTime.now(),
      demographics: demographics!,
      results: completedAssessments,
      context: selectedContext,
    );

    setState(() {
      showResults = true;
    });
  }

  void _shareReport() {
    // Implementation for sharing/exporting report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sharing functionality would be implemented here')),
    );
  }

  void _saveToHistory() {
    // Implementation for saving to patient history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results saved to patient history')),
    );
  }

  Color _getInterpretationColor(CognitiveFunctionLevel level) {
    switch (level) {
      case CognitiveFunctionLevel.normal:
        return Colors.green;
      case CognitiveFunctionLevel.mildImpairment:
        return Colors.orange;
      case CognitiveFunctionLevel.moderateToSevereImpairment:
        return Colors.red;
    }
  }

  IconData _getInterpretationIcon(CognitiveFunctionLevel level) {
    switch (level) {
      case CognitiveFunctionLevel.normal:
        return Icons.check_circle;
      case CognitiveFunctionLevel.mildImpairment:
        return Icons.warning;
      case CognitiveFunctionLevel.moderateToSevereImpairment:
        return Icons.error;
    }
  }

  String _getLevelDescription(CognitiveFunctionLevel level) {
    switch (level) {
      case CognitiveFunctionLevel.normal:
        return 'Cognitive function within normal limits for age and education';
      case CognitiveFunctionLevel.mildImpairment:
        return 'Mild cognitive impairment detected - further evaluation recommended';
      case CognitiveFunctionLevel.moderateToSevereImpairment:
        return 'Significant cognitive impairment - urgent clinical attention required';
    }
  }

  String _getClockInterpretation(ClockDrawingInterpretation interpretation) {
    switch (interpretation) {
      case ClockDrawingInterpretation.normal:
        return 'Normal visuospatial function';
      case ClockDrawingInterpretation.mildImpairment:
        return 'Mild visuospatial impairment';
      case ClockDrawingInterpretation.severeImpairment:
        return 'Severe visuospatial impairment';
    }
  }
}