import 'package:flutter/material.dart';
import 'package:zoomable_image/zoomable_image.dart';

void main() {
  runApp(
    new MaterialApp(
      home: PngHome()
    ),
  );
}

class PngHome extends StatefulWidget {
  PngHome({Key key}) : super(key: key);

  @override
  _PngHomeState createState() => _PngHomeState();
}

class _PngHomeState extends State<PngHome> {
  int height = 0;
  @override
  Widget build(BuildContext context) {
   return new Scaffold(
        body: Stack(children: <Widget>[
          new ZoomableImage(
            new AssetImage('images/img_camera_bg@2x.png'),
            placeholder: const Center(child: const CircularProgressIndicator()),
            backgroundColor: Colors.red,
            isUpdate: height,
          ),
          FlatButton(onPressed: (){
            setState(() {
              height += 1;
            });
          }, child: Text('11111'),color: Colors.black26,)
        ],)
    );
  }
}