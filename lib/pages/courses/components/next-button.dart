import 'package:flutter/material.dart';
import 'package:flutter_app_stulish/helpers/sizes_helpers.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      width: displayWidth(context) * 0.15,
      image: AssetImage("assets/images/next-icon.png"),
    );
  }
}
