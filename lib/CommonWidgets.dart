import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonWidgets {

  launchPage(BuildContext context, Widget builder)  {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => builder));
  }

  Widget setText(String text, double fontSize) {
    return Text(text,style: TextStyle(color: Colors.white,fontSize: fontSize),);
  }

  Widget setTextWithColor(String text, double fontSize, Color color) {
    return Text(text,style: TextStyle(color: color,fontSize: fontSize));
  }


  Widget setTextWithColorFOntWeight(String text, double fontSize, Color color) {
    return Text(text,style: TextStyle(color: color,fontSize: fontSize, fontWeight: FontWeight.bold));
  }

  Widget iconContainer(IconData iconData,Color color,double iconSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(iconData,color: color,size: iconSize),
    );
  }

  String setTime(Duration duration){
    String seconds = (duration.inSeconds % 60).toString().padLeft(2,"0");
    String minutes = (duration.inMinutes % 60).toString().padLeft(2,"0");
    return minutes + " : "+seconds;
  }

  void setBoolean(String key, bool value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> getBoolean(String key) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }
}