import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_pic/statics/Screen.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_pic/statics/CommonStyle.dart';
import 'package:video_player/video_player.dart';
import 'package:lamp/lamp.dart';

List<CameraDescription> cameras;

class CemeraPage extends StatefulWidget {

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CemeraPage> {
  double bottomHeight = ScreenUtil.bottomSafeHeight+ScreenUtil.setHeight(132);
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  Duration _kScrollDuration = Duration(milliseconds: 300);
  final ScrollController _scrollController = ScrollController();

  CameraController controller;
  String _imagePath;
  String videoPath;
  bool _showCamera = true;
  bool _reture = false;
  bool _isStartVideo = false;
  bool _showVideoPlay = false;
  bool isTakephoto = true;
  bool _hasFlash = false;

  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
//  Timer _countdownTimer;
//  int _countdownNum = 0;

  initCamera() async {
    availableCameras().then((v){
      cameras = v;
      controller = CameraController(cameras[0], ResolutionPreset.low);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });

  }

  @override
  void initState() {
    super.initState();
    initCamera();
    _scrollController.addListener(() {
      bool isPhoto;
    _scrollController.offset>0? isPhoto=false:isPhoto=true;
      if(isPhoto != isTakephoto){
        isTakephoto = isPhoto;
        _isStartVideo = false;
//        removeTimer();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController.dispose();
    videoController = null;
//    print('11111');
//    removeTimer();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF1B181C),
        centerTitle: true,
        leading:IconButton(icon: Image.asset(_hasFlash?CSImages.icon_flash_auto:CSImages.icon_flash_off),
            iconSize: ScreenUtil.setWidth(45),
            color: Colors.white,
            onPressed: (){
              _hasFlash = !_hasFlash;
              setState(() {});
              _hasFlash ?Lamp.turnOn():Lamp.turnOff();
            }) ,
//        title: isTakephoto?Container():_showVideoPlay?Container():_buldVideoPosition(),
      ),
      body: Stack(children: <Widget>[
        Positioned(left: 0,right: 0,bottom: bottomHeight,top: 0,
            child:Center(child: _showCamera&& controller !=null ?AspectRatio(
                aspectRatio:controller.value.aspectRatio,
                child: CameraPreview(controller)):isTakephoto && _imagePath !=null?
            Image.file(File(_imagePath),fit: BoxFit.cover,):_showVideoPlay?
            AspectRatio(
                aspectRatio: videoController.value.size != null
                    ? videoController.value.aspectRatio
                    : 1.0,
                child: VideoPlayer(videoController))
                :new Container()
            )
        ),
        Positioned(left: 0,right: 0,height: bottomHeight,bottom: 0,
          child: Container(color: Colors.black.withOpacity(0.9),
            child: !_showCamera?_buldPreBottom():_buldTakeBottom()
          ),
        ),

      ],),

    );
  }
  Widget _buldVideoPosition(){
    String durtion = '00:00:00';
//    if (_countdownNum>0){
//      final String poHourse = getDouble((_countdownNum/3600).toInt());
//      final String poMinute = getDouble((_countdownNum%360)~/60);
//      final String poSeconds = getDouble(_countdownNum%60);
//      durtion = '$poHourse:$poMinute:$poSeconds';
//    }
    return Text(durtion,style: TextStyle(color: Colors.white),);
  }

  String getDouble(int po) {
    if (po <10){
      String poStr = po.toString();
      return'0$poStr';
    }else{
      return po.toStringAsPrecision(2);
    }
  }

  //拍摄底部
  Widget _buldTakeBottom(){
    double height = ScreenUtil.setHeight(32);
    double width = ScreenUtil.setWidth(48);
    double spr = (ScreenUtil.screenWidth/3)/ScreenUtil.setHeight(100);
    return Stack(children: <Widget>[
        Positioned(height: height,top: 0,left: 0,right: 0,
          child: Center(child: Container(width: width*3,child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection : Axis.horizontal,
            reverse:true,
            child: Container(width: width*4,height: height,
              child: Row(children: <Widget>[
                Container(width: width,),
                Container(width: width,child: Center(child: IconButton(icon: Text('视频',style:
                TextStyle(color: !isTakephoto ? Color(0xFFFFFFE025):Colors.white),), onPressed: (){
                  _scrollController.animateTo(width,
                      curve: Curves.fastOutSlowIn,
                      duration: _kScrollDuration).then((v){
                    setState(() {});
                  });
                })),),
                Container(width: width,child: Center(child: IconButton(icon: Text('照片',
                    style: TextStyle(color: isTakephoto ? Color(0xFFFFFFE025):Colors.white)), onPressed: (){
                  _scrollController.animateTo(0,
                      curve: Curves.fastOutSlowIn,
                      duration: _kScrollDuration).then((v){
                    setState(() {});
                  });
                })),),
              ],
              ),
            ),
          )
          ),)
        ),

        Positioned(top: height,bottom: 0,left: 0,right: 0,
        child:Center(child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio:spr,
          ),
          itemBuilder: _buildBottomItem,
          itemCount: 3,
          physics: new NeverScrollableScrollPhysics(),
        ),)
      )

    ]);
  }
  Widget _buildBottomItem(BuildContext context, int index) {
    Widget content ;
    if (index == 0){
    content = Text('Cancel',
        style:TextStyle(color: Colors.white,fontSize: 20));
    }else if(index == 1){
      content = Image.asset(isTakephoto?CSImages.btn_camera_photo_normal:
      _isStartVideo?CSImages.btn_camera_video_press:CSImages.btn_camera_video_normal);
    }else{
      content = Image.asset(CSImages.icon_camera_change,width: ScreenUtil.setWidth(30),height: ScreenUtil.setWidth(30),);

    }
    return Center(
        child:Container(width:ScreenUtil.screenWidth/3,height: ScreenUtil.setHeight(100),
          child:
            IconButton(icon: content,color: Colors.white, onPressed: (){
              if(index == 1){
                if (!isTakephoto){
                  _isStartVideo = !_isStartVideo;
                  if (_isStartVideo){
                    onVideoRecordButtonPressed();
//                    reGetCountdown();
                  }else{
                    onStopButtonPressed();
//                    removeTimer();
                  }
                }else{
                  _showCamera = false;
                  onTakePictureButtonPressed();
                }
              }else if(index == 2){
                _reture = !_reture;
                if (_reture)
                  onNewCameraSelected(cameras[1]);
                else
                  onNewCameraSelected(cameras[0]);
              }else{
                Navigator.pop(context);
              }
            }),


        ),

    );
  }
  //拍摄完成--底部
  Widget _buldPreBottom(){
    return Stack(children: <Widget>[
      Align(alignment: Alignment.centerLeft,
        child: Container(width: ScreenUtil.screenWidth/2,child: IconButton(icon: Text('Retake',
          style:TextStyle(color: Colors.white,fontSize: 20),), onPressed: (){
          if (_showVideoPlay){
            _stopVideoPlayer();
          }else{
            _imagePath = null;
          }
          setState(() {
            _showCamera = true;
          });
        }),),
      ),
      Align(alignment: Alignment.centerRight,
        child:Container(width: ScreenUtil.screenWidth/2,child: IconButton(icon: Text(_showVideoPlay?'User Video':'User Photo',
            style:TextStyle(color: Colors.white,fontSize: 20)), onPressed: (){
//           videoController?.dispose();
          Navigator.pop(context,_showVideoPlay?videoPath:_imagePath);

//          saveImage(_showVideoPlay?videoPath:_imagePath);
        }),),),
    ],);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.low);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
