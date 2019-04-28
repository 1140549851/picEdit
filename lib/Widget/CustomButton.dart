import 'package:flutter/material.dart';
import 'package:flutter_app_pic/statics/Screen.dart';

class Custombutton {
  creatHButton(String image, String desc,GestureTapCallback onTap){
    return Container(height:18+ScreenUtil.setWidth(122),
      child: new GestureDetector(
        onTap: onTap,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
          new Image.asset(image,width:ScreenUtil.setWidth(122) ,height: ScreenUtil.setWidth(122),),
          Positioned(bottom: 0,height: 24,left: 0,width:144 ,child: Text(desc, textAlign:TextAlign.center,
              style: TextStyle(fontSize: 16,decoration: TextDecoration.none,
                  color: Color(0xFFFF151411))),)
        ],),
      ),
    );
  }
}