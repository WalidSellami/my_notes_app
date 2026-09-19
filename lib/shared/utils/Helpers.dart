import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notes/shared/utils/Constants.dart';

String getGreeting(BuildContext context) {
  var now = DateTime.now();
  var hour = now.hour;

  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 18) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

TextDirection getTextDirection(String text) {
  // Check if the text contains any Arabic characters
  return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
}


void scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
  }
}


Future<void> saveImage(GlobalKey globalKey, BuildContext context) async {
  final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  await Future.delayed(const Duration(milliseconds: 300)).then((value) async {
    RenderRepaintBoundary boundary =
    globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    ui.Image? image = await boundary.toImage(pixelRatio: devicePixelRatio);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List? imageBytes = byteData?.buffer.asUint8List();

    await ImageGallerySaver.saveImage(imageBytes!);
  });
}