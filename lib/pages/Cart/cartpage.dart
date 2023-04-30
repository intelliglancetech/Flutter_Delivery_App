// ignore_for_file: unrelated_type_equality_checks, prefer_const_constructors, non_constant_identifier_names, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/cartpage/isopenmodel.dart';
import 'package:singlerestaurant/Model/cartpage/ordersummaryModel.dart';
import 'package:singlerestaurant/Model/settings%20model/changepasswordmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:singlerestaurant/common%20class/icons.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Cart/addonslist.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

import '../../Theme/ThemeModel.dart';
import 'Ordersummary.dart';

class Viewcart extends StatefulWidget {
  const Viewcart({Key? key}) : super(key: key);

  @override
  State<Viewcart> createState() => _ViewcartState();
}

class _ViewcartState extends State<Viewcart> {
  int showbutton = 0;
  order_summary_model? cartdata;
  String? userid;
  String? currency;
  String? currency_position;
  cartcount count = Get.put(cartcount());

  cartlistAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    currency = (prefs.getString(APPcurrency) ?? " ");
    currency_position = (prefs.getString(APPcurrency_position) ?? " ");

    try {
      var map = {
        "user_id": userid,
      };

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Summary, data: map);

      var finalist = await response.data;
      cartdata = order_summary_model.fromJson(finalist);
      count.cartcountnumber(cartdata!.data!.length);

