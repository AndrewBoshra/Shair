import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/config.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _btnAnimation;
  @override
  void initState() {
    final devices = context.read<WifiNetworkDevices>();
    devices.canCreateRoom.then((value) => setState(() {
          if (!value) _animationController.reverse();
        }));

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000), value: 1);
    _btnAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Config config = Provider.of(context);
    final textTheme = Theme.of(context).textTheme;
    final appTheme = AppTheme.of(context);
    final appModel = AppModel.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildHomeScreen(context, config, appTheme, textTheme),
          if (appModel.accessibleRooms.isNotEmpty)
            _buildOpenedRooms(appModel, appTheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildOpenedRooms(
    AppModel appModel,
    AppTheme appTheme,
    TextTheme textTheme,
  ) {
    textTheme = textTheme.apply(bodyColor: appTheme.onSecondaryColor);
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            color: appTheme.secondaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacers.kPadding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 5,
                      child: ColoredBox(color: appTheme.onSecondaryColor),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (appModel.myRooms.isNotEmpty) ...[
                        Spacers.smallSpacerVr(),
                        Text(
                          'Your Rooms',
                          style: textTheme.subtitle1,
                        ),
                        Spacers.smallSpacerVr(),
                        ...appModel.myRooms
                            .map((r) => _buildRoomTile(r, appTheme)),
                        Spacers.smallSpacerVr(),
                        Divider(color: appTheme.onSecondaryColor),
                      ],
                      if (appModel.joinedRooms.isNotEmpty) ...[
                        Spacers.smallSpacerVr(),
                        Text(
                          'Joined Rooms',
                          style: textTheme.subtitle1,
                        ),
                        Spacers.smallSpacerVr(),
                        ...appModel.joinedRooms
                            .map((r) => _buildRoomTile(r, appTheme)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile _buildRoomTile(Room room, AppTheme appTheme) {
    return ListTile(
      onTap: () => RootNavigator.toRoomScreen(room),
      leading: RoomAvatar(
        characterImage: room.roomImage,
      ),
      title: Text(
        room.name,
        style: TextStyle(
          color: appTheme.onSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context, Config config,
      AppTheme appTheme, TextTheme textTheme) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildUserWidget(appTheme, config, textTheme),
        ),
        Expanded(
          child: _buildActions(context),
        )
      ],
    );
  }

  DecoratedBox _buildUserWidget(
      AppTheme appTheme, Config config, TextTheme textTheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appTheme.secondaryVarColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.elliptical(500, 100),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(
                child: CharacterAvatar(characterImage: config.character!),
              ),
              SelectableText(
                config.name!,
                style: textTheme.headlineSmall
                    ?.copyWith(color: appTheme.onSecondaryColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return AnimatedBuilder(
      animation: _btnAnimation,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 50),
          if (!_animationController.isDismissed) ...[
            Expanded(
              flex: (100 * _btnAnimation.value).toInt(),
              child: StyledElevatedButton.secondary(
                context,
                onPressed: RootNavigator.toJoinRoomScreen,
                text: 'Join',
                maxLines: 1,
              ),
            ),
            Spacers.mediumSpacerHz(),
          ],
          Expanded(
            flex: 100,
            child: StyledElevatedButton.secondary(
              context,
              onPressed: RootNavigator.toCreateRoomScreen,
              text: 'New Room',
            ),
          ),
          const Spacer(flex: 50),
        ],
      ),
    );
  }
}
