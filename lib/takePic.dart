

import 'package:flutter/material.dart';
import 'package:testcamera/sqlite/imageSqlite.dart';
import 'package:testcamera/utils/utils.dart';

import 'model/imageModel.dart';

class TakePicMe extends StatefulWidget {
  final List<ImageModel> images;

  const TakePicMe({Key key, this.images}) : super(key: key);
  @override
  _TakePicMeState createState() => _TakePicMeState();
}

class _TakePicMeState extends State<TakePicMe> {
  DbImage dbImage = new DbImage();
  
  @override
  void initState() {
    super.initState();
    DbImage dbImage;
    //images = [];
    //refreshImages();
  }

  // refreshImages() {
  //   dbImage.getImageList().then((imgs) {
  //     setState(() {
  //       //images.clear();
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
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: GridView.count(
                    scrollDirection: Axis.vertical,
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    children: widget.images.length == null
                        ? Container(
                            child: Text("Kosong"),
                          )
                        : widget.images.map((photo) {
                            return Utils.imageFromBase64String(photo.photoName);
                          }).toList(),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: InkWell(
              //     onTap: () async {
              //       await dbImage.getImageList().then((value) {
              //         //log(value.toString());

              //         images.addAll(value);
              //       });
              //       print('ini list ' + images.toString());
              //     },
              //     child: Container(
              //       child: Text("Show Photo"),
              //     ),
              //   ),
              // ),
            ],
          )),
    );
  }

  // gridView() {
  //   return Padding(
  //     padding: EdgeInsets.all(5.0),
  //     child: GridView.count(
  //       crossAxisCount: 2,
  //       childAspectRatio: 1.0,
  //       mainAxisSpacing: 4.0,
  //       crossAxisSpacing: 4.0,
  //       children: images.length == null
  //           ? Container()
  //           : images.map((photo) {
  //               return Utils.imageFromBase64String(photo.photoName);
  //             }).toList(),
  //     ),
  //   );
  // }
}
