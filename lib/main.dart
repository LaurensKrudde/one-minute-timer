import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

void main() { 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = TimerPage();
    // switch (selectedIndex) {
    //   case 0:
    //     page = GeneratorPage();
    //   case 1:
    //     page = FavoritesPage();
    //   case 2:
    //     page = TimerPage();
    //   default:
    //     throw UnimplementedError("No widget for index $selectedIndex");
    // }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'One Minute Timer',
      //     style: Theme.of(context).textTheme.titleLarge,
      //   ),
      // ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite),
      //       label: 'Favorites',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.timer_sharp),
      //       label: 'Timer',
      //     ),
      //   ],
      //   currentIndex: selectedIndex,
      //   onTap: (value) {
      //     print('selected: $value');
      //     setState(() {
      //       selectedIndex = value;
      //     });
      //   },
      // ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.star;
    } else {
      icon = Icons.star_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  print('Favorite button pressed!');
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Favorite'),
              ),
              SizedBox(
                width: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  print('Next word button pressed!');
                  appState.getNext();
                },
                child: Text('Next word'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorites yet.',
          style: theme.textTheme.titleLarge,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have ${appState.favorites.length} favorites:',
            style: theme.textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text(
                    pair.asLowerCase,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
            ],
          ),
        ),
      ]
    );
  }
}

class TimerPage extends StatefulWidget {
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {

  Timer? _timer;
  static const int _totalSeconds = 60;
  int _seconds = _totalSeconds;

  final AudioPlayer player = AudioPlayer();

  Timer startTimer() {
    return Timer.periodic(
      Duration(seconds: 1), 
      (timer) {
        if (_seconds == 0) {  
          setState(() {
            player.play(AssetSource('sounds/feels_good.mp3'));
            timer.cancel();
          });
        } else {
          setState(() {
            _seconds--;
          });
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double buttonSize = min(screenWidth, screenHeight) * 0.8;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child:// TweenAnimationBuilder<double>(
              // tween: Tween(begin: 1.0, end: 0.0),
              // duration: Duration(seconds: _totalSeconds),
              // builder: (context, value, child) => 
              CircularProgressIndicator(
                value: _seconds / _totalSeconds,
                strokeWidth: 25,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          //),
          ElevatedButton(
            onPressed: () {
              print('Timer button pressed!');
              setState(() {
                if (_timer != null) {
                _timer!.cancel();
                _timer = null;
                _seconds = _totalSeconds;
                player.stop();
              } else {
                _timer = startTimer();
              }
              });
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              // padding: const EdgeInsets.all(80),
            ),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '$_seconds', 
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 150
                    )
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
