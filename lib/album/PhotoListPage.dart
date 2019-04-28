import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'dart:typed_data';

class PhotoListPage extends StatefulWidget {
  final AssetPathEntity pathEntity;
  final VoidCallback onPressed;
  final callback;

  const PhotoListPage({Key key, this.pathEntity,this.onPressed,this.callback}) : super(key: key);
  @override
  _PhotoListPageState createState() => _PhotoListPageState();
}
class _PhotoListPageState extends State<PhotoListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pathEntity.name),
        actions: <Widget>[
          Container(width: 91+ScreenUtil.setWidth(32),child: IconButton(icon: Text('Cancel',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 18
                  ,color: Color(0xFFFF151411))),
            onPressed: (){
              Navigator.of(context).pop();
            },),
          )
        ],
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Color(0xFFFF151411),),
          onPressed: widget.onPressed,
        ),
      ),
      body: FutureBuilder<List<AssetEntity>>(
        future: widget.pathEntity.assetList,
        builder:
            (BuildContext context, AsyncSnapshot<List<AssetEntity>> snapshot) {
          var assetList = snapshot.data;
          if (assetList == null || assetList.isEmpty) {
            return Container();
          }
          return PhotoList(photos: assetList,callback: widget.callback,);
        },
      )
    );
  }
}
class PhotoList extends StatefulWidget {
  final List<AssetEntity> photos;
  final callback;

  const PhotoList({Key key,  this.photos,this.callback}) : super(key: key);
  @override
  _PhotoListState createState() => _PhotoListState();
}
class _PhotoListState extends State<PhotoList> {

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: _buildItem,
      itemCount: widget.photos.length,
    );
  }
  String getDouble(int po, bool sub) {
    if (po <10){
      String poStr = po.toString();
      if (sub){
        return'0$poStr';
      }else{
        return'$poStr';
      }
    }else{
      return po.toStringAsPrecision(2);
    }
  }
  
  Widget _buldDurText(AssetEntity entity){
    return FutureBuilder<Duration>(
      future: entity.videoDuration,
      builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          final int po = snapshot.data.inSeconds;
          final String poMinute = getDouble((po%3600)~/60,false);
          final String poSeconds = getDouble(po%60,true);
          String dur = "$poMinute:$poSeconds";
          return Text(dur,
              style: TextStyle(fontSize: 12
                  ,color: Colors.white));
        }
        return Container();
      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    AssetEntity entity = widget.photos[index];
    return FutureBuilder<Uint8List>(
      future: entity.thumbDataWithSize(150, 150),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return InkWell(
            onTap: (){
              widget.callback(entity);
            },
            child: Stack(children: <Widget>[
              Image.memory(
                snapshot.data,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              entity.type == AssetType.video ? Positioned (right: 5,bottom: 5,
                child: _buldDurText(entity),
              ):Container()

            ],)
          );
        }
        return Container();
      },
    );
  }

}
