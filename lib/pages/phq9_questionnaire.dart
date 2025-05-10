import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'phq9_result_page.dart';

class PHQ9Questionnaire extends StatefulWidget {
  const PHQ9Questionnaire({super.key});

  @override
  _PHQ9QuestionnaireState createState() => _PHQ9QuestionnaireState();
}

class _PHQ9QuestionnaireState extends State<PHQ9Questionnaire> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _questions = [
    'Little interest or pleasure in doing things?',
    'Feeling down, depressed, or hopeless?',
    'Trouble falling or staying asleep, or sleeping too much?',
    'Feeling tired or having little energy?',
    'Poor appetite or overeating?',
    'Feeling bad about yourself — or that you are a failure or have let yourself or your family down?',
    'Trouble concentrating on things, such as reading the newspaper or watching television?',
    'Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?',
    'Thoughts that you would be better off dead or of hurting yourself in some way?',
  ];

  final List<Map<String, dynamic>> _answerOptions = [
    {'value': 0, 'label': 'Not at all'},
    {'value': 1, 'label': 'Several days'},
    {'value': 2, 'label': 'More than half the days'},
    {'value': 3, 'label': 'Nearly every day'},
  ];

  int _currentIndex = 0;
  final List<int?> _responses = List.filled(9, null);
  bool _isLoading = false;
  String? _userId = "rethi";

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    var user = _auth.currentUser;
    if (user != null) {
      try {
        var docSnapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        var username = docSnapshot.data()?['username'] as String?;
        setState(() {
          _userId = username;
        });
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
  }

  void _selectAnswer(int value) {
    setState(() {
      _responses[_currentIndex] = value;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _submit();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  Future<void> _submit() async {
    if (_responses.contains(null)) {
      _showSnackBar('Please answer all questions before submitting.');
      return;
    }

    if (_userId == null) {
      _showSnackBar('User ID not available. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final submitUrl = Uri.parse('https://akash297-mindcare.hf.space/api/submit_phq9/');
    final resultUrl = Uri.parse('https://akash297-mindcare.hf.space/api/phq9_results/');

    try {
      await http.post(
        submitUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': _userId,
          'responses': _responses,
        }),
      );

      final resultRes = await http.get(Uri.parse('${resultUrl.toString()}?user_id=$_userId'));
      final resultList = jsonDecode(resultRes.body);
      final result = resultList[0];

      int score = 0;
      String? scoreString = result['responses']?.toString();
      if (scoreString != null) {
        score = int.tryParse(scoreString) ?? 0;
      }

      String assessment = result['prediction'] ?? 'Unknown';

      await _saveHistory(score, assessment);
      _navigateToResultPage(score, assessment, _responses.cast<int>());
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHistory(int score, String assessment) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('phq9_history') ?? [];

    final entry = jsonEncode({
      'date': DateTime.now().toIso8601String(),
      'score': score,
      'assessment': assessment,
    });

    historyList.add(entry);
    await prefs.setStringList('phq9_history', historyList);
  }

  void _navigateToResultPage(int score, String assessment, List<int> responses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Phq9ResultPage(
          totalScore: score,
          assessment: assessment,
          responses: responses,
          testCount: 1, // Replace this with the actual test count if available
        ),
      ),
    );
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildQuestionSection() {
    final question = _questions[_currentIndex];
    final selected = _responses[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_currentIndex + 1} of ${_questions.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text(question, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        ..._answerOptions.map((option) {
          return RadioListTile<int>(
            value: option['value'],
            groupValue: selected,
            onChanged: (value) => _selectAnswer(value!),
            title: Text(option['label']),
          );
        }),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final selected = _responses[_currentIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentIndex > 0)
          ElevatedButton(
            onPressed: _previous,
            child: const Text('Previous'),
          ),
        ElevatedButton(
          onPressed: selected != null && !_isLoading ? _next : null,
          child: Text(_currentIndex == _questions.length - 1 ? 'Submit' : 'Next'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PHQ-9 Questionnaire')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildQuestionSection(),
                const Spacer(),
                _buildNavigationButtons(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
