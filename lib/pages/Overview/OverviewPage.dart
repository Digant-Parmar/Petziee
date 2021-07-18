// @dart=2.9
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petziee/colors/Themes.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:provider/provider.dart';

import 'Schedule/TimeScheduler.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<Widget> _images = [
    // "assets/other.jpg",
    // "assets/other.jpg",
    // "assets/other.jpg",
    // "assets/petTime.jpg",
    // "assets/other.jpg",
    ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        key: ValueKey(true),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xFF2D2F41),
        ),
        child: Center(
          child: Image.asset(
            "assets/timeScheduler.jpg",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    TimeScheduler(),
    ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        key: ValueKey(true),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xFF2D2F41),
        ),
        child: Center(
          child: Image.asset(
            "assets/timeScheduler.jpg",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        key: ValueKey(true),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xFF2D2F41),
        ),
        child: Center(
          child: Image.asset(
            "assets/timeScheduler.jpg",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),

    ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        key: ValueKey(true),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xFF2D2F41),
        ),
        child: Center(
          child: Image.asset(
            "assets/timeScheduler.jpg",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    Container(
      color: Colors.grey,
    ),
  ];

  String blog =
      "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, , comes from a line in section 1.10.32.The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.";
  String heading = "This is my first blog";
  String title = "Where does it come from?";
  String username = "Digant";
  String profileImage =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyraF9JU_344Gnoto9FVOlma8A4rsNNJPLrQ&usqp=CAU";

  String time = DateTime.now().toString();
  int stars = 10;

  String _themeType;

  _getThemeType() async {
    _themeType = await PhoneDatabase.getAppTheme();
  }

  @override
  initState() {
    _getThemeType();
    super.initState();
  }

  Future<List<String>> getTopInfoImageLinks() async {
    List<String> links = [];
    await FirebaseFirestore.instance
        .collection("Overview")
        .doc("TopInfoImage")
        .collection("images")
        .orderBy("number", descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        links.add(element.get("link"));
      });
    });
    print(links.length);
    return links;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 55),
          children: [
            //TOP APP BAR
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "Petziee",
                        style: GoogleFonts.bitter(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).accentColor,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(3.0, 3.0),
                          color: Theme.of(context).shadowColor,
                          blurRadius: 2.0,
                          spreadRadius: 0.1,
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.only(left: 6, right: 2, top: 2, bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "DIGANT",
                          style: TextStyle(),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyraF9JU_344Gnoto9FVOlma8A4rsNNJPLrQ&usqp=CAU"),
                          radius: 17,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9,
              // child: Container(
              //   color: Colors.white,
              // ),
            ),
            //FEATURED
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3.5,
                child: FutureBuilder(
                  future: getTopInfoImageLinks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(3.0, 3.0),
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.1,
                                    ),
                                  ],
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data[index],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data.length,
                      );
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyraF9JU_344Gnoto9FVOlma8A4rsNNJPLrQ&usqp=CAU",
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyraF9JU_344Gnoto9FVOlma8A4rsNNJPLrQ&usqp=CAU",
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 9,
              child: Container(
                color: Theme.of(context).shadowColor,
              ),
            ),
            //MENU
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 16,
                  crossAxisCount: 2,
                  childAspectRatio: 1.1),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                // return ClipRRect(
                //   borderRadius: BorderRadius.all(Radius.circular(15)),
                //   child:_images[index]
                // );
                return _images[index];
              },
            ),
            SizedBox(
              height: 8,
              child: Container(
                color: Theme.of(context).shadowColor,
              ),
            ),
            //BLOG
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: Container(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        child: Image.asset(
                          _themeType == "blackTheme"
                              ? "assets/backDark.png"
                              : "assets/back.png",
                          // colorBlendMode: BlendMode.colorBurn,
                          // color: Colors.grey,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(right: 18, left: 18, top: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: CachedNetworkImageProvider(
                                        profileImage),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    username,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 16,
                                        right: 16,
                                        left: 16,
                                        bottom: 2),
                                    child: Text(
                                      heading,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                        top: 10),
                                    child: Text(
                                      blog,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                        wordSpacing: 2,
                                      ),
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "Read More",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFFFADAD).withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Divider(),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Explore All",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Icon(
                                Icons.arrow_forward,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
