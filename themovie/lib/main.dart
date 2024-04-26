import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:themovie/repositories/movie_repository_impl.dart';
import 'package:themovie/services/http_manage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => Dio()),
      Provider(create: (context) => HttpManager(dio: context.read())),
      Provider(
          create: (context) => MovieRepositoryImpl(httpManager: context.read()))
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _fetchMovieData() async {
    try {
      String apiKey = dotenv.env['API_KEY']!;
      String apiToken = dotenv.env['API_TOKEN']!;
      String apiUrl = 'https://api.themoviedb.org/3/movie/550?api_key=$apiKey';
      
      Dio dio = context.read<Dio>();
      Response response = await dio.get(apiUrl, options: Options(headers: {
        'Authorization': 'Bearer $apiToken',
      }));

      // Handle response data here
      print(response.data);
    } catch (error) {
      // Handle error here
      print('Error fetching movie data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
          });
          // Call the API when floating action button is pressed
          _fetchMovieData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
