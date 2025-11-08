import "dart:io";

void main() async {
  final file = File("coverage/lcov.info");

  if (\!await file.exists()) {
    print("Coverage file not found");
    return;
  }

  final lines = await file.readAsLines();

  Map<String, Map<String, int>> fileStats = {};
  String currentFile = "";
  int totalLines = 0;
  int coveredLines = 0;

  for (final line in lines) {
    if (line.startsWith("SF:")) {
      currentFile = line.substring(3);
      fileStats[currentFile] = {"total": 0, "covered": 0};
    } else if (line.startsWith("DA:")) {
      final parts = line.substring(3).split(",");
      if (parts.length >= 2) {
        final hits = int.tryParse(parts[1]) ?? 0;
        totalLines++;
        fileStats[currentFile]?["total"] = (fileStats[currentFile]?["total"] ?? 0) + 1;

        if (hits > 0) {
          coveredLines++;
          fileStats[currentFile]?["covered"] = (fileStats[currentFile]?["covered"] ?? 0) + 1;
        }
      }
    }
  }

  print("Coverage Analysis for Feature Tests:");
  print("=" * 50);

  // Filter for our entity files
  final relevantFiles = fileStats.entries.where((entry) =>
    entry.key.contains("lib/domain/entities/") ||
    entry.key.contains("lib/data/datasources/database.dart")
  ).toList();

  double totalRelevantLines = 0;
  double totalRelevantCovered = 0;

  for (final entry in relevantFiles) {
    final fileName = entry.key.split("/").last;
    final total = entry.value["total"]\!;
    final covered = entry.value["covered"]\!;
    final percentage = total > 0 ? (covered / total * 100) : 0.0;

    if (total > 0) {
      print("$fileName: ${covered}/${total} lines (${percentage.toStringAsFixed(1)}%)");
      totalRelevantLines += total;
      totalRelevantCovered += covered;
    }
  }

  if (totalRelevantLines > 0) {
    final overallPercentage = (totalRelevantCovered / totalRelevantLines * 100);
    print("");
    print("Entity Coverage: ${totalRelevantCovered.toInt()}/${totalRelevantLines.toInt()} lines (${overallPercentage.toStringAsFixed(1)}%)");
  }

  final overallPercentage = totalLines > 0 ? (coveredLines / totalLines * 100) : 0.0;
  print("");
  print("Overall Coverage: ${coveredLines}/${totalLines} lines (${overallPercentage.toStringAsFixed(1)}%)");
}
