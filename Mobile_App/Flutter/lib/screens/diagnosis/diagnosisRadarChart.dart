import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mulcam_final/config/buttons.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:mulcam_final/screens/diagnosis/request.dart';
import 'package:mulcam_final/screens/recommend/recommend.dart';

import 'package:mulcam_final/screens/home.dart';
import 'package:provider/provider.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({Key? key}) : super(key: key);

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  Map mapLocation = {'FH': '앞머리', 'TH': '정수리', 'LH': '옆머리', 'ETC': '기타'};

  List<double> stringToList(value) {
    List<String> _temp = value.substring(1, value.length - 1).split(',');
    List<double> _out = [];
    for (String i in _temp) {
      _out.add(double.parse(i.trim()));
    }
    return _out;
  }

  @override
  Widget build(BuildContext context) {
    // 화면 세로고정
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      appBar: AppBar(
        title: Text('두피 진단 및 처방'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(children: [
          // image columns
          _mycolumns(),
          SizedBox(
            height: 10,
          ),
          // radar chart
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('rec_shampoo')
                  .doc(context.read<Store>().uid)
                  .collection(context.read<Store>().today)
                  .orderBy('index')
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData & !snapshot.data!.docs.isEmpty) {
                  final String scoreString = snapshot.data!.docs.first['value'];
                  final List<double> scoreList = stringToList(scoreString);
                  return Container(
                    color: Colors.white,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: RadarChart.light(
                      ticks: [1, 2, 3],
                      features: [
                        '${snapshot.data!.docs.first['scalp_type']}두피',
                        '탈모',
                        '민감성',
                        '비듬',
                        '두피염'
                      ],
                      data: [scoreList],
                    ),
                  );
                }
                return Container(
                  color: Colors.white,
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: RadarChart.light(
                    ticks: [1, 2, 3],
                    features: ['두피 타입', '탈모', '민감성', '비듬', '두피염'],
                    data: [
                      [0, 0, 0, 0, 0]
                    ],
                  ),
                );
              }),
          // buttons
          Container(
              padding: EdgeInsets.all(40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyElevatedButton2('진단 시작', requestScreen()),
                  ]))
        ]),
      ),
    );
  }

  Row _mycolumns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _myImageRow('FH'),
        _myImageRow('TH'),
        _myImageRow('LH'),
        _myImageRow('ETC')
      ],
    );
  }

  Container _myImageRow(location) {
    return Container(
      height: 145,
      child: Column(
        children: [
          Container(
              height: 45,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.cyan[900],
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Center(
                child: Text(
                  mapLocation[location],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              )),
          SizedBox(height: 15),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('images')
                  .doc(context.read<Store>().uid)
                  .collection(context.read<Store>().today)
                  .where('location', isEqualTo: location)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData & !snapshot.data!.docs.isEmpty) {
                  final imageUrl = snapshot.data!.docs.first['photoUrl'];
                  return Container(
                      child: Image(
                    image: NetworkImage(
                      imageUrl,
                    ),
                    width: 80,
                    height: 80,
                  ));
                }
                return Container(
                  width: 80,
                  height: 80,
                  child: Center(child: Text('image')),
                  decoration: BoxDecoration(border: Border.all(width: 0.5)),
                );
              }),
        ],
      ),
    );
  }
}
