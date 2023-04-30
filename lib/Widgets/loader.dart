// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class loader {
  // show error; Dialog
  static void showErroDialog({String? description = 'Something went wrong'}) {
    Get.dialog(
      AlertDialog(
        title: Text(
          LocaleKeys.Single_Restaurant.tr(),
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins_semibold'),
        ),
        content: Text(
          description ?? '',
          style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Get.isDialogOpen!) Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primarycolor,
            ),
            child: Text(
              LocaleKeys.ok.tr(),
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showLoading([String? message]) {
    Get.dialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      Center(
          child: CircularProgressIndicator(
        color: color.primarycolor,
      )),
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen!) Get.back();
  }
}

class dialogbox {
  static void showDialog(
      {String title = 'Single Resturant',
      String? description = 'Something went wrong'}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                description ?? '',
                style: TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  if (Get.isDialogOpen!) Get.back();
                },
                child: Text(
                  'Ok',
                  style: TextStyle(color: color.primarycolor, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
