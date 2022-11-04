//import 'package:carousel_slider/carousel_slider.dart';
//import 'package:flutter/material.dart';
//import 'package:miumiu/utilmethod/custom_color.dart';
//import 'package:miumiu/utilmethod/custom_ui.dart';
//class Profile_Screen extends StatefulWidget {
//
//  @override
//  _Profile_ScreenState createState() => _Profile_ScreenState();
//}
//
//class _Profile_ScreenState extends State<Profile_Screen> {
//    final List<String> images = [
//    'https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
//    'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
//    'https://images.unsplash.com/photo-1586901533048-0e856dff2c0d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//    'https://images.unsplash.com/photo-1586902279476-3244d8d18285?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
//    'https://images.unsplash.com/photo-1586943101559-4cdcf86a6f87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1556&q=80',
//    'https://images.unsplash.com/photo-1586951144438-26d4e072b891?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//    'https://images.unsplash.com/photo-1586953983027-d7508a64f4bb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//  ];
//    int _current = 0;
//
//    @override
//  Widget build(BuildContext context) {
//    return SafeArea(
//      child: Material(
//        child: CustomScrollView(
//          slivers: [
//            SliverPersistentHeader(
//              delegate: SliverCustomHeaderDelegate(callback: funcallback,collapsedHeight: 50,expandedHeight: 400,paddingTop: 0,coverImgUrl: images,title: "My App bar"),
//              pinned: true,
//              floating: true,
//            ),
//            SliverList(
////              delegate: SliverChildListDelegate([
////                CustomWigdet.TextView(text: "name",color: Custom_color.BlueLightColor,fontSize: 18),
////                CustomWigdet.TextView(text: "male",color: Custom_color.GreyLightColor),
////                Divider(thickness: 1,),
////                Column(
////                  children: <Widget>[
////                    CustomWigdet.TextView(text: "interest",color: Custom_color.BlueLightColor),
////                    CustomWigdet.TextView(text: "Men",color: Custom_color.GreyLightColor),
////                  ],
////                ),
////                Divider(thickness: 1,),
////
////
////              ])
//              delegate: SliverChildBuilderDelegate(
//                      (context, index) => Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: Container(
//                      height: 75,
//                      color: Colors.black12,
//                    ),
//                  ),
//                  childCount: 10),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//    void funcallback(int nextPage) {
//      setState(() {
//        this._current = nextPage;
//      });
//    }
//}
//class SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
//  Function callback;
//  final double collapsedHeight;
//  final double expandedHeight;
//  final double paddingTop;
//  final List<String> coverImgUrl;
//  final String title;
//
//  SliverCustomHeaderDelegate({
//    this.callback,
//    this.collapsedHeight,
//    this.expandedHeight,
//    this.paddingTop,
//    this.coverImgUrl,
//    this.title,
//  });
//
//  @override
//  double get minExtent => this.collapsedHeight + this.paddingTop;
//
//  @override
//  double get maxExtent => this.expandedHeight;
//
//  @override
//  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
//    return true;
//  }
//
//  Color makeStickyHeaderBgColor(shrinkOffset) {
//    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
//        .clamp(0, 255)
//        .toInt();
//    return Color.fromARGB(alpha, 255, 255, 255);
//  }
//
//  Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
//    if (shrinkOffset <= 50) {
//      return isIcon ? Colors.white : Colors.transparent;
//    } else {
//      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
//          .clamp(0, 255)
//          .toInt();
//      return Color.fromARGB(alpha, 0, 0, 0);
//    }
//  }
//
//  @override
//  Widget build(
//      BuildContext context, double shrinkOffset, bool overlapsContent) {
//    return Container(
//      height: this.maxExtent,
//      width: MediaQuery.of(context).size.width,
//      child: Stack(
//        fit: StackFit.expand,
//        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.only(bottom: 40.0),
//            child: CarouselSlider.builder(
//              itemCount: coverImgUrl.length,
//              options: CarouselOptions(
//                 // height: _screenSize.height,
//                  autoPlay: true,
//                  viewportFraction: 1.0,
//                  // aspectRatio: 2.0,
//                  // enlargeCenterPage: true,
//                  onPageChanged: (index, reason) {
//                    callback(index);
////                    setState(() {
////                      _current = index;
////                    });
//                  }),
//              itemBuilder: (context, index) {
//                return Container(
//                    child:
//                    CustomWigdet.GetImagesNetwork(
//                        imgURL: coverImgUrl[index],
//                        boxFit: BoxFit.cover));
//              },
//            ),
//          ),
//          Positioned(
//            bottom: 0.0,
//            //left: 0.0,
//            right: 0.0,
//            child: Container(
//              padding:
//              EdgeInsets.only(right: 14, bottom: 40),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: coverImgUrl.map((url) {
//                  int index = coverImgUrl.indexOf(url);
//                  return Container(
//                    width: 8.0,
//                    height: 8.0,
//                    margin: EdgeInsets.symmetric(
//                        vertical: 10.0, horizontal: 2.0),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: coverImgUrl == index
//                          ? Custom_color.BlueLightColor
//                          : Custom_color.WhiteColor,
//                    ),
//                  );
//                }).toList(),
//              ),
//            ),
//          ),
//          // Background image
//          // Put your head back
//          Positioned(
//            left: 0,
//            right: 0,
//            top: 0,
//            child: Container(
//              color: this.makeStickyHeaderBgColor(shrinkOffset),
//              // Background color
//              child: SafeArea(
//                bottom: false,
//                child: Container(
//                  height: this.collapsedHeight,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      IconButton(
//                        icon: Icon(
//                          Icons.arrow_back_ios,
//                          color: this.makeStickyHeaderTextColor(
//                              shrinkOffset, true), // Return icon color
//                        ),
//                        onPressed: () => Navigator.pop(context),
//                      ),
//                      Text(
//                        this.title,
//                        style: TextStyle(
//                          fontSize: 20,
//                          fontWeight: FontWeight.w500,
//                          color: this.makeStickyHeaderTextColor(
//                              shrinkOffset, false), // Title color
//                        ),
//                      ),
//                      IconButton(
//                        icon: Icon(
//                          Icons.share,
//                          color: this.makeStickyHeaderTextColor(
//                              shrinkOffset, true), // Share icon color
//                        ),
//                        onPressed: () {},
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//}
//
