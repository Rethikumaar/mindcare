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

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(responses.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: responses[index].toDouble(), // ✅ Corrected from `y` to `toY`
            width: 18,
            gradient: const LinearGradient(colors: [Colors.teal]),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Your PHQ-9 Results",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarGroups(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('Q${value.toInt() + 1}');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Printing.layoutPdf(
                  onLayout: (format) async {
                    final pdf = await _buildPdfDocument();
                    return pdf.save();
                  },
                );
              },
              child: const Text("Download as PDF"),
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
        build: (context) => pw.Column(
          children: [
            pw.Text('PHQ-9 Result Summary', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Responses: ${responses.join(', ')}'),
          ],
        ),
      ),
    );

    return pdf;
  }
}
