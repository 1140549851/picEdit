import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'dart:typed_data';
import 'PhotoListPage.dart';
import 'albumListPage.dart';
class AlbumPage extends StatefulWidget {
  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  var height = ScreenUtil.screenHeight;
  var width = ScreenUtil.screenWidth;
  bool showPhotoList = false;
  final ScrollController _scrollController = ScrollController();
  AssetPathEntity selectEntity;
  Duration _kScrollDuration = Duration(milliseconds: 300);
  Widget buldAlbum;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buldAlbum = AlbumListPage(callback: (val) => onDataChange(val));
    setState(() {});
  }
  static  getPhotosData(AssetPathEntity entity) async {
    return await entity.assetList;
  }
  void onDataChange(val) {
    showPhotoList = true;
    selectEntity = val;
    setState(() {});
    _scrollController.animateTo(ScreenUtil.screenWidth,
        curve: Curves.fastOutSlowIn,
        duration: _kScrollDuration);
  }
  void onPhotoDataChange(val) {
    Navigator.pop(context,val);
  }
  @override
  Widget build(BuildContext context) {
    print(selectEntity);
    return Scaffold(
      body:Stack(children: <Widget>[
        Container(width: width,height: height,
          child:buldAlbum,
        ),
         new SingleChildScrollView(
          scrollDirection : Axis.horizontal,
          child: new Container(
            width: showPhotoList?width * 2:0,
            height: height,
            child: Padding(padding:EdgeInsets.only(left:width) ,
              child: selectEntity != null ?new Container(
                  width: width,
                  height: height,
                  child: PhotoListPage(
                    pathEntity: selectEntity,
                    onPressed: (){
                      _scrollController.animateTo(0,
                          curve: Curves.fastOutSlowIn,
                          duration: _kScrollDuration).then((v){
                        showPhotoList = false;
                        setState(() {});
                      });
                    },
                    callback: (val) => onPhotoDataChange(val),
                  )

              ):Container(),
            )
          ),
          controller: _scrollController,
          physics: new NeverScrollableScrollPhysics(),
        ),

      ],)


    );
  }
}
