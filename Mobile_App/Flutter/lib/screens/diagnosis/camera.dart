import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as Im;

import 'package:mulcam_final/screens/home.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? location;
  var _index = {'FH':0, 'TH':1, 'LH':2, 'ETC':3};

  final picker = ImagePicker();

// 이미지 인터페이스 위젯
  Widget showImage() {
    return Container(
        color: Color(0xffd0cece),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Center(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(File(_image!.path))));
  }

  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource, maxHeight: 224, maxWidth: 224);
    

    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장

    });
    await _uploadFile(
        context, File(image!.path)); // 가져온 이미지를 업로드하기 위해 await을 사용
  }

  Future _uploadFile(BuildContext context, _image) async {
    print(location);

    try {
      // 스토리지에 업로드할 파일 경로
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(context.read<Store>().uid)
          .child('${location}')
          .child(context.read<Store>().today)
          .child('${DateTime.now()}.png');

      // 파일 업로드
      final uploadTask = firebaseStorageRef.putFile(
          _image, SettableMetadata(contentType: 'image/png'));

      // 완료까지 기다림
      await uploadTask.whenComplete(() => null);

      // 업로드 완료 후 url
      final downloadUrl = await firebaseStorageRef.getDownloadURL();

      // 문서 작성
      await FirebaseFirestore.instance
          .collection('images')
          .doc(context.read<Store>().uid)
          .collection(
              '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}')
          .add({
        'userID': context.read<Store>().uid,
        'location': '${location}',
        'datetime': DateTime.now(),
        'photoUrl': downloadUrl,
        'index': _index[location]
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 세로고정
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Text(
                ('앞머리'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[900], minimumSize: Size(70, 50)),
              onPressed: () {
                location = 'FH';
                print(location);
              },
            ),
            ElevatedButton(
              child: Text(
                ('정수리'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[900], minimumSize: Size(70, 50)),
              onPressed: () {
                location = 'TH';
                print(location);
              },
            ),
            ElevatedButton(
              child: Text(
                ('옆머리'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[900], minimumSize: Size(70, 50)),
              onPressed: () {
                location = 'LH';
                print(location);
              },
            ),
            ElevatedButton(
              child: Text(
                ('기타'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[900], minimumSize: Size(70, 50)),
              onPressed: () {
                location = 'ETC';
                print(location);
              },
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        showImage(),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Camera button
            FloatingActionButton(
              backgroundColor: Colors.cyan[900],
              heroTag: 'camera',
              child: Icon(
                Icons.add_a_photo,
              ),
              tooltip: 'pick Image',
              onPressed: () {
                getImage(ImageSource.camera);
              },
            ),
            FloatingActionButton(
              backgroundColor: Colors.cyan[900],
              heroTag: 'gallery',
              child: Icon(Icons.wallpaper),
              tooltip: 'pick Image',
              onPressed: () {
                getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ]),
    );
  }
}
