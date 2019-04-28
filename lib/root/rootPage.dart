import 'package:flutter/material.dart';
import 'package:flutter_app_pic/statics/CommonStyle.dart';
import 'package:flutter_app_pic/Widget/CustomButton.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'package:flutter_app_pic/camera/cameraPage.dart';
import 'package:flutter_app_pic/album/albumPage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_app_pic/edit/preViewPage.dart';
class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AssetEntity entity;
  String _imagePath;
  String _videoPath;
  bool showPhoto = false;
  var height = ScreenUtil.screenHeight;
  var width = ScreenUtil.screenWidth;
  final ScrollController _scrollController = ScrollController();
  Duration _kScrollDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      _buildFirstView(),
//      new SingleChildScrollView(
//        scrollDirection : Axis.horizontal,
//        child: new Container(
//            width: showPhoto?width * 2:0,
//            height: height,
//            child: Padding(padding:EdgeInsets.only(left:width) ,
//              child: entity != null || _imagePath !=null || _videoPath!=null?new Container(
//                  width: width,
//                  height: height,
//                  child: PreViewPage(imagePath: _imagePath,videoPath: _videoPath,entity: entity,onPressed: (){
//                    _scrollController.animateTo(0,
//                        curve: Curves.fastOutSlowIn,
//                        duration: _kScrollDuration).then((v){
//                      showPhoto = false;
//                      setState(() {});
//                    });
//                  },),
//
//              ):Container(),
//            )
//        ),
//        controller: _scrollController,
//        physics: new NeverScrollableScrollPhysics(),
//      ),

    ],);

  }

  Widget _buildFirstView(){
    return Container(color: Color(0xFFFFFFE025),
      child:Stack(alignment :AlignmentDirectional.center,children: <Widget>[
        Center(child: new Image.asset(CSImages.img_camera_bg,),),
        Positioned(top: ScreenUtil.setHeight(391),width:ScreenUtil.setWidth(282) ,
          child: Container(
            child: Stack(children: <Widget>[
              Align(alignment: Alignment.centerLeft,
                child: Custombutton().creatHButton(CSImages.btn_camera_camera, 'カメラ',(){
                  _onclicked('camera');
                }),
              ),
              Align(alignment: Alignment.centerRight,
                child: Custombutton().creatHButton(CSImages.btn_camera_album, 'ライブラリから選択',(){
                  _onclicked('album');
                }),
              ),
            ],),
          ),
        )
      ],),
    );
  }
  _onclicked(String sourse) async{
    var result = await PhotoManager.requestPermission();
    var page = sourse.contains('camera') ? CemeraPage():AlbumPage();
    if (result) {
      _imagePath = null;
      entity = null;
      Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => page,
        fullscreenDialog: true,
      )).then((value){
        if (value !=null){
          Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) => PreViewPage(value: value,),
            fullscreenDialog: false,
          ));
//          if (value is String){
//
//          }else{
//            entity = value;
//            Navigator.push(context, MaterialPageRoute(
//              builder: (BuildContext context) => PreViewPage(imagePath: null,videoPath: null,entity: entity,onPressed:null,),
//              fullscreenDialog: false,
//            ));
//          }

//          _scrollController.animateTo(ScreenUtil.screenWidth,
//              curve: Curves.fastOutSlowIn,
//              duration: _kScrollDuration).then((v){
//            showPhoto = true;
//            setState(() {});
//          });
        }
      });
    } else {
      PhotoManager.openSetting();
    }

  }
}