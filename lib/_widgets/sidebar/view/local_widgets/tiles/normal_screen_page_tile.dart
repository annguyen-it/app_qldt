import 'package:flutter/material.dart';

import 'package:app_qldt/_models/screen.dart';

import 'other_screen_page_tile.dart';

class NormalScreenPageTile extends OtherScreenPageTile {
  NormalScreenPageTile(
    BuildContext context, {
    Key? key,
    required ScreenPage screenPage,
  }) : super(
          context,
          key: key,
          screenPage: screenPage,
        );
}
