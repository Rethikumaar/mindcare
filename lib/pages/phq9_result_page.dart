import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class Phq9ResultPage extends StatelessWidget {
  final int totalScore;
  final String assessment;
  final List<int> responses;
  final int testCount;

  const Phq9ResultPage({
    Key? key,
    required this.totalScore,
    required this.assessment,
    required this.responses,
    required this.testCount,
  }) : super(key: key);

  double get meanScore => responses.isEmpty
      ? 0
      : (responses.reduce((a, b) => a + b) / responses.length);

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(responses.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: responses[index].toDouble(),
            width: 18,
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.green],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PHQ-9 Result"),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Your PHQ-9 Results",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Flexible(
                  child: _infoCard("Total Score", meanScore.toStringAsFixed(2)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoCard("Assessment", assessment, center: true),
            const SizedBox(height: 24),
            const Text(
              "Question-wise Scores",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: 3,
                  barGroups: _generateBarGroups(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Q${value.toInt() + 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 24),    
                ),
                icon: const Icon(Icons.picture_as_pdf,color: Colors.white       ,),
                label: const Text("Download as PDF",style:
                  TextStyle(color: Colors.white),),
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (format) async {
                      final pdf = await _buildPdfDocument();
                      return pdf.save();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, {bool center = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PHQ-9 Result Summary',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Total Score: $totalScore',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('Mean Score: ${meanScore.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('Assessment: $assessment',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 12),
              pw.Text('Question-wise Responses: ${responses.join(', ')}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 24),
              pw.Text('Report generated after test #: $testCount',
                  style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }
}
