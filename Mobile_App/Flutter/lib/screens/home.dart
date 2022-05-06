import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mulcam_final/config/drawer.dart';
import 'package:mulcam_final/screens/diagnosis/diagnosisRadarChart.dart';
import 'package:mulcam_final/screens/info/info.dart';

import 'package:mulcam_final/screens/history/history.dart';
import 'package:mulcam_final/screens/recommend/recommend.dart';
import 'package:provider/provider.dart';

class _MyOutlinedButton extends StatelessWidget {
  String text;
  Widget destination;

  _MyOutlinedButton(this.text, this.destination);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OutlinedButton(
          child: Text(
            this.text,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
              primary: Colors.black87,
              side: const BorderSide(color: Colors.black87, width: 0.8),
              minimumSize: Size(MediaQuery.of(context).size.width - 60, 100)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return destination;
              },
            ));
          }),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authentication = FirebaseAuth.instance;

  // 유저 등록이 끝나고 화면 이동 후 이메일 표출 -> state 초기화 마다 시행
  @override
  void initState() {
    super.initState();
    context.read<Store>().getName();
    print(context.read<Store>().uid);
    print(context.read<Store>().name);
    print(context.read<Store>().today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        // ignore: prefer_const_literals_to_create_immutables
        title: Column(children: [
          const Image(
            image: AssetImage('images/main.png'),
            width: 150,
            height: 70,
          ),
        ]),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.exit_to_app_sharp,
                size: (28),
              ),
              onPressed: () {
                _authentication.signOut();
                Navigator.pop(context);
              })
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MyOutlinedButton('두피 진단 및 처방', DiagnoseScreen()),
            const SizedBox(height: 25),
            _MyOutlinedButton('두피 경과 관찰', const HistoryScreen()),
            const SizedBox(height: 25),
            _MyOutlinedButton('두피 제품 추천', const shopScreen()),
            const SizedBox(height: 25),
            _MyOutlinedButton('두피 관리 방법 어플사용 방법', infoSlideScreen()),
            // TextButton(onPressed: (){
            //   print(context.read<Store>().name);
            //   print(context.read<Store>().uid);
            //   print(context.read<Store>().today);
            //   context.read<Store>().updateLog();
            // }, child: Text('Text'))
            
          ],
        ),
      ),
    );
  }
}


class Store extends ChangeNotifier{
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var today =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  var name;
  Map mapLocation = {'FH': '앞머리', 'TH': '정수리', 'LH': '옆머리', 'ETC': '기타'};
  
  getName() async{
    var result = await FirebaseFirestore.instance.collection('user').doc(Store().uid).get();
    var resultUid = await FirebaseAuth.instance.currentUser!.uid;
    var resultToday =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    name = result['userName'];
    uid = resultUid;
    today = resultToday;
    notifyListeners();
  }

  updateLog() async {
    var result = await FirebaseFirestore.instance.collection('user').doc(uid).get();
    var updateData = result.data();
    if(updateData!['log'] == null){
      updateData['log'] = [today];
    } else{
      updateData['log'].add(today);
    }
    FirebaseFirestore.instance.collection('user').doc(uid).set(updateData);
  }

  List<double> stringToList(value) {
    List<String> _temp = value.substring(1, value.length - 1).split(',');
    List<double> _out = [];
    for (String i in _temp) {
      _out.add(double.parse(i.trim()));
    }
    return _out;
  }
}