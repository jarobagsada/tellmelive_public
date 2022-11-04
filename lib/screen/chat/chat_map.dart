import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:ui' as ue;


class Chat_Map extends StatefulWidget {
  @override
  _Chat_MapState createState() => _Chat_MapState();
}

class _Chat_MapState extends State<Chat_Map> {
  Size _screenSize;
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  Timer _timer;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CameraPosition _currentCameraPosition;
  Map<String, dynamic> routeData;
  static final CameraPosition _initialposition = CameraPosition(
    bearing: 30,
    target: LatLng(0, 0),
    tilt: 0,
  );
  IO.Socket socket;

  @override
  void initState() {


    super.initState();
    socketConnection();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _updateGPSLocation();
      }
    });
  }

  socketConnection() {


    socket = IO.io(WebServices.CHAT_SERVER, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true
    });

    socket.connect();

    pprintstatment(socket, "connect");
    pprintstatment(socket, "connect_error");
    pprintstatment(socket, "connect_timeout");
    pprintstatment(socket, "connecting");
    pprintstatment(socket, "disconnect");
    pprintstatment(socket, "error");
    pprintstatment(socket, "reconnect");
    socket.on(
      'connect',
      (_) {
        print('--yaho socket connect hogaya--connect------');
        socket.emit("new_user", {
          "chat_user_id": routeData["chat_user_id"],
          "user_id": routeData["user_id"],
          "name": routeData["name"]
        });

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    routeData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("------routdata----" + routeData.toString());
    _screenSize = MediaQuery.of(context).size;
    stoplivelocationGet();
    return Scaffold(
      key: _scaffoldKey,
      appBar: _getAppbar,
      body: Container(
          width: _screenSize.width,
          height: _screenSize.height,
          child: Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: _initialposition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Custom_color.WhiteColor,
                  padding: EdgeInsets.only(top: 20,bottom: 20),
                  width: _screenSize.width,
                  child: routeData["type"]==5? CustomWigdet.TextView(text: AppLocalizations.of(context).translate("Live location ended"),color: Custom_color.OrangeLightColor,textAlign: TextAlign.center):
                  CustomWigdet.TextView(text: AppLocalizations.of(context).translate("Live update now"),color: Custom_color.BlackTextColor,textAlign: TextAlign.center)
                ),
              )
            ],
          )),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      title: CustomWigdet.TextView(
          text: routeData["name"].toString(),
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold"),
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.BlueLightColor,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(0.0)),
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: Icon(
          Icons.arrow_back,
          color: Custom_color.BlueLightColor,
        ),
        onTap: () {
          Navigator.pop(context, true);
        },
      ),
    );
  }

  _updateGPSLocation() async {
        var now = new DateTime.now().millisecondsSinceEpoch;
        _markers.clear();
        Uint8List markerIcon = await getMarkerIcon(routeData["images"], Size(150, 150));
        await _markers.add(Marker(
            markerId: MarkerId(now.toString()+ Random().nextInt(1000).toString()),
            position:
            LatLng(double.parse(routeData["lat"].toString()) , double.parse(routeData["log"].toString())),
            icon: BitmapDescriptor.fromBytes(markerIcon)));

        _currentCameraPosition = await CameraPosition(
            target:  LatLng(double.parse(routeData["lat"].toString()) , double.parse(routeData["log"].toString())),
            zoom: 17);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
            CameraUpdate.newCameraPosition(_currentCameraPosition));
        setState(() {});
      UpdateGooglemap();


  }

  Future<void> _stopListen() async {
    Constant.locationSubscription.cancel();
    Constant.locationSubscription = null;
  }

  UpdateGooglemap()
  {

    if(routeData["type"]==3 || routeData["type"]==4) {
      socket.on('getlivelocation', (data) async {
        var now = new DateTime.now().millisecondsSinceEpoch;
        print("--getlivelocation-----" + data.toString());
        // await _markers.add(Marker(
        //     markerId: MarkerId(
        //         now.toString() + Random().nextInt(1000).toString()), position:
        // LatLng(double.parse(data["lat"].toString()),
        //     double.parse(data["lan"].toString())),
        //     icon: BitmapDescriptor.fromBytes(markerIcon)));

        _currentCameraPosition = await CameraPosition(
            target: LatLng(double.parse(data["lat"].toString()),
                double.parse(data["lan"].toString())), zoom: 17);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
            CameraUpdate.newCameraPosition(_currentCameraPosition));
        setState(() {});
        print("------Constainlatlog----" + data["lat"].toString() + "---sdsad" +
            data["lan"].toString());
      });
    }
  }

  Future<Uint8List> getMarkerIcon(String imagePath, Size size) async {
    final ue.PictureRecorder pictureRecorder = ue.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    /*
    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);


    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count,
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2));

     */

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ue.Image images = await loadUiImage(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: images, rect: oval, fit: BoxFit.cover);
    // paintImage()    ;



    // Convert canvas to image
    final ue.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData byteData =
    await markerAsImage.toByteData(format: ue.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }

  Future<ue.Image> loadUiImage(String imageAssetPath) async {
    NetworkAssetBundle networkAssetBundle = NetworkAssetBundle(Uri.parse(imageAssetPath));
    final ByteData data = await networkAssetBundle.load(imageAssetPath);
    //  final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ue.Image> completer = Completer();
    ue.decodeImageFromList(Uint8List.view(data.buffer), (ue.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  pprintstatment(IO.Socket socket, String messahe) {
    socket.on(messahe,
        (data) => print("--error-----" + messahe + "----" + data.toString()));
  }

  stoplivelocationGet()
  {
    socket.on("event_stopsharing", (data) {
      print('-------stopsharingdata-------' + data.toString());
      if (routeData["message_id"] == data["message_id"]) {
        routeData["type"]=5;
      }
      setState(() {});
      if (Constant.locationSubscription != null) {
        Constant.locationSubscription.cancel();
        Constant.locationSubscription = null;
      }
    });
  }


  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (socket != null) {
      socket.disconnect();
      socket.close();
      socket.clearListeners();
      socket.dispose();
    }
  }
}
