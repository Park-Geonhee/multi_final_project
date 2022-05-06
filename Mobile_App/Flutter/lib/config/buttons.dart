import 'package:flutter/material.dart';

class MyElevatedButton1 extends StatelessWidget {
  String text;

  MyElevatedButton1(this.text);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        this.text,
        style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
          primary: Colors.cyan[900], minimumSize: Size(70, 50)),
      onPressed: () {
      },
    );
  }
}

class MyElevatedButton2 extends StatelessWidget {
  String text;
  Widget destination;

  MyElevatedButton2(this.text, this.destination);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
          child: Text(
            this.text,
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.cyan[900],
              minimumSize: Size(180, 50)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return destination;
              },
            ));
          }),
    );
  }
}