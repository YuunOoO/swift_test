import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});
  @override
  State<Scan> createState() => _Scan();
}

class _Scan extends State<Scan> {
  static const scanChanel = MethodChannel('com.exampleDL.swiftTest/scan');
  TextEditingController controller = TextEditingController();
  String status = "unknown";
  List<String> logs = ["logi"];

  @override
  void initState() {
    bleinit();
    onListenStatus();
    super.initState();
  }

  onListenStatus() {
    scanChanel.setMethodCallHandler((call) async {
      if (call.method == "getStatus") {
        final String newStatus = call.arguments;
        setState(() {
          status = newStatus;
        });
      }
      if (call.method == "logs") {
        setState(() {
          logs.add(call.arguments);
        });
      }
    });
  }

  bleinit() {
    scanChanel.invokeMethod("init");
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
                onTap: initScan,
                child: Container(
                  height: MediaQuery.of(context).size.height * .15,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.green,
                  child: const Center(
                    child: Text("Start scan"),
                  ),
                ),
              ),
              GestureDetector(
                onTap: stopScan,
                child: Container(
                  height: MediaQuery.of(context).size.height * .07,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.red,
                  child: const Center(
                    child: Text("Stop scan"),
                  ),
                ),
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
              SizedBox(height: MediaQuery.of(context).size.width * .05),
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

  Future initScan() async {
    await scanChanel.invokeMethod('scan');
    setState(() {});
  }

  Future stopScan() async {
    await scanChanel.invokeMethod('stopScan');
  }

  Future sendMessage() async {
    final message = {'message': controller.text};
    await scanChanel.invokeMethod('sendMessage', message);
  }
}
