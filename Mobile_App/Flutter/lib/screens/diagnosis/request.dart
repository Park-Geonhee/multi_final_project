// import 'dart:html';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mulcam_final/config/buttons.dart';
import 'package:mulcam_final/screens/diagnosis/camera.dart';

import 'package:mulcam_final/screens/home.dart';
import 'package:provider/provider.dart';

class requestScreen extends StatefulWidget {
  const requestScreen({Key? key}) : super(key: key);

  @override
  State<requestScreen> createState() => _requestScreenState();
}

class _requestScreenState extends State<requestScreen> {
  var _headers = ['앞머리', '정수리', '옆머리', '기타'];
  var imgUrl =
      'https://firebasestorage.googleapis.com/v0/b/mulcam-final.appspot.com/o/etc%2Fmain.png?alt=media&token=7cdfc983-bd19-48f4-b443-b8e96548dc1c';

  requestTodayImages(listUrl, listDocs, location) async {
    var images = await FirebaseFirestore.instance
        .collection('images')
        .doc(context.read<Store>().uid)
        .collection(context.read<Store>().today)
        .where('location', isEqualTo: location)
        .get();
    var imagesDocs = images.docs.getRange(0, images.docs.length);
    var imagesUrl = imagesDocs.map((x) => x['photoUrl']).toList();

    var images2 = await FirebaseFirestore.instance
        .collection('images')
        .doc(context.read<Store>().uid)
        .collection(context.read<Store>().today);

    print(imagesUrl.length);
    listUrl.addAll({location: imagesUrl});
    listDocs.addAll({location: imagesDocs.first.id});
  }

  saveRecommend(value, recommend, scalp_type, flag) {
    int cnt = 0;
    var name = ['rec_shampoo', 'rec_serum'];
    print(name[flag]);
    for (List rec in recommend.sublist(0, recommend.length)) {
      print(cnt);
      print(rec);
      FirebaseFirestore.instance
          .collection(name[flag])
          .doc(context.read<Store>().uid)
          .collection(context.read<Store>().today)
          .add({
        'index': cnt,
        'userID': context.read<Store>().uid,
        'date': context.read<Store>().today,
        'datetime': DateTime.now(),
        'scalp_type': scalp_type,
        'recommend': FieldValue.arrayUnion(rec),
        'value': value.toString()
      });
      cnt += 1;
    }
  }

  Future _uploadFile(BuildContext context, _image, location, listPath) async {
    try {
      // 스토리지에 업로드할 파일 경로
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('new_images')
          .child(context.read<Store>().uid)
          .child('${location}')
          .child(context.read<Store>().today)
          .child('${DateTime.now()}.png');

      // 파일 업로드
      final uploadTask = firebaseStorageRef.putData(
          _image, SettableMetadata(contentType: 'image/png'));

      // 완료까지 기다림
      await uploadTask.whenComplete(() => null);
      // 업로드 완료 후 url
      final downloadUrl = await firebaseStorageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('images')
          .doc(context.read<Store>().uid)
          .collection(context.read<Store>().today)
          .doc(listPath)
          .update({'photoUrl': downloadUrl});
    } catch (e) {
      print(e);
    }
  }

  postRequest() async {
    Map toFastAPI = {};
    Map listImagePath = {};

    await requestTodayImages(toFastAPI, listImagePath, 'FH');
    await requestTodayImages(toFastAPI, listImagePath, 'TH');
    await requestTodayImages(toFastAPI, listImagePath, 'LH');
    await requestTodayImages(toFastAPI, listImagePath, 'ETC');

    final survey = await FirebaseFirestore.instance
        .collection('survey')
        .doc(context.read<Store>().uid)
        .get();
    toFastAPI.addAll({'survey': survey.data()});
    print(toFastAPI.keys);
    print(toFastAPI);

    Uri url = Uri.parse('http://d525-124-197-134-110.ngrok.io/test');
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }, // this header is essential to send json data
      body: jsonEncode([toFastAPI]),
    );
    String responseBody = utf8.decode(response.bodyBytes);
    print("statusCode: ${response.statusCode}");
    print("responseHeaders: ${response.headers}");
    print("responseBody: ${responseBody}");

    Map<String, dynamic> modelResult = jsonDecode(responseBody);
    print(modelResult.keys);
    List value = modelResult['value'];
    List recommend_shampoo = modelResult['recommend'];
    List recommend_serum = modelResult['recommend_serum'];
    String scalp_type = modelResult['scalp_type'];
    String image_FH = modelResult['image_FH'];
    String image_TH = modelResult['image_TH'];
    String image_LH = modelResult['image_LH'];
    String image_ETC = modelResult['image_ETC'];
    print(recommend_shampoo);
    print(recommend_serum);
    saveRecommend(value, recommend_shampoo, scalp_type, 0);
    saveRecommend(value, recommend_serum, scalp_type, 1);
    await _uploadFile(
        context, base64Decode(image_FH), 'FH', listImagePath['FH']);
    await _uploadFile(
        context, base64Decode(image_TH), 'TH', listImagePath['TH']);
    await _uploadFile(
        context, base64Decode(image_LH), 'LH', listImagePath['LH']);
    await _uploadFile(
        context, base64Decode(image_ETC), 'ETC', listImagePath['ETC']);
    context.read<Store>().updateLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '촬영사진 진단',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ),
        body: Container(
            child: Scrollbar(
          thickness: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('images')
                          .doc(context.read<Store>().uid)
                          .collection(context.read<Store>().today)
                          .orderBy('index')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final imageDocs = snapshot.data!.docs;
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty || snapshot.data!.docs.length != 4) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.7,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0),
                            itemBuilder: (context, index) => Card(
                                  margin: const EdgeInsets.all(4),
                                  elevation: 8,
                                  child: GridTile(
                                      header: GridTileBar(
                                        backgroundColor: Colors.cyan[900],
                                        title: Text(_headers[index]),
                                      ),
                                      child: ClipRRect(
                                        child: Text('비어있음'),
                                      )),
                                ));
                        }
                        return GridView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.7,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0),
                            itemBuilder: (context, index) => Card(
                                  margin: const EdgeInsets.all(4),
                                  elevation: 8,
                                  child: GridTile(
                                      header: GridTileBar(
                                        backgroundColor: Colors.cyan[900],
                                        title: Text(_headers[index]),
                                      ),
                                      child: ClipRRect(
                                        child: Image(
                                            image: NetworkImage(
                                                imageDocs[index]['photoUrl']),
                                            fit: BoxFit.fitWidth),
                                      )),
                                ));
                      }),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              child: Text(
                                '사진 선택',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.cyan[900],
                                  minimumSize: Size(70, 50)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return CameraScreen();
                                  },
                                ));
                              },
                            ),
                            ElevatedButton(
                              child: Text(
                                '서버 전송',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.cyan[900],
                                  minimumSize: Size(70, 50)),
                              onPressed: () {
                                postRequest();
                              },
                            ),
                            
                          ]))
                ],
              ),
            ),
          ),
        )));
  }
}
