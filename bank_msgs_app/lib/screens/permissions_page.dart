import 'package:bank_msgs_app/screens/home_page/home_page.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/material.dart';

class PermissionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PermissionPageState();
}

enum GrantStatus { NOT_CHECKED, NOT_GRANTED, GRANTED }

class PermissionPageState extends State<PermissionPage> {
  RaisedButton permButton;
  Text permStatusText;
  Color statusColor = Colors.white;
  GrantStatus _grantStatus = GrantStatus.NOT_CHECKED;

  @override
  void initState() {
    super.initState();

    RaisedButton requestButton = RaisedButton(
      child: Text("Allow"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textColor: Colors.white,
      color: Colors.redAccent,
      onPressed: () {
        requestPermission();
      },
    );

    Text requestText =
        Text("Please Allow SMS Permission", style: TextStyle(fontSize: 18));


    Future<bool> permStatus = getPermissionStatus();
    permStatus.then((res) {
      setState(() {
        if (res) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              ModalRoute.withName("/Home"));
        } else {
          _grantStatus = GrantStatus.NOT_GRANTED;
          permButton = requestButton;
          permStatusText = requestText;
          statusColor = Colors.orange;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("hell in build");

    RaisedButton nextButton = RaisedButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName("/Home"));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Text("Next"),
      textColor: Colors.white,
      color: Colors.blue,
    );

    Text nextScreenText = Text(
      "Awesome! Now continue",
      style: TextStyle(fontSize: 18),
    );

    if (_grantStatus == GrantStatus.NOT_CHECKED) {
      permButton = RaisedButton(
        onPressed: () {},
        color: Colors.white,
        elevation: 0,
      );
      permStatusText = Text("");
    } else if (_grantStatus == GrantStatus.GRANTED) {
      permButton = nextButton;
      permStatusText = nextScreenText;
      statusColor = Colors.blue;
    }

    AssetImage image = AssetImage('assets/images/money.png');

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.center,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration:
                        BoxDecoration(image: DecorationImage(image: image)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      permStatusText,
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: permButton,
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: statusColor,
                          width: 2,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> getPermissionStatus() async {
    return SimplePermissions.checkPermission(Permission.ReadSms);
  }

  requestPermission() async {
    PermissionStatus res =
        await SimplePermissions.requestPermission(Permission.ReadSms);

    if (res == PermissionStatus.authorized) {
      setState(() {
        debugPrint("hell in stting state");
        _grantStatus = GrantStatus.GRANTED;
      });
    }
  }
}