import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'package:flutter_app_pic/statics/CommonStyle.dart';
import 'package:video_player/video_player.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_pic/Widget/backgroundPickerView.dart';

class PreViewPage extends StatefulWidget {
  final value;
  const PreViewPage({Key key, this.value}) : super(key: key);
  @override
  _PreViewPageState createState() => _PreViewPageState();
}

class _PreViewPageState extends State<PreViewPage> {
  GlobalKey globalKey = GlobalKey();

   File imagePath;
   File videoPath;
   Size imageSize;
   Size padSize;

  double imageHeight =0;

  double scale =0;
  double iconSize = ScreenUtil.setWidth(24);
  bool _showColors = false;
  VideoPlayerController _videoController;
  VoidCallback videoPlayerListener;
  Size zoomSize = Size(ScreenUtil.screenWidth, ScreenUtil.screenHeight-ScreenUtil.bottomSafeHeight
      -ScreenUtil.navigationBarHeight-ScreenUtil.setHeight(146));
  AlignmentGeometry _alignment = Alignment.center;
  int _imagePadding = 0;
  int _alignCount = 0;
  int qTurns = 0;
  bool qFlip = false;
  int isReturn = 1;
  int _fit= 0;
  int edittype= 0;
  Color editBackColor= Color(0xFFFFF9F9F9);
  int editBackImageIndex;
  File editBackImageFile;
  List backImages = [];

  @override
  void initState() {
    for (int i=1; i<22;i++){
      String index = i.toString();
      if (i<10) index = '0'+i.toString();
      backImages.add('assets/images/img_pic_bg_$index@2x.png');
    }
    initSourse();
    _getcrementType();
    super.initState();
  }
  initSourse()async{
    if (widget.value is AssetEntity ){
      AssetEntity entity = widget.value;
      entity.type == AssetType.video ?videoPath = await entity.file:imagePath = await entity.originFile;
    }else{
      if (widget.value is String){
        String path = widget.value;
        path.contains('mp4') ? videoPath = File(path) :imagePath = File(path);
      }
    }
    if (videoPath !=null){
      initVideo(videoPath);
      print(videoPath);
    }else{
      File image = imagePath; // Or any other way to get a File instance.
      var decodedImage = await decodeImageFromList(image.readAsBytesSync());
      scale = decodedImage.height/decodedImage.width;
      imageHeight = scale*ScreenUtil.screenWidth;
      imageSize = Size(ScreenUtil.screenWidth, scale*ScreenUtil.screenWidth);
      padSize = imageSize;
//      print(decodedImage.width);
//      print(decodedImage.height);
    }

    if (mounted) setState(() {});
  }
  initVideo(File path)async{
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(path);
    videoPlayerListener = () {
      if (_videoController != null && _videoController.value.size != null) {
        if (mounted) setState(() {});
        _videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await vcontroller.setVolume(0);
    await _videoController?.dispose();
    if (mounted) {
      setState(() {
        _videoController = vcontroller;
      });
    }
    await vcontroller.play();
    if (mounted) setState(() {});
  }
  @override
  void dispose() {
    _videoController?.dispose();
    print('stop--------');
    PickerBox().remove();
    super.dispose();
  }
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

      var filePath = await ImagePickerSaver.saveFile(
          fileData: pngBytes);

      var savedFile= File.fromUri(Uri.file(filePath));
      print(savedFile);
      setState(() {

      });
      print(pngBytes);
    }
  }