//        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
//      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
  // button clicked
  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        print(filePath);
        setState(() {
          _imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
      }

    });
  }
  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      _showCamera = false;
      if (mounted) setState(() {});
    });
  }
  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
      print('stopVideoRecording ------------');
    } on CameraException catch (e) {
      return null;
    }
    await _startVideoPlayer();

  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        _imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
    _showVideoPlay = true;
    if (mounted) setState(() {});
  }
  Future<void> _stopVideoPlayer() async {
    if (mounted) {
      setState(() {
        videoPath = null;
        videoController?.pause();
      });
    }
    _showVideoPlay = false;
    if (_reture)
      onNewCameraSelected(cameras[1]);
    else
      onNewCameraSelected(cameras[0]);
    if (mounted) setState(() {});
  }
//
//  void reGetCountdown() {
//    setState(() {
//      if (_countdownTimer != null) {
//        return;
//      }
//      _countdownTimer =
//      new Timer.periodic(new Duration(seconds: 1), (timer) {
//        setState(() {
//          _countdownNum = _countdownNum+1;
//          print(_countdownNum);
//        });
//      });
//    });
//  }
//  void removeTimer() {
//    setState(() {
//      _countdownTimer?.cancel();
//      _countdownTimer = null;
//      _countdownNum = 0;
//    });
//  }

  void saveImage(String filePath) async{
    final dbBytes = await rootBundle.load(filePath);
    var buffer=  dbBytes.buffer.asUint8List();
    var savePath = await ImagePickerSaver.saveFile(
        fileData:buffer);
    print(savePath);
    Navigator.pop(context,savePath);

    print('3333');

  }
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }

    return filePath;
  }
}
