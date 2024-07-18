import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/shared/styles/Colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String os;
  const LoadingIndicator({super.key, required this.os});

  @override
  Widget build(BuildContext context) {
     if(os == 'android') {
       return CircularProgressIndicator(
         color: lightPrimaryColor,
         strokeCap: StrokeCap.round,
       );
     } else {
       return CupertinoActivityIndicator(
         color: lightPrimaryColor,
       );
     }
  }
}
