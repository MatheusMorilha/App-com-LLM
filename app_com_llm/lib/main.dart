import 'package:app_com_llm/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recomendação de Livros',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppScreen(),
    );
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final TextEditingController _booksController = TextEditingController();
  String _booksRecomendation = '';
  bool _isLoading = false;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {
      // O reconhecimento de voz não está disponível no dispositivo
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _booksController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  Future<void> _getMotivationalMessage() async {
    if (_booksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o assunto no campo de busca')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = api_url_gemini;

      final String prompUserText = _booksController.text;
      final String prompt = '''
        Baseado na descrição informada: "$prompUserText"
        
        Recomende os principais e mais populares livros que se enquadram no assunto. Traga as informações de título do livro, autor e uma breve descrição do que se trata.
      ''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 400,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String content =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _booksRecomendation = content;
        });
      } else {
        setState(() {
          _booksRecomendation =
              'Erro ao obter mensagem: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _booksRecomendation = 'Erro ao conectar com a API';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendação de Livros'),
        backgroundColor: const Color.fromARGB(255, 10, 40, 120),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            if (_booksRecomendation.isNotEmpty) ...[
              const Text(
                'Livros Populares:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _booksRecomendation,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'Diga-me o assunto que deseja se aprofundar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _booksController,
                    decoration: const InputDecoration(
                      hintText: 'Digite uma breve descrição do assunto...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _getMotivationalMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 40, 120),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Text(
                              'Pesquisar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                ),

                const SizedBox(width: 10),
                IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color:
                        _isListening
                            ? Colors.red
                            : const Color.fromARGB(255, 10, 40, 120),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _booksController.dispose();
    super.dispose();
  }
}
