import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:testcamera/takePic.dart';

import 'model/imageModel.dart';
import 'sqlite/imageSqlite.dart';
import 'utils/utils.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<ImageModel> images;
  DbImage dbImage;
  @override
  void initState() {
    super.initState();
    images = [];
    // refreshImages();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  // refreshImages() {
  //   dbImage.getImageList().then((imgs) {
  //     setState(() {
  //       images.clear();
  //       images.addAll(imgs);
  //     });
  //   });
  // }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        //! Provide an onPressed callback.
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            print(path.toString());
            await _controller.takePicture(path);

            Uint8List bytes = File(path).readAsBytesSync();
            print('ini byte ' + bytes.toString());

            String imgString = Utils.base64String(bytes);
            print('ini imgStr' + imgString);

            DateTime now = DateTime.now();

            print('ini tanggal ' + now.toString());
            ImageModel photo =
                new ImageModel( photoName: imgString, date: now.toString());
            DbImage dbImage = new DbImage();

            try {
              dbImage.insertPhoto(photo);

              log(photo.date);
            } catch (e) {
              print(e);
            }
            //print('ini insert db' + photo.toString());

            //refreshImages();
            await dbImage.getImageList().then((value) {
              images.addAll(value);
            });
            //! If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakePicMe(
                  images: images,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      //! The image is stored as a file on the device. Use the `Image.file`
      //! constructor with the given path to display the image.
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

class TakePic extends StatefulWidget {
  final List<ImageModel> images;
  const TakePic({
    Key key,
    this.images,
  }) : super(key: key);

  @override
  _TakePicState createState() => _TakePicState();
}

class _TakePicState extends State<TakePic> {
  // DbImage dbImage;
  @override
  void initState() {
    super.initState();
    // images = [];
    // refreshImages();
  }

  // refreshImages() {
  //   dbImage.getImageList().then((imgs) {
  //     setState(() {
  //       images.clear();
  //       images.addAll(imgs);
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Images List SQL"),
      ),
      body: gridView(),
    );
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: widget.images.map((photo) {
          return Utils.imageFromBase64String(photo.photoName);
        }).toList(),
      ),
    );
  }
}
