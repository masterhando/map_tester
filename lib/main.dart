import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'package:latlong/latlong.dart';
import 'dart:io';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class TempImg extends StatefulWidget {
  File immagine;
  TempImg(this.immagine);
  @override
  _TempImgState createState() => _TempImgState();
}

class _TempImgState extends State<TempImg> {
  final File img;
  _TempImgState({Key key, this.img});
  @override
  Widget build(BuildContext context) {
    var immagine = widget.immagine;
    return new Scaffold(
        bottomNavigationBar: Image.file(immagine),
        body: Center(
          child: Container(
              child: RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('go back'),
          )),
        ));
  }
}

/*Future<Null> displayPrediction(Prediction p) async {
  if (p != null) {
    PlacesDetailsResponse detail =
    await _places.getDetailsByPlaceId(p.placeId);

    var placeId = p.placeId;
    double lat = detail.result.geometry.location.lat;
    double lng = detail.result.geometry.location.lng;

    var address = await Geocoder.local.findAddressesFromQuery(p.description);

    print(lat);
    print(lng);
  }
}*/

/*class demo extends StatefulWidget {
  @override
  demoState createState() => new demoState();
}

// ignore: camel_case_types
class demoState extends State<demo> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                // show input autocomplete with selected mode
                // then get the Prediction selected
                Prediction p = await PlacesAutocomplete.show(
                    context: context, apiKey: kGoogleApiKey);
                //displayPrediction(p);
              },
              child: Text('Find address'),

            )
        )
    );
  }
}*/

/*const kGoogleApiKey = "AIzaSyCeZXgiou595c6lt8_qQ9SnedqiZt-EaO4";
PlacesAutocompleteField _places = PlacesAutocompleteField(apiKey: kGoogleApiKey);*/

/*class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapApp',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}*/

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapApp',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController _controller;

  static const List<IconData> icons = const [
    Icons.refresh,
    Icons.photo_camera,
    Icons.image,
  ];
  _HomePageState({this.immagine});
  Dio porco = new Dio();
  //Response response= await porco.get('https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=YOUR_API_KEY');
  Geolocator geolocatore;

  static Position _position;
  //static LocationOptions locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);

  void checkPermission() {
    geolocatore.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });

    geolocatore
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });

    geolocatore.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  File immagine;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      immagine = image;
    });
  }

  /*_loadImage() async {
    var file = await _image.create();
    var _attendi = new Image.file(file);
    return _attendi;
  }*/

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  MapController get mapController => new MapController();

  imageSelector() async {
    dynamic cameraFile =
        await ImagePicker.pickImage(source: ImageSource.camera);
    print(cameraFile.path);
  }

  //@override
  // Widget build(BuildContext context) {

  //}

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void updateImage() {
    setState(() {
      immagine != null
          ? Image.file(immagine, fit: BoxFit.contain)
          : Text('non ci sono immagini');
    });
  }

  List<Marker> markers;
  int pointIndex;
  List points = [
    LatLng(_position != null ? _position.latitude : 40,
        _position != null ? _position.longitude : 13)
  ];

  Geolocator geolocator = Geolocator();

  Position userLocation;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    pointIndex = 0;
    markers = [
      Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: 30,
          width: 30,
          point: points[pointIndex],
          builder: (ctx) => GestureDetector(
                onTap: () {
                  print('porcopelor');
                },
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        print('porcodiaz');
                      },
                      child: Center(
                        child: ConstrainedBox(
                            constraints: new BoxConstraints.expand(),
                            child: Icon(
                              Icons.pin_drop,
                            )),
                      ),
                    )
                  ],
                ),
              ) //
          ),
