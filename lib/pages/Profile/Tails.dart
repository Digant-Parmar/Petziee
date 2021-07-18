// @dart=2.9
import 'package:flutter/material.dart';

import 'RequestPawsList.dart';
import 'TailsList.dart';


class TailsPage extends StatefulWidget {
  const TailsPage({Key key}) : super(key: key);
  @override
  _TailsPageState createState() => _TailsPageState();
}

class _TailsPageState extends State<TailsPage> {

  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: key,
        appBar: AppBar(
          title: Text("Paws"),
          bottom: TabBar(
            tabs: [
              Text(
                "Tails",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Requests",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    elevation: 10,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.grey[900],
                    context: context,
                    builder: (context) {
                      return ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: Text("Paws"),
                            subtitle: Text(
                                "Paws are the one who has allowed you to access their location"),
                          ),
                          Divider(),
                          ListTile(
                            title: Text("Tails"),
                            subtitle: Text(
                                "Tails are the one whom you have given access to your location"),
                          ),
                        ],
                      );
                    },
                  );
                }),
          ],
        ),
        body: TabBarView(
          children: [
            TailsList(),
            RequestPawsList(),
          ],
        ),
      ),
    );
  }

}

