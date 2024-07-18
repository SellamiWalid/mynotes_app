import 'package:flutter/widgets.dart';

extension DoubleOperations on double {

  Widget get vrSpace => SizedBox(height: this,);
  Widget get hrSpace => SizedBox(width: this,);

}