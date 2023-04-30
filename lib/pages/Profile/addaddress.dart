// ignore_for_file: prefer_const_constructors, unused_import, camel_case_types, unused_element, non_constant_identifier_names,   must_be_immutable, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, unused_field
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_place_search/place_search.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:singlerestaurant/common%20class/EngString.dart';
import 'package:singlerestaurant/pages/Home/Search.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';

import 'package:sizer/sizer.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'confirm location.dart';
import 'manage address.dart';
import 'package:geolocator/geolocator.dart';

class Add_address extends StatefulWidget {
  String? isedit;
  var addressid;
  double? latitude;
  double? longitude;
  String? area;
  String? houseno;
  String? address;
  var addresstype;

  @override
  State<Add_address> createState() => _Add_addressState();
  Add_address([
    this.isedit,
    this.addressid,
    this.latitude,
    this.longitude,
    this.area,
    this.houseno,
    this.address,
    this.addresstype,
  ]);
}

class _Add_addressState extends State<Add_address> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  String? Area = "";
  String? Address = "";
  double _latitude = Engstring.latitude;
  double _longitude = Engstring.longitude;

  @override
  void initState() {
    super.initState();
    print("sdffgvdajdknafjsIGDJJUIAE");
    print(widget.address);
    print(widget.addressid);
    print(widget.area);
    print(widget.isedit);
    print(widget.latitude);
    print("HVDAEFJKWHIAEFUGYISREFAIH");
    if (widget.isedit == "1") {
      setState(() {
        _latitude = widget.latitude!;
        _longitude = widget.longitude!;
      });
    } else {
      _latitude = Engstring.latitude;
      _longitude = Engstring.longitude;
    }
    getaddress(_latitude, _longitude);
  }

  Future<void> getaddress(double latitude, double longitude) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(latitude, longitude);

    Placemark place = placemark[0];

    setState(() {
      Area = place.subLocality;
      Address =
          "${place.street}, ${place.postalCode} ${place.administrativeArea} ${place.country}";
    });
  }

  static final LatLng _kMapCenter =
      LatLng(Engstring.latitude, Engstring.longitude);

  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 16.0, tilt: 0, bearing: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => Manage_Addresses()),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            )),
        leadingWidth: 40,
        title: widget.isedit == "1"
            ? Text(
                LocaleKeys.Edit_Address.tr(),
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
              )
            : Text(
                LocaleKeys.Add_Address.tr(),
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
              ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 57.h,
                color: Colors.grey,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(_latitude, _longitude),
                      zoom: 18.0,
                      tilt: 0,
                      bearing: 0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onCameraMove: (position) async {
                    // Position position = await _determinePosition();

                    setState(() {
                      Engstring.latitude = position.target.latitude;
                      Engstring.longitude = position.target.longitude;
                      getaddress(Engstring.latitude, Engstring.longitude);
                    });
                  },
                ),
              ),
              Positioned(
                right: Get.size.width * 0.18,
                top: Get.size.width * 0.35,
                bottom: Get.size.width * 0.5,
                left: Get.size.width * 0.18,
                child: Image.asset(
                  "Assets/Image/ic_locationpin.png",
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                ),
                child: Text(
                  LocaleKeys.Selectdelloca.tr(),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 8.8.sp),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return SizedBox(
                          height: 85.h,
                          child: Scaffold(
                            body: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  PlaceAutocomplete.widget(
                                      minLengthToStartSearch: 0,
                                      autoFocus: true,
                                      textfieldDecoration: InputDecoration(
                                        hintText: LocaleKeys.Search.tr(),
                                        labelText: LocaleKeys.Search.tr(),
                                      ),
                                      onDone: (e) async {
                                        setState(() {
                                          mapController.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                                      zoom: 18.0,
                                                      target: LatLng(
                                                        e.point!.latitude,
                                                        e.point!.longitude,
                                                      ))));
                                        });

                                        Get.back();
                                      }),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6)),
                  margin: EdgeInsets.only(
                    top: 1.5.h,
                    right: 4.w,
                    left: 4.w,
                  ),
                  height: 4.h,
                  width: 20.w,
                  alignment: Alignment.center,
                  child: Text(
                    LocaleKeys.Change.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: color.primarycolor,
                      fontSize: 8.8.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 1.8.h,
            ),
            child: Row(children: [
              ImageIcon(
                AssetImage('Assets/Icons/address.png'),
                size: 26,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 2.w,
                  right: 2.w,
                ),
                child: Text(
                  Area.toString(),
                  style: TextStyle(
                      fontFamily: 'Poppins_semibold', fontSize: 14.sp),
                ),
              ),
            ]),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 1.5.h,
            ),
            child: Text(
              Address.toString(),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11.sp),
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(
              bottom: 1.h,
              left: 4.w,
              right: 4.w,
            ),
            height: MediaQuery.of(context).size.height / 16,
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Confirm_location(
                      Area.toString(),
                      Address.toString(),
                      Engstring.latitude,
                      Engstring.longitude,
                      widget.addressid,
                      widget.area,
                      widget.houseno.toString(),
                      widget.address,
                      widget.addresstype.toString(),
                      widget.isedit,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: color.black,
              ),
              child: widget.isedit == "1"
                  ? Text(
                      LocaleKeys.Edit_Address.tr(),
                      style: TextStyle(
                          fontFamily: 'Poppins_Bold',
                          color: Colors.white,
                          fontSize: 12.sp),
                    )
                  : Text(
                      LocaleKeys.Confirmlocation.tr(),
                      style: TextStyle(
                          fontFamily: 'Poppins_Bold',
                          color: Colors.white,
                          fontSize: 12.sp),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
