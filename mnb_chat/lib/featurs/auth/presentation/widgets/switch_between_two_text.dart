import '../../../../core/constant.dart';
import '../provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchBetweenTwoText extends StatelessWidget {
  final String firstText;
  final String secondText;
  final TextStyle textStyle;
  const SwitchBetweenTwoText({
    Key? key,
    required this.firstText,
    required this.secondText,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedOpacity(
        duration: Constant.duration,
        opacity: context.watch<AuthProvider>().isSignIn ? 0 : 1,
        child: Text(
          firstText,
          style: textStyle,
        ),
      ),
      AnimatedOpacity(
        duration: Constant.duration,
        opacity: !context.watch<AuthProvider>().isSignIn ? 0 : 1,
        child: Text(
          secondText,
          style: textStyle,
        ),
      ),
    ]);
  }
}
