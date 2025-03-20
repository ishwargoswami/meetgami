import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/flashcard_screen.dart';
import 'providers/language_provider.dart';
import 'models/language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(prefs),
      child: const LanguageLearningApp(),
    ),
  );
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: languageProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Language Learning App'),
            actions: [
              IconButton(
                icon: Icon(
                  languageProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: languageProvider.toggleDarkMode,
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language Learning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Score: ${languageProvider.totalScore}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Streak: ${languageProvider.streak} days',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Quiz'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flip),
                  title: const Text('Flashcards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlashcardScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Language',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...supportedLanguages.map(
                  (language) => ListTile(
                    leading: Text(language.flag),
                    title: Text(language.name),
                    selected:
                        languageProvider.selectedLanguage.code == language.code,
                    onTap: () {
                      languageProvider.setLanguage(language);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
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
                      children: [
                        Text(
                          'Learning ${languageProvider.selectedLanguage.name}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        LinearPercentIndicator(
                          lineHeight: 20.0,
                          percent: languageProvider.totalScore / 1000,
                          center: Text('${(languageProvider.totalScore / 10).toStringAsFixed(1)}%'),
                          backgroundColor: Colors.grey[300],
                          progressColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                  child: const Text('Start Quiz'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlashcardScreen(),
                      ),
                    );
                  },
                  child: const Text('Practice with Flashcards'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the Spanish word for "Apple"?',
      'options': ['Manzana', 'Banana', 'Pera', 'Naranja'],
      'answer': 'Manzana'
    },
    {
      'question': 'What is the French word for "Hello"?',
      'options': ['Bonjour', 'Hola', 'Ciao', 'Hallo'],
      'answer': 'Bonjour'
    }
  ];

  void _checkAnswer(String selected) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    if (selected == _questions[_currentIndex]['answer']) {
      setState(() {
        _score++;
      });
      languageProvider.incrementStreak();
      languageProvider.addScore(10);
    } else {
      languageProvider.resetStreak();
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: $_score/${_questions.length}'),
            const SizedBox(height: 10),
            Text(
              'Streak: ${Provider.of<LanguageProvider>(context).streak} days',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _score = 0;
              });
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearPercentIndicator(
              lineHeight: 10.0,
              percent: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              progressColor: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              _questions[_currentIndex]['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ..._questions[_currentIndex]['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  child: Text(option),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _speak(_questions[_currentIndex]['answer']),
              icon: const Icon(Icons.volume_up),
              label: const Text('Hear Pronunciation'),
            ),
          ],
        ),
      ),
    );
  }
}
