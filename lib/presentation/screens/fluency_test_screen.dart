import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/native_speech_recognition_service.dart';
import '../../core/services/google_cloud_speech_service.dart';
import '../widgets/custom_card.dart';

class FluencyTestScreen extends ConsumerStatefulWidget {
  const FluencyTestScreen({super.key});

  @override
  ConsumerState<FluencyTestScreen> createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends ConsumerState<FluencyTestScreen> {
  final _textController = TextEditingController();
  final _nativeSpeech = NativeSpeechRecognitionService();
  GoogleCloudSpeechService? _cloudSpeech;
  bool _useCloudSpeech = false;
  StreamSubscription<SpeechRecognitionResult>? _cloudSpeechSubscription;
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _testStarted = false;
  bool _testCompleted = false;
  bool _speechEnabled = false;
  bool _speechListening = false;
  String _speechStatus = 'ready';
  double _soundLevel = 0.0;
  final List<String> _enteredWords = [];
  List<String> _validWords = [];
  int _score = 0;
  int _lastProcessedWordCount = 0; // Track how many words we've processed from partial results

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _cloudSpeechSubscription?.cancel();
    _cloudSpeech?.dispose();
    _nativeSpeech.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    print('=== FLUENCY TEST: Initializing speech services ===');

    // Try to initialize Google Cloud Speech first
    _cloudSpeech = GoogleCloudSpeechService();
    final isConfigured = await _cloudSpeech!.isConfigured();

    if (isConfigured) {
      print('✓ Using Google Cloud Speech (no beeping!)');
      _useCloudSpeech = true;

      // Setup Google Cloud Speech streams
      _cloudSpeechSubscription = _cloudSpeech!.resultStream.listen((result) {
        _handleSpeechResult(result.transcript, result.isFinal);
      });

      _cloudSpeech!.errorStream.listen((error) {
        print('=== FLUENCY TEST: Cloud speech error: $error ===');
      });

      _cloudSpeech!.statusStream.listen((status) {
        print('=== FLUENCY TEST: Cloud speech status: $status ===');
      });

      setState(() {
        _speechEnabled = true;
      });
    } else {
      print('⚠️  Using native speech (will beep) - Google Cloud credentials not configured');
      _useCloudSpeech = false;

      // Setup callbacks for native speech recognition (fallback)
      _nativeSpeech.onResult = (String text, bool isFinal) {
        _handleSpeechResult(text, isFinal);
      };

      _nativeSpeech.onError = (String error) {
        print('=== FLUENCY TEST: Native speech error: $error ===');
      };

      _nativeSpeech.onSoundLevel = (double level) {
        if (mounted) {
          setState(() {
            _soundLevel = level;
          });
        }
      };

      _nativeSpeech.onStatus = (String status) {
        print('=== FLUENCY TEST: Native speech status: $status ===');
        if (mounted) {
          setState(() {
            _speechStatus = status;
          });
        }
      };

      setState(() {
        _speechEnabled = true;
      });
    }

    print('=== FLUENCY TEST: Speech initialization complete, enabled: $_speechEnabled ===');
  }

