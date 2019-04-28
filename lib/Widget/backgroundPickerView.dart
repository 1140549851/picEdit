import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_app_pic/statics/Screen.dart';
import 'package:flutter_app_pic/statics/CommonStyle.dart';
import 'dart:async';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PickerBox {
  BuildContext currentContext;
  OverlayEntry overlayEntry;
  // 工厂模式
  factory PickerBox() =>_getInstance();
  static PickerBox get instance => _getInstance();
  static PickerBox _instance;
  PickerBox._internal() {
    // 初始化
  }
  static PickerBox _getInstance() {
    if (_instance == null) {
      _instance = new PickerBox._internal();
    }
    return _instance;
  }
  showView(Widget child, BuildContext context){
    var overlayState = Overlay.of(context);
    double bottom = ScreenUtil.bottomSafeHeight+ScreenUtil.setHeight(56);
    double left = ScreenUtil.setWidth(11);
    overlayEntry = new OverlayEntry(builder: (context) {
      return Positioned(bottom: bottom, left: left, right: left,
          child:child
      );
    });
    overlayState.insert(overlayEntry);
  }
  remove(){
    if (overlayEntry !=null)
    overlayEntry.remove();
  }

}

class PngPage extends StatefulWidget {
  final callback;
  final colorCallback;

  final int selectType;
  final Color selectColor;
  final int selectImageIndex;
  final File selectImageName;

  final List editImages;

  final imageCallback;
  const PngPage({Key key,this.callback,this.selectType,this.colorCallback,this.selectColor
    ,this.selectImageIndex,this.imageCallback,this.editImages,this.selectImageName
  }) : super(key: key);

  @override
  _PngPageState createState() => _PngPageState();
}

class _PngPageState extends State<PngPage> {
  double speHeight = ScreenUtil.screenHeight - ScreenUtil.setHeight(88)
      -ScreenUtil.navigationBarHeight-ScreenUtil.bottomSafeHeight;
  double containerHeight = 0;
  Color currentColor = Colors.yellow;
  int selectType = 0;
  List titles = ['色','ぼかし','画像'];
  double speWidth = ScreenUtil.setWidth(22);
  int selectPicNum = 0;

  void changeColor(Color color) => setState(() => currentColor = color);

  File _imageFile;

  Future getImage() async {
    File image = await ImagePickerSaver.pickImage(source: ImageSource.gallery);
    print(image);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('image', 100);
    await prefs.setString('imageFile', image.path);
    widget.imageCallback(image);
    setState(() {
      _imageFile = image;
    });
  }
  @override
  void initState() {
    if (widget.selectType !=null)  selectType = widget.selectType ;
    containerHeight = selectType == 1?ScreenUtil.setHeight(118):speHeight;
    if (widget.selectColor !=null)  currentColor = widget.selectColor ;
    if (widget.selectImageIndex !=null)  selectPicNum = widget.selectImageIndex ;

    super.initState();
  }

