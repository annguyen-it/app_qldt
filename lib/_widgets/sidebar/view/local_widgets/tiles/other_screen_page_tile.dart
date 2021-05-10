import 'package:app_qldt/_models/screen.dart';
import 'package:flutter/material.dart';

import 'screen_page_tile.dart';

class OtherScreenPageTile extends ScreenPageTile {
  OtherScreenPageTile(
    BuildContext context, {
    Key? key,
    CustomPainter? painter,
    required ScreenPage screenPage,
  }) : super(
          key: key,
          screenPage: screenPage,
          painter: painter,
          onTap: () async {
            await Navigator.maybePop(context);
            Navigator.of(context).pushNamedAndRemoveUntil(screenPage.string, (route) => false);
          },
        );
}
