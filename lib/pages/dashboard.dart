import '../services/scripts.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:percent_indicator/percent_indicator.dart'; // You can use this package for progress bars

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedReport = 'Day 1'; // To keep track of selected report
  ReportFetcher reportFetcher = ReportFetcher();
  Map<String, Map<String, dynamic>> reports =
      {}; // Initialize the reports variable
  // ignore: non_constant_identifier_names
  bool fetched_reports = false;

  List<String> daysOfWeek = [];

  Future<void> _fetchReports() async {
    try {
      reports =
          await reportFetcher.getReports(); // Fetch reports asynchronously
      setState(() {
        // Update the state to reflect the fetched reports
        daysOfWeek = reports.keys.toList();
        fetched_reports = true;
        if (daysOfWeek.isNotEmpty) {
          selectedReport = daysOfWeek[0];
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching reports: $e');
    }
  }

  @override
  void initState() {
    _fetchReports(); // Call the function to fetch reports
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Screen Sage Dashboard')),
      body: !fetched_reports
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Sidebar
                Container(
                  width: 200,
                  child: ListView.builder(
                    itemCount: daysOfWeek.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text(daysOfWeek[index]),
                          selected: selectedReport == daysOfWeek[index],
                          onTap: () {
                            setState(() {
                              selectedReport = daysOfWeek[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Right Report Display
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: buildReportContent(reports[selectedReport]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

// Function to build the report content
  Widget buildReportContent(Map<String, dynamic>? report) {
    if (report == null) {
      return const Center(child: Text('No report available.'));
    }
    final wellnessScore = report["content_analysis"]["overall_wellness_score"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular Progress Indicator to mimic an odometer-like score display
        Center(
          child: CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 13.0,
            animation: true,
            percent: wellnessScore / 100,
            center: Text(
              "${wellnessScore.toInt()}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.green),
            ),
            footer: const Text(
              "Wellness Score",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
          ),
        ),
        const Text(
          'Content Analysis',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: Image.asset(
            report['world_cloud'],
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(report["content_analysis"]["summary"]),
          ),
        ),
        const SizedBox(height: 10),

        _buildSectionTitle('Problematic Usage Patterns'),
        ...report["problematic_usage_patterns"]["issues"]
            .map<Widget>((issue) => _buildIssueCard(issue))
            .toList(),
        const SizedBox(height: 20),

        _buildSectionTitle('Positive Usage Patterns'),
        ...report["positive_usage"]["patterns"]
            .map<Widget>((issue) => _buildPatternCard(issue))
            .toList(),

        const SizedBox(height: 20),
        _buildSectionTitle('Recommendations'),
        ...report["recommendations"]["suggestions"]
            .map<Widget>((issue) => _buildRecommendationCard(issue))
            .toList(),
      ],
    );
  }

// Function to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.report, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

// Function to build issue card
  Widget _buildIssueCard(Map<String, dynamic> issue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue["issue"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(issue["description"]),
          ],
        ),
      ),
    );
  }

// Function to build pattern card
  Widget _buildPatternCard(Map<String, dynamic> issue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue["pattern"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(issue["description"]),
          ],
        ),
      ),
    );
  }

// Function to build recommendation card
  Widget _buildRecommendationCard(Map<String, dynamic> issue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue["recommendation"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(issue["details"]),
          ],
        ),
      ),
    );
  }
}
