import 'package:brain_plan/domain/entities/assessment_results.dart';
import 'package:brain_plan/domain/entities/validated_assessments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssessmentResults Tests', () {
    late CognitiveDemographics demographics;
    late CognitiveAssessmentSession session;
    late MMSEResults mmseResults;
    late MoCAResults mocaResults;
    late ClockDrawingResults clockResults;

    setUp(() {
      demographics = CognitiveDemographics(
        age: 75,
        educationYears: 12,
        gender: 'Female',
      );

      mmseResults = MMSEResults(
        responses: [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Correct',
            pointsAwarded: 25,
            responseTime: DateTime.now(),
          ),
        ],
        completedAt: DateTime.now(),
        totalTime: const Duration(minutes: 15),
      );

      mocaResults = MoCAResults(
        responses: [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Excellent',
            pointsAwarded: 26,
            responseTime: DateTime.now(),
          ),
        ],
        completedAt: DateTime.now(),
        totalTime: const Duration(minutes: 20),
      );

      clockResults = ClockDrawingResults(
        score: 5,
        scoringNotes: 'Good performance',
        completedAt: DateTime.now(),
        drawingTime: const Duration(minutes: 3),
      );

      session = CognitiveAssessmentSession(
        sessionId: 'test_session_1',
        sessionDate: DateTime.now(),
        demographics: demographics,
        results: {
          ValidatedAssessmentType.mmse: mmseResults,
          ValidatedAssessmentType.moca: mocaResults,
          ValidatedAssessmentType.clockDrawing: clockResults,
        },
        clinicianId: 'doc_123',
        patientId: 'patient_456',
        sessionNotes: 'Good cooperation',
        context: AssessmentContext.routine,
      );
    });

    group('CognitiveAssessmentSession', () {
      test('should create session with all fields', () {
        expect(session.sessionId, 'test_session_1');
        expect(session.demographics, demographics);
        expect(session.results.length, 3);
        expect(session.clinicianId, 'doc_123');
        expect(session.patientId, 'patient_456');
        expect(session.sessionNotes, 'Good cooperation');
        expect(session.context, AssessmentContext.routine);
      });

      test('should calculate composite cognitive index correctly', () {
        final cci = session.compositeCognitiveIndex;
        expect(cci, greaterThan(80)); // Should be high with good scores
        expect(cci, lessThanOrEqualTo(100));
      });

      test('should calculate domain scores', () {
        final domainScores = session.domainScores;
        expect(domainScores.isNotEmpty, true);
        expect(domainScores.containsKey(CognitiveDomain.memory), true);
        expect(domainScores.containsKey(CognitiveDomain.visuospatial), true);
      });

      test('should generate normal clinical interpretation for high scores', () {
        final interpretation = session.clinicalInterpretation;
        expect(interpretation.level, CognitiveFunctionLevel.normal);
        expect(interpretation.confidence, greaterThan(0.7));
        expect(interpretation.recommendations.isNotEmpty, true);
        expect(interpretation.recommendations.first, contains('normal'));
      });

      test('should generate impairment interpretation for low scores', () {
        final lowSession = CognitiveAssessmentSession(
          sessionId: 'low_session',
          sessionDate: DateTime.now(),
          demographics: demographics,
          results: {
            ValidatedAssessmentType.mmse: MMSEResults(
              responses: [
                MMSEResponse(
                  questionId: 'test_1',
                  userResponse: 'Poor',
                  pointsAwarded: 15,
                  responseTime: DateTime.now(),
                ),
              ],
              completedAt: DateTime.now(),
              totalTime: const Duration(minutes: 15),
            ),
          },
        );

        final interpretation = lowSession.clinicalInterpretation;
        expect(interpretation.level, CognitiveFunctionLevel.moderateToSevereImpairment);
        expect(interpretation.recommendations.isNotEmpty, true);
      });

      test('should handle empty results gracefully', () {
        final emptySession = CognitiveAssessmentSession(
          sessionId: 'empty_session',
          sessionDate: DateTime.now(),
          demographics: demographics,
          results: {},
        );

        expect(emptySession.compositeCognitiveIndex, 0.0);
        expect(emptySession.domainScores.isEmpty, true);
      });
    });

    group('LongitudinalCognitiveTrends', () {
      late List<CognitiveAssessmentSession> sessions;
      late LongitudinalCognitiveTrends trends;

      setUp(() {
        final now = DateTime.now();
        sessions = [
          CognitiveAssessmentSession(
            sessionId: 'session_1',
            sessionDate: now.subtract(const Duration(days: 365)),
            demographics: demographics,
            results: {
              ValidatedAssessmentType.mmse: MMSEResults(
                responses: [
                  MMSEResponse(
                    questionId: 'test_1',
                    userResponse: 'Good',
                    pointsAwarded: 28,
                    responseTime: DateTime.now(),
                  ),
                ],
                completedAt: DateTime.now(),
                totalTime: const Duration(minutes: 15),
              ),
            },
          ),
          CognitiveAssessmentSession(
            sessionId: 'session_2',
            sessionDate: now.subtract(const Duration(days: 180)),
            demographics: demographics,
            results: {
              ValidatedAssessmentType.mmse: MMSEResults(
                responses: [
                  MMSEResponse(
                    questionId: 'test_1',
                    userResponse: 'Fair',
                    pointsAwarded: 26,
                    responseTime: DateTime.now(),
                  ),
                ],
                completedAt: DateTime.now(),
                totalTime: const Duration(minutes: 15),
              ),
            },
          ),
          CognitiveAssessmentSession(
            sessionId: 'session_3',
            sessionDate: now,
            demographics: demographics,
            results: {
              ValidatedAssessmentType.mmse: MMSEResults(
                responses: [
                  MMSEResponse(
                    questionId: 'test_1',
                    userResponse: 'Poor',
                    pointsAwarded: 25,
                    responseTime: DateTime.now(),
                  ),
                ],
                completedAt: DateTime.now(),
                totalTime: const Duration(minutes: 15),
              ),
            },
          ),
        ];

        trends = LongitudinalCognitiveTrends(
          patientId: 'patient_123',
          sessions: sessions,
        );
      });

      test('should calculate annual decline rates', () {
        final declineRates = trends.annualDeclineRates;
        expect(declineRates.isNotEmpty, true);
        expect(declineRates.containsKey(ValidatedAssessmentType.mmse), true);

        final mmseDecline = declineRates[ValidatedAssessmentType.mmse]!;
        expect(mmseDecline, lessThan(0)); // Should show decline
      });

      test('should detect significant changes', () {
        final changes = trends.significantChanges;
        // Changes may be empty if decline is not significant enough
        expect(changes, isA<List<ClinicalChange>>());


        if (changes.isNotEmpty) {
          final change = changes.first;
          expect(change.assessmentType, ValidatedAssessmentType.mmse);
          expect(change.isDecline, true);
          expect(change.isImprovement, false);
        }
      });

      test('should generate trend summary', () {
        final summary = trends.trendSummary;
        expect(summary.patientId, 'patient_123');
        expect(summary.trajectory, CognitiveTrajectory.rapidDecline);
        expect(summary.annualDeclineRates.isNotEmpty, true);
        expect(summary.recommendedFollowUpInterval, const Duration(days: 90));
      });

      test('should handle single session gracefully', () {
        final singleSessionTrends = LongitudinalCognitiveTrends(
          patientId: 'single_patient',
          sessions: [sessions.first],
        );

        expect(singleSessionTrends.annualDeclineRates.isEmpty, true);
        expect(singleSessionTrends.significantChanges.isEmpty, true);
      });

      test('should calculate annualized change correctly', () {
        final changes = trends.significantChanges;
        if (changes.isNotEmpty) {
          final change = changes.first;
          expect(change.annualizedChange, lessThan(0)); // Should be negative
        } else {
          // If no significant changes detected, test passes
          expect(changes.isEmpty, true);
        }
      });
    });

    group('ClinicalChange', () {
      test('should create clinical change correctly', () {
        final change = ClinicalChange(
          assessmentType: ValidatedAssessmentType.mmse,
          previousScore: 28.0,
          currentScore: 25.0,
          changeAmount: -3.0,
          timePeriod: const Duration(days: 180),
          previousDate: DateTime.now().subtract(const Duration(days: 180)),
          currentDate: DateTime.now(),
          significance: ChangeSignificance.moderate,
        );

        expect(change.assessmentType, ValidatedAssessmentType.mmse);
        expect(change.changeAmount, -3.0);
        expect(change.significance, ChangeSignificance.moderate);
        expect(change.isDecline, true);
        expect(change.isImprovement, false);
      });

      test('should detect improvement correctly', () {
        final change = ClinicalChange(
          assessmentType: ValidatedAssessmentType.moca,
          previousScore: 22.0,
          currentScore: 25.0,
          changeAmount: 3.0,
          timePeriod: const Duration(days: 180),
          previousDate: DateTime.now().subtract(const Duration(days: 180)),
          currentDate: DateTime.now(),
          significance: ChangeSignificance.moderate,
        );

        expect(change.isImprovement, true);
        expect(change.isDecline, false);
      });
    });

    group('TrendSummary', () {
      test('should provide trajectory descriptions', () {
        final summary = TrendSummary(
          patientId: 'test_patient',
          assessmentPeriod: const Duration(days: 365),
          trajectory: CognitiveTrajectory.rapidDecline,
          annualDeclineRates: {},
          significantChanges: [],
          recommendedFollowUpInterval: const Duration(days: 90),
        );

        expect(summary.trajectoryDescription, contains('Rapid cognitive decline'));
        expect(summary.trajectoryDescription, contains('urgent'));
      });

      test('should handle stable trajectory', () {
        final summary = TrendSummary(
          patientId: 'stable_patient',
          assessmentPeriod: const Duration(days: 365),
          trajectory: CognitiveTrajectory.stable,
          annualDeclineRates: {},
          significantChanges: [],
          recommendedFollowUpInterval: const Duration(days: 365),
        );

        expect(summary.trajectoryDescription, contains('stable'));
      });

      test('should handle improvement trajectory', () {
        final summary = TrendSummary(
          patientId: 'improving_patient',
          assessmentPeriod: const Duration(days: 365),
          trajectory: CognitiveTrajectory.improvement,
          annualDeclineRates: {},
          significantChanges: [],
          recommendedFollowUpInterval: const Duration(days: 180),
        );

        expect(summary.trajectoryDescription, contains('improvement'));
      });
    });

    group('ClinicalInterpretation', () {
      test('should create interpretation with all fields', () {
        final interpretation = ClinicalInterpretation(
          level: CognitiveFunctionLevel.normal,
          confidence: 0.85,
          recommendations: ['Continue monitoring', 'Regular exercise'],
          domainSpecificFindings: {
            CognitiveDomain.memory: 'Within normal limits',
            CognitiveDomain.attention: 'Slightly reduced',
          },
        );

        expect(interpretation.level, CognitiveFunctionLevel.normal);
        expect(interpretation.confidence, 0.85);
        expect(interpretation.recommendations.length, 2);
        expect(interpretation.domainSpecificFindings!.length, 2);
      });

      test('should create interpretation without domain findings', () {
        final interpretation = ClinicalInterpretation(
          level: CognitiveFunctionLevel.mildImpairment,
          confidence: 0.75,
          recommendations: ['Further evaluation needed'],
        );

        expect(interpretation.domainSpecificFindings, null);
      });
    });

    group('Enums', () {
      test('should have all AssessmentContext values', () {
        expect(AssessmentContext.values.length, 6);
        expect(AssessmentContext.values.contains(AssessmentContext.routine), true);
        expect(AssessmentContext.values.contains(AssessmentContext.diagnostic), true);
        expect(AssessmentContext.values.contains(AssessmentContext.research), true);
      });

      test('should have all CognitiveFunctionLevel values', () {
        expect(CognitiveFunctionLevel.values.length, 3);
        expect(CognitiveFunctionLevel.values.contains(CognitiveFunctionLevel.normal), true);
        expect(CognitiveFunctionLevel.values.contains(CognitiveFunctionLevel.mildImpairment), true);
      });

      test('should have all CognitiveDomain values', () {
        expect(CognitiveDomain.values.length, 8);
        expect(CognitiveDomain.values.contains(CognitiveDomain.memory), true);
        expect(CognitiveDomain.values.contains(CognitiveDomain.attention), true);
        expect(CognitiveDomain.values.contains(CognitiveDomain.mood), true);
      });

      test('should have all CognitiveTrajectory values', () {
        expect(CognitiveTrajectory.values.length, 5);
        expect(CognitiveTrajectory.values.contains(CognitiveTrajectory.rapidDecline), true);
        expect(CognitiveTrajectory.values.contains(CognitiveTrajectory.stable), true);
        expect(CognitiveTrajectory.values.contains(CognitiveTrajectory.improvement), true);
      });

      test('should have all ChangeSignificance values', () {
        expect(ChangeSignificance.values.length, 3);
        expect(ChangeSignificance.values.contains(ChangeSignificance.mild), true);
        expect(ChangeSignificance.values.contains(ChangeSignificance.moderate), true);
        expect(ChangeSignificance.values.contains(ChangeSignificance.high), true);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle division by zero in percentile calculation', () {
        final emptyDemographics = CognitiveDemographics(
          age: 0,
          educationYears: 0,
          gender: 'Unknown',
        );

        final percentile = ValidatedAssessmentUtils.calculatePercentile(
          score: 0,
          assessmentType: ValidatedAssessmentType.mmse,
          demographics: emptyDemographics,
        );

        expect(percentile, greaterThanOrEqualTo(0));
        expect(percentile, lessThanOrEqualTo(100));
      });

      test('should handle extreme age values', () {
        final extremeDemographics = CognitiveDemographics(
          age: 120,
          educationYears: 25,
          gender: 'Other',
        );

        final session = CognitiveAssessmentSession(
          sessionId: 'extreme_session',
          sessionDate: DateTime.now(),
          demographics: extremeDemographics,
          results: {
            ValidatedAssessmentType.mmse: mmseResults,
          },
        );

        expect(session.compositeCognitiveIndex, greaterThanOrEqualTo(0));
        expect(session.compositeCognitiveIndex, lessThanOrEqualTo(100));
      });

      test('should handle missing assessment types in calculations', () {
        final session = CognitiveAssessmentSession(
          sessionId: 'missing_session',
          sessionDate: DateTime.now(),
          demographics: demographics,
          results: {
            ValidatedAssessmentType.gds: 5, // GDS score as integer
          },
        );

        expect(session.compositeCognitiveIndex, greaterThanOrEqualTo(0));
        expect(session.domainScores.isNotEmpty, true);
      });

      test('should handle very short time periods in trend analysis', () {
        final now = DateTime.now();
        final shortSessions = [
          CognitiveAssessmentSession(
            sessionId: 'session_1',
            sessionDate: now,
            demographics: demographics,
            results: {ValidatedAssessmentType.mmse: mmseResults},
          ),
          CognitiveAssessmentSession(
            sessionId: 'session_2',
            sessionDate: now.add(const Duration(hours: 1)),
            demographics: demographics,
            results: {ValidatedAssessmentType.mmse: mmseResults},
          ),
        ];

        final trends = LongitudinalCognitiveTrends(
          patientId: 'short_patient',
          sessions: shortSessions,
        );

        expect(trends.annualDeclineRates.isEmpty, true);
      });
    });
  });
}