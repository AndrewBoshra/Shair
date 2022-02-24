import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/commands/create_room.dart';
import 'package:shair/utils/validators.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/assets.dart';
import 'package:shair/data/config.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/widgets/rounded_button.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  String? _roomImage;
  late TextEditingController _nameEditController;
  bool _isLocked = true;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    Config config = context.read();
    _nameEditController = TextEditingController.fromValue(
        TextEditingValue(text: '${config.name}\'s room'));
    super.initState();
  }

  void _createRoom() async {
    if (_formKey.currentState?.validate() == true) {
      final room = CreateRoomCommand(
        _nameEditController.value.text,
        _roomImage,
        _isLocked,
      ).execute();
      RootNavigator.toRoomScreen(room, pop: true);
    }
  }

  void _changeImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        _roomImage = result.paths[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar:
          StyledAppBar.transparent(foregroundColor: appTheme.onBackgroundColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacers.kPadding),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacers.largeSpacerVr(),
              SizedBox.square(
                dimension: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: _changeImage,
                      child: CircleAvatar(
                        foregroundImage: _roomImage == null
                            ? const AssetImage(ImageAssets.logo)
                            : FileImage(File(_roomImage!)) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: RoundedButton(
                        onPressed: _changeImage,
                        child: const Icon(Icons.camera_alt_outlined),
                      ),
                    )
                  ],
                ),
              ),
              Spacers.smallSpacerVr(),
              TextFormField(
                validator: const EmptyStringValidator('Name').validate,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: textTheme.headlineSmall,
                autofocus: true,
                controller: _nameEditController,
              ),
              Spacers.mediumSpacerVr(),
              Expanded(
                child: ListView(
                  children: [
                    SwitchListTile(
                      value: !_isLocked,
                      title: const Text('Anyone can join this room ?'),
                      onChanged: (unlocked) => setState(
                        () {
                          _isLocked = !unlocked;
                        },
                      ),
                    )
                  ],
                ),
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints.tightFor(width: double.infinity),
                child: StyledElevatedButton.secondary(
                  context,
                  onPressed: _createRoom,
                  text: 'CREATE ROOM',
                ),
              ),
              Spacers.mediumSpacerVr(),
            ],
          ),
        ),
      ),
    );
  }
}