  Future<void> _captureVideo() async {

  }
  _getcrementType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var type = await prefs.get('editType');
    if (type !=null)  edittype = type ;
    var colorValue = await prefs.get('color');
    if (colorValue !=null)  editBackColor = Color(colorValue) ;
    var imageValue = await prefs.get('image');
    if (imageValue !=null)  editBackImageIndex = imageValue ;
    if (imageValue == 100){
      var fle = await prefs.get('imageFile');
      editBackImageFile = File(fle);
      print(fle);
      print(editBackImageFile);

    }

    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back,color: Color(0xFFFF151411),),
            onPressed:(){
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Container(width: 50+ScreenUtil.setWidth(32),child: IconButton(icon: Text('保存',
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700)),
              onPressed: (){
                _capturePng();
                },),
            ),
          ],
          title: _videoController!=null ?Container(width:ScreenUtil.setWidth(168) ,
            child: Stack(children: <Widget>[
              Align(alignment: Alignment.centerLeft,
                child: Container(width:ScreenUtil.setWidth(56),child: IconButton(
                  icon: Image.asset(CSImages.icon_index_minute_adjust,width:iconSize ,),
                  onPressed: (){
                    Navigator.pop(context);
                  },),
                ),
              ),
              Align(alignment: Alignment.centerRight,
                child: Container(width:ScreenUtil.setWidth(56),child: IconButton(
                  icon: Image.asset(_videoController.value.volume>0?CSImages.icon_index_voice_on:CSImages.icon_index_voice_off),
                  onPressed: (){
                    _videoController.setVolume(_videoController.value.volume==0?1.0:0.0);
                    if (mounted) setState(() {});
                  },),
                ),
              ),
            ],),
          ):Text('编辑'),
          centerTitle: true,

        ),
        body:Padding(padding:EdgeInsets.only(top: 0,bottom: ScreenUtil.bottomSafeHeight) ,child:
        Container(color: editBackColor,
          child: Stack(children: <Widget>[
            Positioned(top: ScreenUtil.setHeight(48),left: 0,right: 0,
                bottom: ScreenUtil.setHeight(98),
                child:imagePath != null? RepaintBoundary(
                    key: globalKey,
                    child:imageSize==null ?Container():new ZoomableImage(
                        new FileImage(imagePath),
                        placeholder: const Center(child: const CircularProgressIndicator()),
                        backgroundColor: editBackColor,
                        isUpdate:isReturn,
                        imageSize: imageSize,
                        quarterTurns:qTurns,
                        dropFilter:edittype==1?true:false,
                        backgroundImage:editBackImageIndex !=null ?editBackImageIndex==100? editBackImageFile!=null?
                        FileImage(editBackImageFile):null:AssetImage(backImages[editBackImageIndex]):null,
                        showColor:edittype==0?true:false,
                        flipHorizontally:qFlip,
                    ),
                ):videoPath!=null && _videoController!=null?Center(
                  child:
                  AspectRatio(
                      aspectRatio: _videoController.value.size != null
                          ? _videoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(_videoController)),
                ):Container()
            ),
            Positioned(top: 0,left: 0,right: 0,height: ScreenUtil.setHeight(48),
              child: Container(color: Color(0xFFFFF9F9F9)),
            ),
            Positioned(bottom: ScreenUtil.setHeight(50),left: 0,right: 0,height: ScreenUtil.setHeight(48),
              child: Container(color: Color(0xFFFFF9F9F9)),
            ),
            Positioned(left: 0,right: 0,bottom: 0,height: ScreenUtil.setHeight(50),
              child:Container(color: Colors.white,
                  child: Stack(children: <Widget>[
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: _buildItem,
                      itemCount: 7,
                    ) ,
                    Positioned(top: 0,left: 0,right: 0,height: 1,
                      child: Container(color: Color(0xFFFFE6E6E6),),
                    ),
                  ],)
              ),
            )
          ],
          ),
        ),
        )

    );
  }
  Widget _buildItem(BuildContext context, int index) {
    String aset = CSImages.getBottomAsset(index);
    double iconSize = ScreenUtil.setWidth(32);
    return Center(
      child:Container(width:ScreenUtil.screenWidth/7,child:
      IconButton(icon: Image.asset(aset,width:iconSize,height: iconSize,), onPressed: (){
        if (index == 0){
          showColorsView();
        }else {
          if(index ==1){
            _imagePadding = 0;
            imageSize = Size(ScreenUtil.screenWidth, scale*ScreenUtil.screenWidth);
            padSize = imageSize;
            _fit = 0;
          }else if(index == 2){
            _imagePadding = 0;
            imageSize = Size(zoomSize.height/scale, zoomSize.height);
            padSize = imageSize;
            _fit = 1;
          }else if(index == 3){
            int ape = _fit ==0 ? ScreenUtil.setWidth(30).toInt() :ScreenUtil.setHeight(30).toInt();
            if (_imagePadding == 0 || _imagePadding==ape){
              _imagePadding = ape*3;
            }else{
              _imagePadding -= ape;
            }
            imageSize = Size(padSize.width-_imagePadding, padSize.height-_imagePadding);
          }else if(index == 6){
          }else if(index == 5){
            if (qTurns ==0){
              qTurns = 4;
            }
            qTurns-=1;
          }else{
            qFlip = !qFlip;
          }
          isReturn+=1;

          if (mounted) setState(() {});

        }
      })
      ),

    );
  }

  void showColorsView(){
    _showColors = !_showColors;
    if (_showColors){
      PickerBox().showView(PngPage(callback: (value){
        setState(() {
          edittype = value;
        });
      },selectType: edittype,
        colorCallback: (color){
          setState(() {
            editBackColor = color;
          });
        },
        selectImageIndex: editBackImageIndex,
        selectImageName: editBackImageFile,
        editImages: backImages,
        imageCallback: (index){
        if (index is int){
          editBackImageIndex = index;
        }else{
          editBackImageFile = index;
          editBackImageIndex = 100;
        }
          setState(() {
          });
        },
      ),context);
    }else{
      PickerBox().remove();
    }
  }

  Future<ui.Image> _getImage(File path) {
    Image image =Image.file(path);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener((ImageInfo info, bool _) => completer.complete(info.image));
    return completer.future;
  }
}

