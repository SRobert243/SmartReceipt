import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:math';

class SassyCoachService {
  // ⚠️ PASTEAZĂ CHEIA NOUĂ AICI (cea din proiectul disco-skyline)
  static const String _apiKey = 'AIzaSyDajw5EgViJovGtM-Z_060ewEr505PkQYE';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  late final Random _random;
  
  final List<String> _sassyResponses = [
    "you fat fuck",
    "get a life loser",
    "broke as fuck fr fr",
    "seek help bestie",
    "this is why you're poor",
    "unhinged behavior ngl",
    "bro WHAT 💀",
    "that's absolutely unserious",
    "L take honestly",
    "touch grass maybe",
  ];

  SassyCoachService() {
    _random = Random();
    _model = GenerativeModel(
      // Folosim modelul Flash care e rapid pentru chat
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0, 
      ),
      systemInstruction: Content.system(
        "You are a toxic financial friend. "
        "Analyze text I give you (receipts or chat questions). "
        "If it's a receipt, find the most expensive or unhealthy item and roast me. "
        "If it's a question, answer it but be rude, sassy, and judgmental. "
        "Always imply the user is broke or making bad life choices. "
        "Use Gen Z slang. Keep responses short."
      ),
    );

    // ✅ ASTA LIPSEA: Inițializăm sesiunea de chat
    _chatSession = _model.startChat();
  }

  // ✅ Folosește funcția asta în ecranul de chat, nu getRoast
  Future<String> sendMessage(String text) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      return response.text ?? _getRandomSassyResponse();
    } catch (e) {
      return _getRandomSassyResponse();
    }
  }
  
  String _getRandomSassyResponse() {
    return _sassyResponses[_random.nextInt(_sassyResponses.length)];
  }
}