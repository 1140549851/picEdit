import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'dart:typed_data';
import 'package:flutter_app_pic/statics/CommonStyle.dart';
class AlbumListPage extends StatefulWidget {
  final callback;
  const AlbumListPage({Key key, this.callback}) : super(key: key);
  @override
  _AlbumListPageState createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  List<AssetPathEntity> pathDatalist = [];
  var height = ScreenUtil.screenHeight;
  var width = ScreenUtil.screenWidth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPhotoManager();
  }

  void initPhotoManager() async{
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
      list.forEach((path){
        if(path.name.contains('Recent')){
          path.name = '时刻';
        }else if (path.name.contains('All Photos')){
          path.name = '全部照片';
        }
        pathDatalist.add(path);
        setState(() {});
      });
      List<AssetPathEntity> viodeos = await PhotoManager.getVideoAsset();
      if(viodeos.length>2){
        AssetPathEntity pathEntity = viodeos[1];
        pathEntity.name = '视频';
        pathDatalist.insert(2,pathEntity);
        setState(() {});
      }
    }
  }
  static  Future<List<AssetEntity>>getPhotosData(AssetPathEntity entity) async {
    return entity.assetList;
  }
  @override
  Widget build(BuildContext context) {
    Widget _buildPreview(AssetEntity asset) {
      double photoSize = ScreenUtil.setWidth(80);
      return FutureBuilder<Uint8List>(
        future: asset.thumbDataWithSize(150, 150),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.data != null) {
            return Container(width: photoSize,height: photoSize,
              child:Image.memory(
                snapshot.data,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }
          return Container();
        },
      );
    }
    Widget _buildItem(BuildContext context, int index) {
      var data = pathDatalist[index];
      Widget content = FutureBuilder<List<AssetEntity>>(
        future: data.assetList,
        builder:
            (BuildContext context, AsyncSnapshot<List<AssetEntity>> snapshot) {
          var assetList = snapshot.data;
          if (assetList == null || assetList.isEmpty) {
            return Container();
          }
          AssetEntity asset = assetList[0];
          return _buildPreview(asset);
        },
      );

      return GestureDetector(
          child: Container(color: Colors.white,
            child: Stack(children: <Widget>[
              Positioned(bottom: 0,left: 0,right: 0,height: 1,
                child: Container(color: Color(0xFFFFE6E6E6),),
              ),
              Positioned(left: ScreenUtil.setWidth(16),right: ScreenUtil.setWidth(16),
                top:ScreenUtil.setHeight(19) ,bottom: ScreenUtil.setHeight(16),
                child: Stack(alignment : AlignmentDirectional.center,children: <Widget>[
                  Align(alignment: Alignment.centerLeft,
                      child:content
                  ),
                  Positioned(left: ScreenUtil.setWidth(95),
                    child: Text(data.name,
                        style: TextStyle(fontSize: 14
                            ,color: Color(0xFFFF151411))),

                  ),
                  Align(alignment: Alignment.centerRight,
                      child:Image.asset(CSImages.icon_index_copy,
                          width: ScreenUtil.setWidth(24),height: ScreenUtil.setWidth(24))
                  ),
                ]),
              )
            ],),
          ),
          onTap:(){
           widget.callback(data);
          }
      );
    }
    return Scaffold(
        appBar:AppBar(
          title: Text('写真'),
          centerTitle: true,
          actions: <Widget>[
            Container(width: 91+ScreenUtil.setWidth(32),child: IconButton(icon: Text('キャンセル',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18
                    ,color: Color(0xFFFF151411))),
              onPressed: (){
                Navigator.pop(context);
            },),
            )
          ],
          leading: Text(''),
        ),
        body:new ListView.builder(
          itemBuilder: _buildItem,
          itemExtent:ScreenUtil.setHeight(35)+ScreenUtil.setHeight(80) ,
          itemCount: pathDatalist.length,
        ),


    );
  }

}