  Widget _buildColorView(){
    return Column(children: <Widget>[
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return Padding(padding: EdgeInsets.only(top: ScreenUtil.setHeight(32),),
              child: Container(width: box.maxWidth,
                child: Stack(children: <Widget>[
                  Text('枠の色',style:TextStyle(color: Color(0xffFF151411),fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,),),
                  Positioned(right: 0,
                    child: Text('リセット',style:TextStyle(color: Color(0xffFF151411),fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,),),
                  )
                ],),
              )
          );
        },
      ),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return  ColorPicker(
              pickerColor: currentColor,
              onColorChanged: ((color){
                currentColor = color;
                widget.colorCallback(currentColor);
                _incrementColor(color);
              }),
              colorPickerWidth:box.maxWidth,
              pickerAreaHeightPercent:(containerHeight-ScreenUtil.setHeight(140)-20)/box.maxWidth
          );

        },
      ),

    ],);
  }
  Widget _buildPhotoView(){
    double picHeight = containerHeight-ScreenUtil.setHeight(216)-20;
    picHeight>speWidth ?speWidth:picHeight;
    return Column(crossAxisAlignment : CrossAxisAlignment.start,children: <Widget>[
      Padding(padding: EdgeInsets.only(top: ScreenUtil.setHeight(32),),
        child:  Text('枠の画像',style:TextStyle(color: Color(0xffFF151411),fontSize: 14,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,),),
      ),
      Padding(padding: EdgeInsets.only(top: ScreenUtil.setHeight(18),)),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          double iconSize = ScreenUtil.setHeight(40);
          return Container(width: box.maxWidth,height: iconSize,
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, //每行三列
                  childAspectRatio: 1.0 ,//显示区域宽高相等
                  mainAxisSpacing:ScreenUtil.setWidth(16),
                ),
                itemCount: widget.editImages.length+1,
                scrollDirection : Axis.horizontal,
                itemBuilder: (context, index) {
                  return FlatButton(onPressed: (){
                    if (index ==0){
                      getImage();
                    }else{
                      if (selectPicNum !=index-1){
                        setState(() {
                          selectPicNum = index-1;
                        });
                        _incrementImage(selectPicNum);
                        widget.imageCallback(selectPicNum);
                      }
                    }
                  },
                    color: Color(0xffFFFFE025),
                    child:index == 0?Icon(Icons.add,color: Colors.black,):new ClipRRect(
                      borderRadius: BorderRadius.circular(iconSize),
                      child: new Image.asset(widget.editImages[index-1]),
                    ),
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(iconSize/2)),
                    padding: EdgeInsets.all(0.0),
                  );
                }
            ),
          );
        },
      ),
      Padding(padding: EdgeInsets.only(top: ScreenUtil.setHeight(18),)),
      Container(child: Center(child:widget.editImages.length>0?
      _imageFile !=null ?Image.file(_imageFile,width: picHeight,height: picHeight,fit: BoxFit.cover,):
    selectPicNum ==100 ?Image.file(widget.selectImageName,width: picHeight,height: picHeight,fit: BoxFit.cover):
      Image.asset(widget.editImages[selectPicNum],width: picHeight,height: picHeight,fit: BoxFit.cover)
          :Container()),
      )

    ],);
  }
  List<Widget> _buildTypeView(){
    List<Widget> widgets =[];
    for (int i=0; i<titles.length;i++){
      widgets.add(
          GestureDetector(onTap: (){
            if (i==1){
              containerHeight = ScreenUtil.setHeight(118);
            }else if(i==0){
              containerHeight = speHeight;
            }else {
              containerHeight = speHeight;
            }
            widget.callback(i);
            _incrementType(i);
            setState(() {
              selectType = i;
            });
          },
            child: Container(width: 50,
              child: Center(child:
              Text(titles[i],style:TextStyle(color: Color(0xffFF151411),fontSize: 12,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,),),),
              decoration:i!=selectType?null : BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(12.0)),
            ),
          )
      );
    }
    return widgets;

  }
  _incrementType(int type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('editType', type);
  }
  _incrementColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color', color.value);
  }
  _incrementImage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('image', index);

  }
  @override
  Widget build(BuildContext context) {
    return Container(height: containerHeight,width: ScreenUtil.screenWidth-22,
      child: Stack(children: <Widget>[
        Container(width: ScreenUtil.screenWidth-22,height: containerHeight,
          child:ConstrainedBox(
            child: Image.asset(CSImages.poppup_bg,fit: BoxFit.fill,),
            constraints: new BoxConstraints.expand(),
          ),
        ),

        Positioned(top: 0,left: speWidth,right: speWidth,bottom: 0,
          child: Stack(children: <Widget>[
            Positioned(height: 24,left: 0,right: 0,bottom: ScreenUtil.setHeight(52),
              child: Stack(
                children: <Widget>[
                  Text('枠の種類',style:TextStyle(color: Color(0xffFF151411),fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,),),
                  Positioned(right: 0,width: 150,top: 0,bottom: 0,
                      child:Container(
                        decoration:BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Row(children:_buildTypeView()) ,
                      )
                  ),
                ],),
            ),
            selectType == 0 || selectType == 2?Positioned(top: 0,left: 0,right: 0,bottom:ScreenUtil.setHeight(108),
              child: selectType == 0 ?_buildColorView():_buildPhotoView(),
            ):Container(height:ScreenUtil.setHeight(32) ,),
          ],),
        ),

      ],),

    );
  }
}