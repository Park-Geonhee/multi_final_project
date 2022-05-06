import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

import 'package:mulcam_final/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var date = [];
  var values = [];

  @override
  void initState() {
    super.initState();
    getLog();
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('두피 경과 관찰'),
      ),
      body: Container(
        child: Scrollbar(
          thickness: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    '${context.read<Store>().name}님의 관리 프로그램 ${date.length}주차 입니다.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                  height: 150,
                  child: _timelines(),
                ),
                // Radar chart
                _RadarChart(context),
                Positioned(
                    top: 30,
                    right: 30,
                    width: 100,
                    child: Image.asset('./images/label.PNG', width: 300,)),
                SizedBox(height: 50,),
                // Pictures
                _myColumns()
              ]),
            ),
          ),
        ),
      ),
    );
  }

  FixedTimeline _timelines() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connectedFromStyle(
        contentsAlign: ContentsAlign.basic,
        oppositeContentsBuilder: (context, index) {
          if (index == 1) {
            return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '중간점검',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ));
          } else if (index == 3) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '최종점검',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ));
          }
        },
        contentsBuilder: (context, index) => Padding(
          padding: const EdgeInsets.fromLTRB(26, 5, 24, 5),
          child: Text('${index + 1}주차'),
        ),
        connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
        firstConnectorStyle: ConnectorStyle.transparent,
        lastConnectorStyle: ConnectorStyle.transparent,
        // indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
        indicatorStyleBuilder: (context, index) {
          // var week = 3 - date.length;
          if (index == date.length - 1) {
            return IndicatorStyle.dot;
          } else {
            return IndicatorStyle.outlined;
          }
        },
        itemCount: 4,
      ),
      direction: Axis.horizontal,
    );
  }

  _RadarChart(BuildContext context) {
    return Builder(builder: (context) {
      try {
        List<List<num>> _input = values.cast();
        return Column(
          children: [
            Container(
              color: Colors.white,
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: RadarChart.light(
                ticks: [1, 2, 3],
                features: [
                  // '${snapshot.data!.docs.first['scalp_type']}두피',
                  '지성두피',
                  '탈모',
                  '민감성',
                  '비듬',
                  '두피염'
                ],
                data: _input,
              ),
            ),
          ],
        );
      } catch (e) {
        return TextButton(
            onPressed: () {
              print(values);
              print(e);
            },
            child: Text('print'));
      }
    });
  }

  Column _myColumns() {
    try {
      return Column(children: [
        _myRow(date[date.length - 4]),
        _myRow2(date[date.length - 3]),
        _myRow2(date[date.length - 2]),
        _myRow2(date[date.length - 1]),
      ]);
    } catch (e) {
      return Column(
        children: [
          CircularProgressIndicator(),
        ],
      );
    }
  }

  Row _myRow(date) {
    print(date);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _myImageRow('FH', date),
        _myImageRow('TH', date),
        _myImageRow('LH', date),
        _myImageRow('ETC', date)
      ],
    );
  }

  Row _myRow2(date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _myImageRow2('FH', date),
        _myImageRow2('TH', date),
        _myImageRow2('LH', date),
        _myImageRow2('ETC', date)
      ],
    );
  }

  Container _myImageRow(location, date) {
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
                  context.read<Store>().mapLocation[location],
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
                  .collection(date)
                  // .collection(context.read<Store>().today)
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

  Container _myImageRow2(location, date) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 7.5),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('images')
                  .doc(context.read<Store>().uid)
                  .collection(date)
                  // .collection(context.read<Store>().today)
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
          SizedBox(height: 7.5),
        ],
      ),
    );
  }

  getLog() async {
    var firebase = FirebaseFirestore.instance;
    var result =
        await firebase.collection('user').doc(context.read<Store>().uid).get();

    setState(() {
      date = result.data()!['log'];
    });

    var result2 = [];
    for (var i = 0; i < date.length; i++) {
      var value = await firebase
          .collection('rec_shampoo')
          .doc(context.read<Store>().uid)
          .collection(date[i])
          .get();

      var value_ =
          context.read<Store>().stringToList(value.docs.first.data()['value']);
      print(date[i]);
      print(value_);
      result2.add(value_);
    }

    setState(() {
      values = result2;
    });

    print(values);
  }
}
