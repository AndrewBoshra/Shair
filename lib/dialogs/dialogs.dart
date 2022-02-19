import 'package:flutter/material.dart';

import 'package:shair/actions/actions.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/config.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/core/extensions.dart';

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

class JoinRequestDialog extends StatelessWidget {
  const JoinRequestDialog({
    Key? key,
    required this.request,
  }) : super(key: key);
  final JoinRequest request;
  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final textTheme =
        Theme.of(context).textTheme.colorize(appTheme.onPrimaryColor);

    final person = request.personDetails;
    return Dialog(
      backgroundColor: appTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(Spacers.kPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: [
                RoomAvatar(imageUrl: person.character),
                Text(
                  '${person.name?.capitalize()} wants to join ${request.room.name}',
                  style: textTheme.subtitle1,
                ),
              ],
            ),
            Spacers.smallSpacerVr(),
            Text(request.code, style: textTheme.headlineMedium),
            Spacers.smallSpacerVr(),
            Text(
              'Let him/her in?',
              style: textTheme.subtitle1,
            ),
            Spacers.smallSpacerVr(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledElevatedButton.error(context, onPressed: () {
                  Navigator.of(context).pop(false);
                }, text: 'Reject'),
                Spacers.mediumSpacerHz(),
                StyledElevatedButton.onPrimary(context, onPressed: () {
                  Navigator.of(context).pop(true);
                }, text: 'Accept'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
