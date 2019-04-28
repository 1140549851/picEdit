import 'package:flutter/material.dart';

class CSImages {

  static const String img_camera_bg = "assets/images/img_camera_bg@2x.png";
  static const String btn_camera_album = "assets/images/btn_camera_album@2x.png";
  static const String btn_camera_camera = "assets/images/btn_camera_camera@2x.png";
  static const String icon_index_copy = "assets/images/icon_index_copy@2x.png";
  static const String poppup_bg = "assets/images/poppup_bg@2x.png";

  static const String icon_index_voice_on = "assets/images/icon_index_voice_on@2x.png";
  static const String icon_index_voice_off = "assets/images/icon_index_voice_off@2x.png";
  static const String icon_index_minute_adjust = "assets/images/icon_index_minute_adjust@2x.png";

  static const String icon_bottom_1= "assets/images/icon_bottom_color@2x.png";
  static const String icon_bottom_2= "assets/images/icon_bottom_height@2x.png";
  static const String icon_bottom_3= "assets/images/icon_bottom_width@2x.png";
  static const String icon_bottom_4= "assets/images/icon_bottom_adaptation@2x.png";
  static const String icon_bottom_5= "assets/images/icon_bottom_rotate_l_r@2x.png";
  static const String icon_bottom_6= "assets/images/icon_bottom_rotate_rotate_90@2x.png";
  static const String icon_bottom_7= "assets/images/icon_bottom_center_alignment@2x.png";
  static const String btn_camera_photo_normal= "assets/images/btn_camera_photo_normal@2x.png";
  static const String btn_camera_video_normal= "assets/images/btn_camera_video_normal@2x.png";
  static const String icon_camera_change= "assets/images/icon_camera_change@2x.png";
  static const String btn_camera_video_press= "assets/images/btn_camera_video_press@2x.png";
  static const String icon_flash_off= "assets/images/icon_flash_off@2x.png";
  static const String icon_flash_auto= "assets/images/icon_flash_auto@2x.png";

  static getBottomAsset(int index){
    return [icon_bottom_1,icon_bottom_2,icon_bottom_3,icon_bottom_4,icon_bottom_5,icon_bottom_6,icon_bottom_7][index];
  }
}