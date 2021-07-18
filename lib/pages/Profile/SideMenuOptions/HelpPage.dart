import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  buttonPressed()async{
    const url = "https://petziee-88ce0.web.app/contact.html";
    if (await canLaunch(url))
    await launch(url);
    else
    // can't launch url, there is some error
    throw "Could not launch $url";
  }

  reportDialog(mContext){
    return showDialog(
      context: mContext,
      builder: (context){
        return SimpleDialog(
          title: Text(
            "Report",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Report Spam",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: (){buttonPressed();},
            ),
            SimpleDialogOption(
              child: Text(
                "Send Feedback",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: (){buttonPressed();},
            ),
            SimpleDialogOption(
              child: Text(
                "Report a Problem",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: (){buttonPressed();},
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Help",
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Report a problem",
            ),
            onTap:()=>reportDialog(context),
          ),
          ListTile(
            title: Text(
              "Help Center",
            ),
            onTap: (){
              buttonPressed();
            },
          ),
        ],
      ),
    );
  }
}
