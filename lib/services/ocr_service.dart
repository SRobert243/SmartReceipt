import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> scanReceipt(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // We join all the text found on the receipt into one big string
      // so the AI can analyze it.
      String fullText = recognizedText.text;
      
      return fullText.isEmpty ? "No text found on receipt." : fullText;
    } catch (e) {
      return "Error scanning receipt: $e";
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}