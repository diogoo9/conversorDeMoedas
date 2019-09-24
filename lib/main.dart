import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=f4e01421";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber)))),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _clearFiels(){
    realController.clear();
    dollarController.clear();
    euroController.clear();
  }

  //recebendo o real
  void _realChanged(String text){
    if(text.isEmpty){
      _clearFiels();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  //recebendo o dollar
  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearFiels();
       return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dollar).toStringAsFixed(2);
    euroController.text = (dolar * this.dollar / euro).toStringAsFixed(2);
  }
  //recebendo o euro
  void _euroChanged(String text){
    if(text.isEmpty){
      _clearFiels();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro/ dollar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),

        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "carregando...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  );

                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "erro ... :( $snapshot.error",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  } else {
                    dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150, color: Colors.amber),
                          buildTextField("Real", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dolar", "U\$", dollarController, _dolarChanged),
                          Divider(),
                          buildTextField("Euro", "E", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function change) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25
    ),
    controller: controller,
    onChanged: change,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