      return cartdata!.data;
    } catch (e) {
      rethrow;
    }
  }

  changeQTYAPI(cartid, qty) async {
    try {
      loader.showLoading();
      var map = {
        "user_id": userid.toString(),
        "cart_id": cartid.toString(),
        "qty": qty.toString()
      };

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Qtyupdate, data: map);

      var finallist = await response.data;
      var QTYdata = QTYupdatemodel.fromJson(finallist);
      if (QTYdata.status == 1) {
        loader.hideLoading();
        setState(() {
          cartlistAPI();
          // cartdata.data.removeAt(index)
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  deleteitem(cartid, index) async {
    loader.showLoading();
    try {
      var map = {"cart_id": cartid};
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Deletecartitem, data: map);
      var data = changepasswordmodel.fromJson(response.data);
      setState(() {
        cartdata!.data!.removeAt(index);
      });
      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }

  isopencloseMODEL? isopendata;
  isopenAPI() async {
    loader.showLoading();
    var map = {
      "user_id": userid,
    };

    var response = await Dio().post(
      DefaultApi.appUrl + PostAPI.isopenclose,
      data: map,
    );

    isopendata = isopencloseMODEL.fromJson(response.data);
    loader.hideLoading();
    if (isopendata!.status == 1) {
      if (isopendata!.isCartEmpty == "0") {
        _showbottomsheet();
      } else {
        Get.to(() => Homepage(0));
      }
    } else {
      loader.showErroDialog(description: isopendata!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeModel themenofier, child) {
        return SafeArea(
            child: FutureBuilder(
          future: cartlistAPI(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: color.primarycolor,
                  ),
                ),
              );
            } else if (cartdata!.data!.isEmpty) {
              return Scaffold(
                body: Center(
                  child: Text(
                    LocaleKeys.No_data_found.tr(),
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: Colors.grey),
                  ),
                ),
              );
            }
            return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    LocaleKeys.Mycart.tr(),
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: 'Poppins_semibold',
                    ),
                  ),
                  automaticallyImplyLeading: false,
                ),
                body: Padding(
                  padding: EdgeInsets.only(bottom: 6.5.h),
                  child: ListView.builder(
                    itemCount: cartdata!.data!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                          top: 1.h,
                          left: 1.5.h,
                          right: 1.5.h,
                          bottom: 1.h,
                        ),
                        height: 15.5.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.8.sp,
                            )),
                        child: Row(children: [
                          SizedBox(
                            width: 28.w,
                            height: 15.5.h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                cartdata!.data![index].itemImage.toString(),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 2.w,
                                left: 2.w,
                                bottom: 0.8.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (cartdata!.data![index].itemType ==
                                            "1") ...[
                                          SizedBox(
                                            height: 2.h,
                                            // color: Colors.black,
                                            child: Image.asset(
                                              Defaulticon.vegicon,
                                            ),
                                          ),
                                        ] else if (cartdata!
                                                .data![index].itemType ==
                                            "2") ...[
                                          SizedBox(
                                            height: 2.h,
                                            // color: Colors.black,
                                            child: Image.asset(
                                              Defaulticon.nonvegicon,
                                            ),
                                          ),
                                        ],
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        SizedBox(
                                          width: 42.w,
                                          child: Text(
                                            cartdata!.data![index].itemName
                                                .toString(),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontFamily: 'Poppins_semibold',
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            deleteitem(
                                                cartdata!.data![index].id
                                                    .toString(),
                                                index);
                                          },
                                          child: SvgPicture.asset(
                                            'Assets/svgicon/delete.svg',
                                            color: themenofier.isdark
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (cartdata!.data![index].variation ==
                                      "") ...[
                                    Expanded(
                                      child: Text(
                                        "-",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          // color: Colors.grey,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: Text(
                                        cartdata!.data![index].variation
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.grey,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (cartdata!.data![index].addonsName ==
                                      "") ...[
                                    Expanded(
                                      child: Text(
                                        "-",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          modelsheet(
                                              context,
                                              cartdata!.data![index].addonsName,
                                              cartdata!
                                                  .data![index].addonsPrice,
                                              currency,
                                              currency_position);
                                        },
                                        child: Text(
                                          "${LocaleKeys.Add_ons.tr()}>>",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            color: Colors.grey,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  Padding(
                                    padding: EdgeInsets.only(top: 0),
                                    child: Row(children: [
                                      SizedBox(
                                        child: Text(
                                          currency_position == "1"
                                              ? "$currency${(numberFormat.format((double.parse(cartdata!.data![index].itemPrice!.toString()) + double.parse(cartdata!.data![index].addonsTotalPrice!.toString()))))}"
                                              : "${(numberFormat.format((double.parse(cartdata!.data![index].itemPrice!.toString()) + double.parse(cartdata!.data![index].addonsTotalPrice!.toString()))))}$currency",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontFamily: 'Poppins_semibold',
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 3.6.h,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          // color: Theme.of(context).accentColor
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  if (cartdata!
                                                          .data![index].qty ==
                                                      "1") {
                                                    deleteitem(
                                                      cartdata!.data![index].id,
                                                      index,
                                                    );
                                                  } else {
                                                    changeQTYAPI(
                                                      cartdata!.data![index].id,
                                                      int.parse(cartdata!
                                                              .data![index].qty
                                                              .toString()) -
                                                          1,
                                                    );
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.remove,
                                                  color: color.green,
                                                  size: 16,
                                                )),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                cartdata!.data![index].qty
                                                    .toString(),
                                                style:
                                                    TextStyle(fontSize: 10.sp),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  changeQTYAPI(
                                                    cartdata!.data![index].id,
                                                    int.parse(cartdata!
                                                            .data![index].qty
                                                            .toString()) +
                                                        1,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.add,
                                                  color: color.green,
                                                  size: 16,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  )
                                ],
                              ),
                            ),
                          )
                        ]),
                      );
                    },
                  ),
                ),
                bottomSheet: Container(
                  margin: EdgeInsets.only(
                    left: 3.w,
                    right: 3.w,
                    top: 1.h,
                  ),
                  height: 6.5.h,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      isopenAPI();
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: color.primarycolor),
                    child: Text(
                      LocaleKeys.Continue.tr(),
                      style: TextStyle(
                          fontFamily: 'Poppins_semibold',
                          color: Colors.white,
                          fontSize: fontsize.Buttonfontsize),
                    ),
                  ),
                ));
          },
        ));
      },
    );
  }

  _showbottomsheet() {
    int _value = 0;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Consumer(builder: (context, ThemeModel themenofier, child) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 36.h,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 1.h)),
                    Center(
                      child: Text(
                        LocaleKeys.Select_Option.tr(),
                        style: TextStyle(
                            fontFamily: 'Poppins_semibold', fontSize: 14.5.sp),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() => _value = 1);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: _value == 1
                                          ? color.green
                                          : Colors.transparent)),
                              margin: EdgeInsets.only(left: 6.w, top: 3.h),
                              height: 17.h,
                              width: 37.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    child: Image.asset(
                                      'Assets/product/Delivery.png',
                                      height: 9.h,
                                      width: 13.w,
                                    ),
                                  ),
                                  Text(
                                    LocaleKeys.DELIVERY.tr(),
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: themenofier.isdark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 8.5.sp),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () {
                            setState(() => _value = 2);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: _value == 2
                                          ? color.green
                                          : Colors.transparent)),
                              margin: EdgeInsets.only(left: 6.w, top: 3.h),
                              height: 17.h,
                              width: 37.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    child: Image.asset(
                                      'Assets/product/Takeaway.png',
                                      height: 9.h,
                                      width: 13.w,
                                    ),
                                  ),
                                  Text(
                                    LocaleKeys.Takeaway.tr(),
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: themenofier.isdark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 8.5.sp),
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 2.w, right: 2.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.5),
                            border: Border.all(
                              color: color.primarycolor,
                            ),
                          ),
                          height: 6.5.h,
                          width: 45.w,
                          child: TextButton(
                            // style: ElevatedButton.styleFrom(
                            //   foregroundColor: color.primarycolor,
                            // ),
                            child: Text(
                              LocaleKeys.Cancel.tr(),
                              style: TextStyle(
                                  fontFamily: 'Poppins_semibold',
                                  color: color.primarycolor,
                                  fontSize: fontsize.Buttonfontsize),
                            ),
                            onPressed: () {
                              _value = 0;
                              Get.back();
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.5),
                          ),
                          height: 6.5.h,
                          width: 45.w,
                          child: TextButton(
                            onPressed: () {
                              if (_value == 0) {
                                loader.showErroDialog(
                                  description:
                                      LocaleKeys.Please_select_option.tr(),
                                );
                              } else {
                                Get.back();
                                Get.to(() => Ordersummary(_value.toString()));
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: color.green,
                            ),
                            child: Text(
                              LocaleKeys.Checkout.tr(),
                              style: TextStyle(
                                  fontFamily: 'Poppins_semibold',
                                  color: Colors.white,
                                  fontSize: fontsize.Buttonfontsize),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 1.5.h,
                    )
                  ],
                ),
              );
            });
          });
        });
  }
}
