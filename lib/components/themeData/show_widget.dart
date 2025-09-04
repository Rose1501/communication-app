import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowWidget {
  static showMessage(
      BuildContext context, String message, Color color, TextStyle textStyle) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Center(
        child: Text(
          message,
          style: textStyle,
        ),
      ),
      duration: Duration(seconds: 2),
    ));
  }

  /*static showLoading(BuildContext  context){
     showDialog(context: context, builder: (context){
        return Center(child: CupertinoActivityIndicator(radius: 25,),);
      });
  }*/
}
