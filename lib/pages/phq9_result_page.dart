import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PHQ9ResultPage extends StatelessWidget {
  final int totalScore;
  final String assessment;
  final int testCount;

  const PHQ9ResultPage({
    Key? key,
    required this.totalScore,
    required this.assessment,
    required this.testCount,
  }) : super(key: key);

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PHQ-9 Test Result', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Total Score: $totalScore'),
            pw.Text('Assessment: $assessment'),
            pw.Text('Number of Attempts: $testCount'),
            pw.SizedBox(height: 24),
            pw.Text('Date: ${DateTime.now()}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PHQ-9 Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your PHQ-9 Score',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Total Score: $totalScore', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Assessment: $assessment', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text(
              'You have taken this test $testCount time${testCount > 1 ? 's' : ''}.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _generatePdf(context),
              child: Text('Export Result as PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
