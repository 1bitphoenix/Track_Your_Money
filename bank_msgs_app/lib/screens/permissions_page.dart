import 'package:bank_msgs_app/screens/home_page/home_page.dart';
import 'package:permission/permission.dart';
import 'package:flutter/material.dart';

class PermissionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => PermissionPageState();
}

class PermissionPageState extends State<PermissionPage>{

  bool _permissionGranted = false;

  @override
  Widget build(BuildContext context){
    requestPermission();
    return MaterialApp(
      home: Scaffold(
        body: _getWidget(),
      ),
    );

  }

  Widget _getWidget(){
    if (_permissionGranted) {
      return Container(
        
      );
    }
    else {
      Future<Widget> hello = Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()) 
      );
      hello.then((widget){
        return widget;
      });
    }
    return Container();
  }

  getPermissionStatus(){
    Future<List<Permissions>> permissionsFuture = Permission.getPermissionStatus([PermissionName.SMS]);
    permissionsFuture.then((permissions){
      if(permissions.first.permissionStatus == PermissionStatus.allow){
        _permissionGranted = true;
      }
    });
  }

  requestPermission() async {
    final res = await Permission.requestSinglePermission(PermissionName.Calendar);
    print(res);
  }
}