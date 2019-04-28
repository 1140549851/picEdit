import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
class PngHome extends StatefulWidget {
  PngHome({Key key}) : super(key: key);

  @override
  _PngHomeState createState() => _PngHomeState();
}

class _PngHomeState extends State<PngHome> {
  GlobalKey globalKey = GlobalKey();
  Uint8List _pngBytes;
  Future<void> _capturePng() async {
    ui.Image image;
    bool catched = false;
    RenderRepaintBoundary boundary =
    globalKey.currentContext.findRenderObject();
    try {
      image = await boundary.toImage();
      catched = true;
    } catch (exception) {
      catched = false;
      Timer(Duration(milliseconds: 1), () {
        _capturePng();
      });
    }
    if (catched) {
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      _pngBytes = pngBytes;

      var filePath = await ImagePickerSaver.saveFile(
          fileData: pngBytes);

      var savedFile= File.fromUri(Uri.file(filePath));
      print(savedFile);
      setState(() {

      });
      print(pngBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(color:_pngBytes!=null?Colors.red: Colors.white,
        child: Center(
          child: _pngBytes!=null ? Container(width: 200,height: 200,child: Image.memory(_pngBytes),):FlatButton(
            child: Text('Hello World', textDirection: TextDirection.ltr),
            onPressed: _capturePng,
          ),
        ),
      )
    );
  }
}