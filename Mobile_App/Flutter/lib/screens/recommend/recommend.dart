import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mulcam_final/screens/home.dart';
import 'package:provider/provider.dart';

class shopScreen extends StatefulWidget {
  const shopScreen({Key? key}) : super(key: key);

  @override
  State<shopScreen> createState() => _shopScreenState();
}

class _shopScreenState extends State<shopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _selectedPage = 0;
  // var recommends = shampoos;
  final firestore = FirebaseFirestore.instance;

  var itemList = [];
  var recommends;
  var shampoos = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
  var serums = [{}, {}, {}, {}, {}];

  _getData() async {
    var result = await firestore
        .collection('rec_shampoo')
        .doc(context.read<Store>().uid)
        .collection(context.read<Store>().today)
        .orderBy('index', descending: true)
        .get();
    print(result.docs[0]['recommend']);
    setState(() {
      for (var i = 0; i < 10; i++) {
        shampoos[i]['name'] = result.docs[i]['recommend'][1];
        shampoos[i]['keywords'] = result.docs[i]['recommend'][2];
        shampoos[i]['price'] = result.docs[i]['recommend'][3];
        shampoos[i]['rate'] = result.docs[i]['recommend'][4];
        shampoos[i]['opinion'] = result.docs[i]['recommend'][5];
        shampoos[i]['imageUrl'] = result.docs[i]['recommend'][6];
      }
    });

    var result2 = await firestore
        .collection('rec_serum')
        .doc(context.read<Store>().uid)
        .collection(context.read<Store>().today)
        .orderBy('index', descending: false)
        .get();
    print(result.docs[0]['recommend']);
    setState(() {
      for (var i = 0; i < 5; i++) {
        serums[i]['name'] = result2.docs[i]['recommend'][0];
        serums[i]['keywords'] = result2.docs[i]['recommend'][1];
        serums[i]['price'] = result2.docs[i]['recommend'][2];
        serums[i]['rate'] = result2.docs[i]['recommend'][3];
        serums[i]['opinion'] = result2.docs[i]['recommend'][4];
        serums[i]['imageUrl'] = result2.docs[i]['recommend'][5];
      }
    });
  }

  _plantSelector(recommends, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 500.0,
            width: Curves.easeInOut.transform(value) * 400.0,
            child: widget,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Colors.black26),
                borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 30),
            padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Hero(
                    tag: recommends[index]['imageUrl'],
                    child: Image(
                      height: 200,
                      width: 200,
                      image: NetworkImage(recommends[index]['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  recommends[index]['name'],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${recommends[index]['price']}',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Rates: ${recommends[index]['rate']}',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Opinions: ${recommends[index]['opinion']}',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 1,
            child: RawMaterialButton(
              padding: EdgeInsets.all(15),
              shape: CircleBorder(),
              elevation: 2,
              fillColor: Colors.black,
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () async {
                print('Add to cart.');
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
    _getData();
    itemList = [shampoos, serums];
    recommends = itemList[_tabController.index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 45,
            foregroundColor: Colors.white,
            backgroundColor: Colors.cyan[400],
            elevation: 0,
            centerTitle: true,
            title: Text(
              '추천제품',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          children: <Widget>[
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.withOpacity(0.6),
              labelPadding: EdgeInsets.symmetric(horizontal: 35.0),
              isScrollable: true,
              onTap: (i) {
                setState(() {
                  recommends = itemList[_tabController.index];
                  _pageController.jumpTo(0);
                });
              },
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'Shampoo',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Serum',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // PageView
            Container(
              height: 410,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedPage = index;
                  });
                },
                itemCount: recommends.length,
                itemBuilder: (BuildContext context, int index) {
                  try {
                    return _plantSelector(recommends, index);
                  } catch (e) {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            // Keywords
            Builder(builder: (context) {
              try {
                return Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Keywords',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(recommends[_selectedPage]['keywords']
                          .replaceAll("', '", '\t\t'))
                    ],
                  ),
                );
              } catch (e) {
                return Text('준비중');
              }
            })
          ],
        ));
  }
}
