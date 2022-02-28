import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class NetworkErrorScreen extends StatefulWidget {
  const NetworkErrorScreen(
      {Key? key, this.message = 'Please Make Sure you are Connected to Wifi'})
      : super(key: key);
  final String message;

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar:
          StyledAppBar.transparent(foregroundColor: appTheme.onBackgroundColor),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator.adaptive()
            : Padding(
                padding: const EdgeInsets.all(Spacers.kPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 200),
                    Spacers.mediumSpacerVr(),
                    Text(
                      widget.message,
                      style: textTheme.headlineSmall,
                    ),
                    Spacers.mediumSpacerVr(),
                    SizedBox(
                      width: 200,
                      child: StyledElevatedButton.secondary(
                        context,
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (await WifiNetworkDevices.canCreateRoom) {
                            RootNavigator.pop();
                          }

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        text: 'Retry',
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
