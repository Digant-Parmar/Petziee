import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "About",
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Data Policy",
            ),
              onTap: ()=>sendToWeb()
          ),
          ListTile(
            title: Text(
              "Terms of Use",
            ),
            onTap: ()=>sendToWeb(),
          )
        ],
      ),
    );
  }

  sendToWeb()async{
    const url = "https://petziee-88ce0.web.app/about.html";
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }
}
