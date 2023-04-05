import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swift_test/scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        disabledColor: Colors.green,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const advertiseChanel =
      MethodChannel('com.exampleDL.swiftTest/advertise');
  TextEditingController controller = TextEditingController();
  String status = "unknown";
  List<String> logs = ["logs"];

  @override
  void initState() {
    onListenStatus();
    super.initState();
  }

  onListenStatus() {
    advertiseChanel.setMethodCallHandler((call) async {
      if (call.method == "getStatus") {
        final String newStatus = call.arguments;
        setState(() {
          status = newStatus;
        });
      } else if (call.method == "logs") {
        setState(() {
          logs.add(call.arguments);
        });
      }
    });
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
                onTap: stopAdvertising,
                child: Container(
                  height: MediaQuery.of(context).size.height * .07,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.red,
                  child: const Center(
                    child: Text("Stop advertising"),
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
                    MaterialPageRoute(builder: (context) => const Scan()),
                  );
                },
              ),
              Center(
                  child: Text(
                "Status: $status",
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
              SizedBox(height: MediaQuery.of(context).size.width * .02),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                    itemCount: logs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(
                        logs[index],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.orange),
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
    await advertiseChanel.invokeMethod('advertise');
    setState(() {});
  }

  Future stopAdvertising() async {
    await advertiseChanel.invokeMethod('stopAdvertising');
  }

  Future sendMessage() async {
    final message = {'message': controller.text};
    await advertiseChanel.invokeMethod('sendMessage', message);
  }
}
