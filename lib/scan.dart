import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scan extends StatefulWidget {


  @override
  State<Scan> createState() => _Scan();
}

class _Scan extends State<Scan> {
  static const scanChanel = MethodChannel('com.exampleDL.swiftTest/scan');

  TextEditingController controller = TextEditingController();


  String batteryLevel = "Waitinig ..";
  String status ="unknown";
  String status2 = "idk";
  List<String> logs = ["logi"];
  void onListenStatus(){
    scanChanel.setMethodCallHandler((call) async{
      if(call.method == "getStatus"){
        final String newStatus = call.arguments;
        setState(() {
          status2 = newStatus;
        });

      }
      if(call.method == "logs"){
        print("logi");
        setState(() {
          logs.add(call.arguments);
          print(call.arguments);
        });
      }
    });
  }

  bleinit(){
    scanChanel.invokeMethod("init");
  }

  @override
  void initState() {
    bleinit();
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
              SizedBox(height:MediaQuery.of(context).size.width*.15),
              GestureDetector(
                child:Container(
                  height: MediaQuery.of(context).size.height*.15,
                  width: MediaQuery.of(context).size.width,
                  color:Colors.green,
                  child:Center(
                    child:Text("Scan")
                    ,)
                  ,),
                onTap: initScan,),
              Center(
                  child:Text(
                    "Status: $status2"
                    ,style:TextStyle(fontSize:24),
                  )),
              SizedBox(height:MediaQuery.of(context).size.width*.05),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
              ),
              SizedBox(height:MediaQuery.of(context).size.width*.05),
              ElevatedButton(
                child:Text("Send message"),
                onPressed: sendMessage,),
              SizedBox(height:MediaQuery.of(context).size.width*.05),
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                child: ListView.builder(
                    itemCount: logs.length,
                    shrinkWrap: true,
                    itemBuilder: (context,index){

                      return Container(

                        child: Text(
                          logs[index]
                          ,style:TextStyle(fontSize:14,color:Colors.orange),
                        ),
                      );
                    }),
              ),
              SizedBox(height:MediaQuery.of(context).size.height*.1),
            ],
          ),
        ),
      ),
    );
  }

  Future initScan()async{
    String newStatus = await scanChanel.invokeMethod('scan');
    setState(() {
      status = newStatus;
    });
  }

  Future sendMessage()async{
    final message = {'message':'${controller.text}'};
    await  scanChanel.invokeMethod('send',message);
  }


}
