import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';

class LanguageProvider extends ChangeNotifier {
  Language _selectedLanguage = supportedLanguages[0];
  int _streak = 0;
  int _totalScore = 0;
  bool _isDarkMode = false;
  final SharedPreferences _prefs;

  LanguageProvider(this._prefs) {
    _loadSavedData();
  }

  Language get selectedLanguage => _selectedLanguage;
  int get streak => _streak;
  int get totalScore => _totalScore;
  bool get isDarkMode => _isDarkMode;

  void _loadSavedData() {
    _streak = _prefs.getInt('streak') ?? 0;
    _totalScore = _prefs.getInt('totalScore') ?? 0;
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    String? languageCode = _prefs.getString('selectedLanguage');
    if (languageCode != null) {
      _selectedLanguage = supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => supportedLanguages[0],
      );
    }
  }

  void setLanguage(Language language) {
    _selectedLanguage = language;
    _prefs.setString('selectedLanguage', language.code);
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    _prefs.setInt('streak', _streak);
    notifyListeners();
  }

  void addScore(int points) {
    _totalScore += points;
    _prefs.setInt('totalScore', _totalScore);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    _prefs.setInt('streak', _streak);
    notifyListeners();
  }
} 