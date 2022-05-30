import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SplashScreen(
      seconds: 5,
      title: const Text('Color Guesser',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
      navigateAfterSeconds: MyHomePage(
        title: "Color Guesser",
      ),
      image: Image.network(
          'https://tech-espm.github.io/garby/logo-techPNG.png?raw=true'),
      photoSize: 100,
      backgroundColor: Colors.white24,
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ColorResponse{
  int a, r, g, b;
  int correctAnswer;
  List<String> options;

  ColorResponse(this.r, this.a, this.b, this.g, this.correctAnswer, this.options);
}

class _MyHomePageState extends State<MyHomePage> {
  int selectOption = 0;
  ColorResponse colorResponse = ColorResponse(0, 0, 0, 0, 0, const []);

  final urlBase =
      'https://7c2bad50.us-south.apigw.appdomain.cloud/api/guessColors';

  Widget listOptions() {
    return Column(children: List<Widget>.from(colorResponse.options.map((option) {
      int index = colorResponse.options.indexOf(option);
      return ListTile(
        title: Text(option),
        leading: Radio<int>(
            value: index,
            groupValue: selectOption,
            onChanged: (int? value) {
              setState(() {
                selectOption = value!;
              });
            }),
      );
    })));
  }

  @override
  void initState() {
    http.get(Uri.parse(urlBase)).then((res) {
      final decodeResponse = jsonDecode(res.body);

      setState(() {
        colorResponse.a = decodeResponse['a'];
        colorResponse.r = decodeResponse['r'];
        colorResponse.g = decodeResponse['g'];
        colorResponse.b = decodeResponse['b'];
        colorResponse.correctAnswer = decodeResponse['correto'];
        colorResponse.options = List<String>.from(decodeResponse['opcoes']);
      });

    });
  }


void checkCorrectAnswer() {
    String result = selectOption == colorResponse.correctAnswer ? "Correct" : "Incorrect";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your choice is...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(result)],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Restart'),
                onPressed: () {
                  Navigator.of(context).pop();
                  initState();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Guess the color :"),
        centerTitle: true,
      ),
      body: // statefull component
      Column(children: <Widget>[
        Container(
          height: 150, 
          color: 
            Color.fromARGB(colorResponse.a, colorResponse.r, colorResponse.g, colorResponse.b)
        ),
        Expanded(
          child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Center(
                child: Text("Guess the color :"),
              ),
              listOptions(),
              Center(
                child: ElevatedButton(
                  child: Text("Confirm"),
                  onPressed: checkCorrectAnswer,
                ),
              )
            ]
          ),
        ))
      ]),
    )
    );
  }
}
