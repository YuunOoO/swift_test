import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swift_test/scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        disabledColor: Colors.green,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const batteryChanel = MethodChannel('com.exampleDL.swiftTest/battery');
  static const advertiseChanel =
      MethodChannel('com.exampleDL.swiftTest/advertise');

  TextEditingController controller = TextEditingController();

  String batteryLevel = "Waitinig ..";
  String status = "unknown";
  String status2 = "idk";
  List<String> logs = ["logi"];
  void onListenStatus() {
    batteryChanel.setMethodCallHandler((call) async {
      if (call.method == "getStatus") {
        final String newStatus = call.arguments;
        setState(() {
          status2 = newStatus;
        });
      }
      if (call.method == "logs") {
        print("logi");
        setState(() {
          logs.add(call.arguments);
          print(call.arguments);
        });
      }
    });
  }

  @override
  void initState() {
    onListenStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.width * .15),
              Center(
                  child: Text(
                "Status: $status",
                style: const TextStyle(fontSize: 24),
              )),
              Center(
                child: Text(
                  batteryLevel,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: getBatteryLevel,
                child: const Text("Get battery level"),
              ),
              GestureDetector(
                onTap: initAdvertise,
                child: Container(
                  height: MediaQuery.of(context).size.height * .15,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.green,
                  child: const Center(
                    child: Text("Advertise"),
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  height: MediaQuery.of(context).size.height * .15,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue,
                  child: const Center(
                    child: Text("Go to scan"),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scan()),
                  );
                },
              ),
              Center(
                  child: Text(
                "Status: $status2",
                style: const TextStyle(fontSize: 24),
              )),
              SizedBox(height: MediaQuery.of(context).size.width * .05),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * .05),
              ElevatedButton(
                onPressed: sendMessage,
                child: const Text("Send message"),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * .05),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                    itemCount: logs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Text(
                          logs[index],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.orange),
                        ),
                      );
                    }),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .1),
            ],
          ),
        ),
      ),
    );
  }

  Future initAdvertise() async {
    String newStatus = await batteryChanel.invokeMethod('advertise');
    setState(() {
      status = newStatus;
    });
  }

  Future sendMessage() async {
    final message = {'message': '${controller.text}'};
    String what = await batteryChanel.invokeMethod('send', message);
  }

  Future getBatteryLevel() async {
    final String newBateryLevel =
        await batteryChanel.invokeMethod('getBatteryLevel');

    setState(() {
      batteryLevel = '$newBateryLevel %';
    });
  }
}
