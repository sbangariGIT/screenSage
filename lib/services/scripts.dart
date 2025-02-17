import 'dart:io';
import 'dart:convert';

class ReportFetcher {
  // Method to get the home directory in a platform-independent way
  String getHomeDirectory() {
    return Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  }

  // Method to fetch reports and structure them like the example
  Future<Map<String, Map<String, dynamic>>> getReports() async {
    Map<String, Map<String, dynamic>> reportsMap = {};

    try {
      String homeDirectory = getHomeDirectory();
      if (homeDirectory.isEmpty) {
        throw Exception('Unable to determine home directory');
      }

      // Define the base directory relative to the user's home directory
      String baseDirectory = '$homeDirectory/reports/';

      final reportsDir = Directory(baseDirectory);
      if (await reportsDir.exists()) {
        // List all subdirectories (dates)
        List<FileSystemEntity> dateDirs = reportsDir.listSync();

        for (var dateDir in dateDirs) {
          if (dateDir is Directory) {
            String date = dateDir.path.split(Platform.pathSeparator).last;
            String reportPath = '${dateDir.path}/report.json';
            File reportFile = File(reportPath);

            if (await reportFile.exists()) {
              // Read and parse the report.json file
              String reportContent = await reportFile.readAsString();
              Map<String, dynamic> reportJson = jsonDecode(reportContent);
              reportJson['world_cloud'] = '${dateDir.path}/output.png';
              // Add to the final structure, where the key is the date, and the value is the parsed JSON
              reportsMap[date] = reportJson;
            }
          }
        }
      } else {
        // ignore: avoid_print
        print('Reports directory does not exist');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching reports: $e');
    }
    return reportsMap;
  }
}