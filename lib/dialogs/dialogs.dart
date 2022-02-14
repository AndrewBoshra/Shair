import 'package:flutter/material.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/styled_components/spacers.dart';

class JoinCodeDialog extends StatelessWidget {
  const JoinCodeDialog({Key? key, required this.code}) : super(key: key);
  final String code;

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final textTheme =
        Theme.of(context).textTheme.colorize(appTheme.onPrimaryColor);
    return Dialog(
      backgroundColor: appTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(Spacers.kPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Code is',
              style: textTheme.subtitle1,
            ),
            Spacers.smallSpacerVr(),
            Text(
              code,
              style: textTheme.headlineMedium,
            ),
            Spacers.smallSpacerVr(),
            Text(
              'Please ask room host to let you in',
              style: textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
