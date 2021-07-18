import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Security"
        ),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Password",
            ),
          ),
        ],
      ),
    );
  }
}
