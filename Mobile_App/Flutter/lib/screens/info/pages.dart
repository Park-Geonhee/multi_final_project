import 'package:flutter/material.dart';
import 'package:mulcam_final/screens/info/survey.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class infoPage1 extends StatelessWidget {
  const infoPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('./images/main.png'),
              height: 80,
              width: 150,
            ),
            SizedBox(height: 20),
            Container(
                child: Text(
              '안녕하세요\n\n두피살려조 두피 관리 프로그램입니다.\n',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class infoPage2 extends StatelessWidget {
  const infoPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('./images/info_1_2.jpg'),
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            Container(
                child: Text(
              '두피살려조 두피 관리 프로그램은\n\nAI 프로그램을 사용해 두피 이미지를 분석하고\n\n두피 상태에 알맞는 두피 제품을 추천하고 있습니다.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class infoPage3 extends StatelessWidget {
  const infoPage3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Image(
              image: AssetImage('./images/info_1_3.jpg'),
              height: 150,
              width: 300,
            ),
            Container(
                child: Text(
              '총 4주 간의 두피 상태를 진단하기 위해\n\n두피를 관찰할 두피현미경, 두피이미지를\n\n준비해주세요.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class infoPage4 extends StatelessWidget {
  const infoPage4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
            ),
            Container(
                height: 300,
                width: 300,
                child: Image(
                  image: AssetImage('./images/info_1_4.jpg'),
                )),
            Container(
                child: Text(
              '촬영 부위는\n\n앞머리/정수리/옆머리 그리고\n\n기타 원하시는 부위를 선택해 촬영해 주세요.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class infoPage5 extends StatelessWidget {
  const infoPage5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Text(
              '프로그램 기간 동안 한 주에 한번\n\n\n두피 사진 업로드는\n\n[메인] - [두피 진단 및 처방] - [사진] - [사진 선택] 에서,\n\n\nAI 진단 시작은\n\n[메인] - [두피 진단 및 처방] - [사진] - [진단 시작] 에서\n\n가능합니다.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class infoPage6 extends StatelessWidget {
  const infoPage6({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: Text(
                '처음 시작하시는 경우\n\n상품 추천을 위한 설문 조사를 시작해 주세요.\n\n감사합니다.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              )),
              SizedBox(height: 30,),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return surveyScreen();
                    }));
                  },
                  child: Text('설문 조사로 가기')),
            ],
          ),
        ));
  }
}