  void _startTest() {
    print('=== FLUENCY TEST: Starting test, _speechEnabled: $_speechEnabled ===');
    setState(() {
      _testStarted = true;
      _remainingSeconds = 60;  // Full 60 seconds
    });

    // Start continuous listening immediately
    _startListening();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _completeTest();
      }
    });
  }

  void _addWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty && !_enteredWords.contains(word)) {
      setState(() {
        _enteredWords.add(word);
        _textController.clear();
      });
    }
  }

  void _startListening() async {
    print('=== FLUENCY TEST: Starting speech recognition ===');
    if (_speechEnabled && !_testCompleted) {
      try {
        if (_useCloudSpeech) {
          await _cloudSpeech!.startListening();
          print('=== FLUENCY TEST: Google Cloud speech started ===');
        } else {
          await _nativeSpeech.startListening();
          print('=== FLUENCY TEST: Native speech started ===');
        }
        setState(() {
          _speechListening = true;
        });
      } catch (e) {
        print('=== FLUENCY TEST: Error starting speech: $e ===');
      }
    }
  }

  void _stopListening() async {
    print('=== FLUENCY TEST: Stopping speech recognition ===');
    try {
      if (_useCloudSpeech) {
        await _cloudSpeech!.stopListening();
      } else {
        await _nativeSpeech.stopListening();
      }
      setState(() {
        _speechListening = false;
      });
    } catch (e) {
      print('=== FLUENCY TEST: Error stopping speech: $e ===');
    }
  }

  void _handleSpeechResult(String text, bool isFinal) {
    final recognizedText = text.toLowerCase().trim();

    // Enhanced debug logging
    print('=== FLUENCY TEST: Speech result ===');
    print('  Final: $isFinal');
    print('  Text: "$recognizedText"');
    print('  Current word count: ${_enteredWords.length}');

    if (recognizedText.isNotEmpty) {
      // Split by multiple delimiters and clean up words
      final words = recognizedText
          .split(RegExp(r'[,\s.!?;:]+'))
          .map((word) => word.trim().replaceAll(RegExp(r'[^\w]'), ''))
          .where((word) => word.isNotEmpty)  // Accept all non-empty words
          .toList();

      print('  Extracted ${words.length} words from text');

      // For partial results: only process NEW words that appeared since last update
      // For final results: process all words
      final int startIndex = isFinal ? 0 : _lastProcessedWordCount;
      final List<String> newWords = words.sublist(startIndex.clamp(0, words.length));

      print('  Processing ${newWords.length} new words (starting from index $startIndex)');

      // Process each new word
      int newWordsAdded = 0;
      for (final String word in newWords) {
        if (word.length < 3) {
          // Skip very short words - likely fragments
          print('  ✗ Skipping "$word" - too short (< 3 chars)');
          continue;
        }

        // Check if this word is similar to any existing word
        // We want to keep the LONGEST version
        bool foundSimilar = false;
        final List<String> wordsToRemove = [];

        for (final String existingWord in _enteredWords) {
          // Check if words are similar (one is a prefix of the other)
          if (existingWord.startsWith(word)) {
            // Existing word is longer - skip this shorter version
            foundSimilar = true;
            print('  ✗ Skipping "$word" - shorter version of existing "$existingWord"');
            break;
          } else if (word.startsWith(existingWord)) {
            // New word is longer - mark old word for removal
            wordsToRemove.add(existingWord);
            foundSimilar = true;
            print('  ↻ Will replace "$existingWord" with longer "$word"');
          }
        }

        if (!foundSimilar) {
          // Completely new word - check if already exists
          if (!_enteredWords.contains(word)) {
            setState(() {
              _enteredWords.add(word);
              newWordsAdded++;
              print('  ✓ Added: "$word"');
            });
          }
        } else if (wordsToRemove.isNotEmpty) {
          // Replace shorter versions with longer version
          setState(() {
            for (final String toRemove in wordsToRemove) {
              _enteredWords.remove(toRemove);
            }
            if (!_enteredWords.contains(word)) {
              _enteredWords.add(word);
              newWordsAdded++;
              print('  ✓ Replaced with: "$word"');
            }
          });
        }
      }

      // Update the last processed count for next partial result
      if (!isFinal) {
        _lastProcessedWordCount = words.length;
      } else {
        // Reset on final result (for next recognition cycle)
        _lastProcessedWordCount = 0;
      }

      if (newWordsAdded > 0) {
        print('  Added $newWordsAdded new word(s). Total: ${_enteredWords.length}');
      }

      print('=== FLUENCY TEST: Result processed (${isFinal ? 'FINAL' : 'PARTIAL'}), total words captured: ${_enteredWords.length} ===');
    }
  }

  void _completeTest() {
    _timer?.cancel();
    _stopListening();
    setState(() {
      _testCompleted = true;
    });
    _calculateScore();
  }

  void _calculateScore() {
    // Comprehensive animal list - 500+ animals
    final commonAnimals = [
      // Domestic animals
      'cat', 'dog', 'horse', 'cow', 'pig', 'sheep', 'goat', 'chicken', 'duck', 'goose',
      'turkey', 'donkey', 'mule', 'rabbit', 'hamster', 'guinea pig', 'gerbil', 'chinchilla',
      'ferret', 'rat', 'mouse', 'canary', 'parakeet', 'parrot', 'cockatoo', 'macaw',

      // Wild mammals - Carnivores
      'lion', 'tiger', 'leopard', 'cheetah', 'jaguar', 'puma', 'cougar', 'panther', 'lynx',
      'bobcat', 'ocelot', 'caracal', 'serval', 'bear', 'grizzly', 'polar bear', 'panda',
      'black bear', 'wolf', 'coyote', 'fox', 'dingo', 'jackal', 'hyena', 'raccoon',

      // Wild mammals - Herbivores
      'elephant', 'rhinoceros', 'hippopotamus', 'giraffe', 'zebra', 'buffalo', 'bison',
      'moose', 'elk', 'deer', 'caribou', 'reindeer', 'antelope', 'gazelle', 'impala',
      'wildebeest', 'gnu', 'okapi', 'tapir', 'warthog',

      // Primates
      'monkey', 'gorilla', 'chimpanzee', 'orangutan', 'baboon', 'mandrill', 'gibbon',
      'lemur', 'marmoset', 'tamarin', 'macaque', 'langur', 'howler', 'capuchin',

      // Small mammals
      'squirrel', 'chipmunk', 'groundhog', 'marmot', 'prairie dog', 'gopher', 'mole',
      'shrew', 'vole', 'lemming', 'pika', 'hedgehog', 'porcupine', 'skunk', 'badger',
      'weasel', 'mink', 'otter', 'stoat', 'ermine', 'marten', 'mongoose', 'civet',

      // Marsupials
      'kangaroo', 'wallaby', 'koala', 'wombat', 'possum', 'opossum', 'tasmanian devil',
      'quoll', 'bandicoot', 'numbat', 'sugar glider',

      // Unique mammals
      'sloth', 'armadillo', 'anteater', 'aardvark', 'pangolin', 'platypus', 'echidna',

      // Marine mammals
      'whale', 'dolphin', 'porpoise', 'orca', 'narwhal', 'beluga', 'manatee', 'dugong',
      'seal', 'sea lion', 'walrus', 'sea otter',

      // Bats
      'bat', 'fruit bat', 'vampire bat', 'flying fox',

      // Birds - Raptors
      'eagle', 'hawk', 'falcon', 'kestrel', 'osprey', 'kite', 'buzzard', 'harrier',
      'owl', 'barn owl', 'screech owl', 'horned owl', 'snowy owl', 'vulture', 'condor',

      // Birds - Water birds
      'swan', 'pelican', 'heron', 'egret', 'stork', 'crane', 'ibis', 'spoonbill',
      'flamingo', 'cormorant', 'anhinga', 'grebe', 'loon', 'albatross', 'petrel',
      'puffin', 'auk', 'murre', 'guillemot', 'tern', 'gull', 'seagull',

      // Birds - Common
      'robin', 'sparrow', 'finch', 'cardinal', 'blue jay', 'crow', 'raven', 'magpie',
      'blackbird', 'starling', 'thrush', 'warbler', 'wren', 'chickadee', 'titmouse',
      'nuthatch', 'woodpecker', 'flicker', 'sapsucker', 'swallow', 'martin', 'swift',
      'hummingbird', 'kingfisher', 'bee eater', 'roller', 'hoopoe',

      // Birds - Game birds
      'pheasant', 'quail', 'partridge', 'grouse', 'ptarmigan', 'peacock', 'peafowl',

      // Birds - Large/Flightless
      'ostrich', 'emu', 'cassowary', 'rhea', 'kiwi', 'penguin', 'emperor penguin',

      // Birds - Parrots
      'cockatiel', 'budgie', 'lovebird', 'conure', 'lorikeet', 'amazon', 'african grey',

      // Birds - Other
      'pigeon', 'dove', 'cuckoo', 'roadrunner', 'toucan', 'hornbill', 'kinglet',
      'mockingbird', 'catbird', 'thrasher', 'meadowlark', 'oriole', 'tanager', 'grosbeak',
      'bunting', 'crossbill', 'redpoll', 'siskin', 'goldfinch', 'canary', 'weaver',

      // Reptiles
      'snake', 'python', 'boa', 'cobra', 'viper', 'rattlesnake', 'mamba', 'anaconda',
      'lizard', 'iguana', 'gecko', 'chameleon', 'monitor', 'komodo dragon', 'skink',
      'anole', 'bearded dragon', 'turtle', 'tortoise', 'terrapin', 'sea turtle',
      'snapping turtle', 'alligator', 'crocodile', 'caiman', 'gharial',

      // Amphibians
      'frog', 'toad', 'tree frog', 'bull frog', 'poison dart frog', 'salamander',
      'newt', 'axolotl', 'caecilian',

      // Fish - Common
      'fish', 'goldfish', 'carp', 'koi', 'catfish', 'bass', 'trout', 'salmon', 'pike',
      'perch', 'tuna', 'mackerel', 'herring', 'sardine', 'anchovy', 'cod', 'haddock',
      'halibut', 'flounder', 'sole', 'tilapia', 'minnow', 'guppy', 'molly', 'platy',
      'swordtail', 'tetra', 'barb', 'danio', 'rasbora', 'loach', 'betta', 'gourami',

      // Fish - Predatory
      'shark', 'great white', 'hammerhead', 'tiger shark', 'bull shark', 'mako',
      'barracuda', 'piranha', 'gar', 'arapaima', 'snakehead',

      // Fish - Rays
      'ray', 'stingray', 'manta ray', 'electric ray', 'skate',

      // Fish - Other
      'eel', 'moray', 'seahorse', 'pipefish', 'angelfish', 'butterflyfish', 'clownfish',
      'damselfish', 'wrasse', 'parrotfish', 'surgeonfish', 'tang', 'pufferfish',
      'triggerfish', 'filefish', 'boxfish', 'lionfish', 'scorpionfish', 'goby',
      'blenny', 'dragonet', 'mandarin', 'dottyback',

      // Marine invertebrates
      'octopus', 'squid', 'cuttlefish', 'nautilus', 'jellyfish', 'coral', 'anemone',
      'starfish', 'sea star', 'sea urchin', 'sand dollar', 'sea cucumber', 'crab',
      'lobster', 'crayfish', 'shrimp', 'prawn', 'krill', 'barnacle', 'clam', 'oyster',
      'mussel', 'scallop', 'snail', 'slug', 'sea slug', 'nudibranch', 'conch', 'whelk',
      'abalone', 'limpet', 'chiton', 'sea sponge', 'sea pen', 'sea fan',

      // Insects - Common
      'ant', 'bee', 'wasp', 'hornet', 'yellow jacket', 'bumblebee', 'honeybee',
      'butterfly', 'moth', 'caterpillar', 'beetle', 'ladybug', 'firefly', 'lightning bug',
      'fly', 'housefly', 'fruit fly', 'horsefly', 'mosquito', 'gnat', 'midge',
      'dragonfly', 'damselfly', 'grasshopper', 'cricket', 'katydid', 'locust',
      'mantis', 'praying mantis', 'cockroach', 'termite', 'aphid', 'cicada',

      // Arachnids
      'spider', 'tarantula', 'black widow', 'brown recluse', 'wolf spider', 'jumping spider',
      'scorpion', 'tick', 'mite', 'daddy longlegs', 'harvestman',

      // Other arthropods
      'centipede', 'millipede', 'pill bug', 'roly poly', 'woodlouse', 'isopod',

      // Worms
      'worm', 'earthworm', 'roundworm', 'flatworm', 'tapeworm', 'leech', 'bloodworm',

      // Other invertebrates
      'snail', 'slug', 'earthworm', 'leech',
    ];

    _validWords = _enteredWords.where((word) =>
        commonAnimals.contains(word) ||
        word.length >= 3 // Accept any word of 3+ letters as potentially valid
    ).toList();

    setState(() {
      _score = _validWords.length;
    });
  }

  String _getPerformanceLevel() {
    // Based on typical fluency test norms
    if (_score >= 18) return 'Excellent';
    if (_score >= 14) return 'Good';
    if (_score >= 10) return 'Average';
    if (_score >= 7) return 'Below Average';
    return 'Poor';
  }

  Color _getPerformanceColor() {
    if (_score >= 18) return Colors.green;
    if (_score >= 14) return Colors.lightGreen;
    if (_score >= 10) return Colors.orange;
    if (_score >= 7) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Fluency Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_testStarted) _buildInstructions(),
            if (_testStarted && !_testCompleted) _buildActiveTest(),
            if (_testCompleted) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pets, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Animal Fluency Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This test measures verbal fluency and executive function.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('1. You will have 60 seconds'),
                const Text('2. Name as many animals as you can'),
                const Text('3. Speak naturally - the app listens continuously'),
                const Text('4. Try to avoid repeating animals'),
                const Text('5. Any animal counts (mammals, birds, fish, insects, etc.)'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Think of different categories: pets, farm animals, wild animals, birds, sea creatures, insects, etc.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startTest,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _remainingSeconds <= 10 ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Time Remaining',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$_remainingSeconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'seconds',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Continuous Listening Status
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_speechEnabled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _speechListening ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _speechListening ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _speechListening ? Icons.mic : Icons.mic_off,
                              size: 32,
                              color: _speechListening ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _speechListening ? 'LISTENING CONTINUOUSLY' : 'Starting...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _speechListening ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _speechListening
                            ? 'Speak naturally - name animals as they come to mind'
                            : 'Initializing speech recognition...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_speechListening && _soundLevel > -25) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (_soundLevel + 25) / 15, // Normalize to 0-1 range
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sound detected',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.mic_off, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Voice input not available',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check microphone permissions in Settings',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Words entered so far
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animals Named (${_enteredWords.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_enteredWords.isEmpty)
                  const Text(
                    'No animals entered yet',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _enteredWords.map((word) => Chip(
                      label: Text(word),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _completeTest,
            icon: const Icon(Icons.stop),
            label: const Text('End Test Early'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: _getPerformanceColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Test Complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor().withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Score',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_score',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(),
                        ),
                      ),
                      Text(
                        'valid animals',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPerformanceLevel(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valid Animals (${_validWords.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _validWords.map((word) => Chip(
                    label: Text(word),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  )).toList(),
                ),
                
                if (_enteredWords.length > _validWords.length) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Invalid/Repeated (${_enteredWords.length - _validWords.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _enteredWords
                        .where((word) => !_validWords.contains(word))
                        .map((word) => Chip(
                          label: Text(word),
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score Interpretation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildScoreRange('18+', 'Excellent', Colors.green),
                _buildScoreRange('14-17', 'Good', Colors.lightGreen),
                _buildScoreRange('10-13', 'Average', Colors.orange),
                _buildScoreRange('7-9', 'Below Average', Colors.deepOrange),
                _buildScoreRange('0-6', 'Poor', Colors.red),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Tests'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Reset and restart test
                  setState(() {
                    _testStarted = false;
                    _testCompleted = false;
                    _enteredWords.clear();
                    _validWords.clear();
                    _score = 0;
                    _remainingSeconds = 60;
                  });
                  _textController.clear();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRange(String range, String level, Color color) {
    final isCurrentLevel = level == _getPerformanceLevel();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: isCurrentLevel ? BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ) : null,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              range,
              style: TextStyle(
                fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                color: isCurrentLevel ? color : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            level,
            style: TextStyle(
              fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLevel ? color : null,
            ),
          ),
          if (isCurrentLevel) ...[
            const Spacer(),
            Icon(Icons.arrow_left, color: color),
          ],
        ],
      ),
    );
  }
}