/*Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(_position != null ? _position.latitude : 44, _position != null ? _position.longitude : -122),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),*/
    ];
    super.initState();

    _getLocation().then((position) {
      userLocation = position;
    });
  }

  int doItOneTime = 0;

  @override
  Widget build(BuildContext context) {
    //Color backgroundColor = Theme.of(context).cardColor;
    // Color foregroundColor = Theme.of(context).accentColor;
    /*return new FutureBuilder(
        future: _loadImage(),
        builder: (BuildContext context, AsyncSnapshot<Image> image){
          if(image.hasData)
            return image.data;)
        }*/
    geolocatore = Geolocator();

    /*LocationOptions locationOptions =
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);*/
    if (doItOneTime == 0) {
      checkPermission();
      doItOneTime++;
    }

    if (doItOneTime == 1) {
      updateLocation();
      doItOneTime++;
    }

    if (doItOneTime == 2) {
      _getLocation();
      doItOneTime++;
    }

    _handleTap() {
      setState(() {
       // markers.add(
          Marker(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 30,
            width: 30,
            /*LatLng(_position.latitude != null ? _position.latitude : 0,
                _position.longitude != null ? _position.longitude : 0),
            builder: (ctx) => Icon(Icons.pin_drop),*/
         // ),
        );
      });
    }

    _marcalo() {
      markers.add(
        Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: 30,
          width: 30,
          point:
              LatLng(_position.latitude != null ? _position.latitude : 0, -100),
          builder: (ctx) => IconButton(
            icon: Icon(Icons.accessibility_new),
            onPressed: () {
              print(porco);
            },
          ),
        ),
      );
    }

    /*getLatitude() async {
      var latitudine = await _position.latitude;
      return latitudine.toDouble();
    }

    getLongitude() async {
      var longitudine = await _position.longitude;
      return longitudine.toDouble();
    }*/

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: new Column(
            mainAxisSize: MainAxisSize.min,
            children: new List.generate(icons.length, (int index) {
              Widget child = new Container(
                  height: 70.0,
                  width: 56.0,
                  alignment: FractionalOffset.topCenter,
                  child: new ScaleTransition(
                    scale: new CurvedAnimation(
                      parent: _controller,
                      curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                          curve: Curves.easeOut),
                    ),
                    child: new FloatingActionButton(
                        heroTag: null,
                        //backgroundColor: backgroundColor,
                        child: new Icon(
                          icons[index], //color: foregroundColor,
                        ),
                        onPressed: () {
                          if (index == 2 && immagine != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TempImg(immagine),
                                ));
                          } else if (index == 1) {
                            getImage();
                          } else if (index == 0) {
                            updateLocation();
                            print(
                              ('Latitude: ${_position != null ? _position.latitude : '0'} \n'
                                  ' Longitude: ${_position != null ? _position.longitude : '0'}'),
                            );

                            checkPermission();
                            _getLocation();
                            print(_getLocation());
                            print(_position.latitude);
                            print(immagine.path);
                            immagine = null;
                          }
                        }
                        //points[0] = LatLng(_position.latitude, _position.longitude);
                        //print(_position);
                        //print(Geolocator().getCurrentPosition());
                        //9mapController.move(LatLng(37, 150), 5)
                        ),
                  ));
              return child;
            }).toList()
              ..add(
                new FloatingActionButton(
                    child: new AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget child) {
                        return new Transform(
                          transform: new Matrix4.rotationZ(
                              _controller.value * 0.5 * math.pi),
                          alignment: FractionalOffset.center,
                          child: new Icon(_controller.isDismissed
                              ? Icons.add
                              : Icons.close),
                        );
                      },
                    ),
                    onPressed: () {
                      if (_controller.isDismissed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    }
                    //upda))
                    ),
              )),

        //mapController.zoom;
        /* pointIndex++;
          if (pointIndex >= points.length) {
            pointIndex = 0;
          }*/
        // setState((){}); {
        /* markers[0] = Marker(
              point: points[pointIndex],
              anchorPos: AnchorPos.align(AnchorAlign.center),
              height: 30,
              width: 30,
              builder: (ctx) => Icon(Icons.pin_drop),
            );

            // one of this
                            //markers = List.from(markers);
            // markers = [...markers];
            // markers = []..addAll(markers);
          });*/

        body:
            /*Container(
    alignment: Alignment.center,
    child: RaisedButton(
    onPressed: () async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
    context: context, apiKey: kGoogleApiKey);
    //displayPrediction(p);
    },child: */
            FlutterMap(
          options: new MapOptions(
            interactive: true,
            center: new LatLng(
                _position.latitude != null ? _position.latitude : 0,
                _position.longitude != null ? _position.longitude : 0),
            zoom: 5,
            onTap: (l) {
              print('$l');
              _handleTap();
            },
            onPositionChanged: _marcalo(),
            plugins: [
              MarkerClusterPlugin(),
            ],
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate: "https://api.tiles.mapbox.com/v4/"
                  "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'sk.eyJ1IjoibWFzdGVyaGFuZCIsImEiOiJjanlxeTZ0YmYwNTNpM21udXd5NDFqcHViIn0.rp0VYcHg2Og75_fA9Oi7PA',
                'id': 'mapbox.streets',
              },
            ),

            /*
        layers: [
          new TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c']),



            */
            /*[
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),*/

            MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              height: 40,
              width: 40,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: markers,
              polygonOptions: PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              builder: (context, markers) {
                return FloatingActionButton(
                    child: Text(markers.length.toString()), onPressed: null);
              },
            ),
          ],
        ),

        /*bottomNavigationBar: _image != null
            ? Image.file(_image)
            : Text('non ci sono immagini'),*/

        /*drawer: new Drawer(
              child: new Column(children: <Widget>[
            new Expanded(child: new Align(alignment: Alignment.bottomCenter)),
            _image != null
                ? Image.file(_image, fit: BoxFit.contain)
                : Text('non ci sono immagini')
          ]))*/
      ),
    );
  }
}
