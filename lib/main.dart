import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:root/root.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chaquopy/chaquopy.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  runApp(MaterialApp(
      home: MyApp()
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: MyPage(),
    );
    throw UnimplementedError();
  }

}

class MyPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPage> {
  var prefs = null;
  late var gx = 0;
  late var gy = 0;
  late var dx = 0;
  late var dy = 0;

  @override
  void initState() {
    getProfs();
  }

  getProfs() async {
    var prefs = await SharedPreferences.getInstance();
    print( prefs.getInt('gx') );
    setState(() {
      gx = prefs.getInt('gx')??0;
      gy = prefs.getInt('gy')??0;
      dx = prefs.getInt('dx')??0;
      dy = prefs.getInt('dy')??0;
    });
  }

  setProfs(gx, gy, dx, dy) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('gx', gx);
    prefs.setInt('gy', gy);
    prefs.setInt('dx', dx);
    prefs.setInt('dy', dy);
    print( prefs.getInt('gx') );
  }



  @override
  Widget build(BuildContext context) {
    /// 倒计时的计时器。
    Timer? _timer;
    // IOWebSocketChannel channel = IOWebSocketChannel.connect('ws://127.0.0.1:7912/minitouch');
    // channel.stream.listen((message) {
    //   channel.sink.add('{"operation": "d", "index": 0, "pX": 0.5, "pY": 0.5, "pressure": 50}');
    //   print(message);
    // });
    var navs = [
      { "name": "获取权限" },
      { "name": "点赞和关注的点位采集(测试视频不要点关注)" },
      { "name": "测试请求" },
      { "name": "测试视频页面" },
      { "name": "取消测试" },
      { "name": "启动atx" }
    ];
    List<dynamic> jsonNav = json.decode( json.encode(navs) );
    jsonNav[0]['icon'] = Icons.account_box;
    jsonNav[1]['icon'] = Icons.timelapse;
    jsonNav[2]['icon'] = Icons.photo;
    jsonNav[3]['icon'] = Icons.keyboard_voice;
    jsonNav[4]['icon'] = Icons.book;
    jsonNav[0]['color'] = Colors.green;
    jsonNav[1]['color'] = Colors.orange;
    jsonNav[2]['color'] = Colors.indigoAccent;
    jsonNav[3]['color'] = Colors.cyan;
    jsonNav[4]['color'] = Colors.brown;

    guanzhu() async{
      var device = await Dio().get('http://127.0.0.1:7912/info');
      var udid = device.data["udid"];
      var url = 'http://39.108.162.8:8089/api/point/device?device=$udid';
      var point = await Dio().get(url);

      if( point.data.gx == 0 || point.data.dx == 0){
        await launch('scheme://mtime/goodsDetail');
        Fluttertoast.showToast(msg: '未采集数据');
        _timer?.cancel();
      }

      await Dio().post(
          'http://127.0.0.1:7912/shell',
          data: {'command': 'input tap $point.data.gx $point.data.gy'},
          options: Options(contentType: Headers.formUrlEncodedContentType)
      );

      print('$dx $dy');
      await Dio().post(
          'http://127.0.0.1:7912/shell',
          data: {'command': 'input tap $point.data.dx $point.data.dy'},
          options: Options(contentType: Headers.formUrlEncodedContentType)
      );

    }

    return MaterialApp(
        title: '抖音软件',
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                '抖音软件',
              ),
            ),
            body: Container(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index){
                      return new ListTile(
                        title: Text( jsonNav[index]['name'] ),
                        onTap: () async{
                          print( index );
                          if( index == 0 ){
                            // var deviceInfo = await Dio().get('http://127.0.0.1:7912/proc/list');
                            // print( deviceInfo );
                            var info = await Dio().get('http://127.0.0.1:7912/proc/com.example.douyin/meminfo/all');
                            print( info );
                            await Permission.camera.request();
                            await Permission.storage.request();
                            //await Permission.
                          }
                          if(index == 1){
                            var scheme = 'snssdk1128://aweme/detail/7049298285286280486?refer=web&gd_label=click_wap_profile_bottom&type=need_follow&appParam=&needlaunchlog=1';
                            await launch(scheme);
                            sleep(Duration(seconds: 1));
                            var screen = await Dio().get('http://127.0.0.1:7912/dump/hierarchy');
                            var xml = screen.data['result'];
                            var document = XmlDocument.parse(xml);
                            // print( document );
                            final nodes = document.findAllElements('node');
                            //bounds="[438,72][642,204]
                            var x1=0,y1=0,x2=0,y2=0;

                            nodes.forEach((element) {
                              print( element.attributes[2].value );
                              if( element.attributes[2].value == 'com.ss.android.ugc.aweme:id/dwp' ){
                                var str = element.attributes[17].value.replaceAll("[", "");
                                str = str.replaceAll(']', ',');
                                print( str );
                                var list = str.split(',');
                                print( list[0] );
                                print( list[1] );
                                x1 = int.parse(list[0]) + 10;
                                y1 = int.parse(list[1]) + 10;
                              }
                              if( element.attributes[2].value == 'com.ss.android.ugc.aweme:id/cl4' ){
                                var str = element.attributes[17].value.replaceAll("[", "");
                                str = str.replaceAll(']', ',');
                                var list = str.split(',');
                                x2 = int.parse(list[0]) + 10;
                                y2 = int.parse(list[1]) + 10;
                                print( list[0] );
                                print( list[1] );
                              }
                            });
                            // sleep(Duration(seconds: 2));
                            var device = await Dio().get('http://127.0.0.1:7912/info');
                            var point = HashMap();
                            point['device'] = device.data['udid'];
                            point['gx'] = x1;
                            point['gy'] = y1;
                            point['dx'] = x2;
                            point['dy'] = y2;
                            await Dio().post('http://39.108.162.8:8089/api/point/insert', data: point);

                            await launch('scheme://mtime/goodsDetail');
                            Fluttertoast.showToast(msg: '采集完毕');
                            // var res = await Dio().post(
                            //   'http://127.0.0.1:7912/shell',
                            //   data: {'command': 'input tap 50 250'},
                            //   options: Options(contentType: Headers.formUrlEncodedContentType)
                            // );
                            //print( res );
                            //await Root.exec(cmd: 'screencap -p /sdcard/2.png');
                            //Root.exec(cmd: '/data/local/tmp/atx-agent server -d');

                            // var screen = await Dio().get('http://127.0.0.1:7912/dump/hierarchy');
                            // var xml = screen.data['result'];
                            // var document = XmlDocument.parse(xml);
                            // // print( document );
                            // final nodes = document.findAllElements('node');
                            // nodes.forEach((element) {
                            //   print( element.attributes[5] );
                            // });
                            // print( nodes );
                            // const timeout = const Duration(seconds: 8);
                            // _timer = Timer.periodic(timeout, (timer) async { //callback function
                            //   guanzhu();
                            //   // var screen = await Dio().get('http://127.0.0.1:7912/dump/hierarchy');
                            //   // var xml = screen.data['result'];
                            //   // var document = XmlDocument.parse(xml);
                            //   // // print( document );
                            //   // final nodes = document.findAllElements('node');
                            //   // //bounds="[438,72][642,204]
                            //   // nodes.forEach((element) async {
                            //   //   if( element.attributes[2].value == 'com.ss.android.ugc.aweme:id/dwp' ){
                            //   //     var str = element.attributes[17].value.replaceAll("[", "");
                            //   //     str = str.replaceAll(']', ',');
                            //   //     var list = str.split(',');
                            //   //     print( list[0] );
                            //   //     print( list[1] );
                            //   //     var x = int.parse(list[0]) + 10;
                            //   //     var y = int.parse(list[1]) + 10;
                            //   //     await Dio().post(
                            //   //         'http://127.0.0.1:7912/shell',
                            //   //         data: {'command': 'input tap $x $y'},
                            //   //         options: Options(contentType: Headers.formUrlEncodedContentType)
                            //   //     );
                            //   //   }
                            //   //   if( element.attributes[2].value == 'com.ss.android.ugc.aweme:id/cl4' ){
                            //   //     var str = element.attributes[17].value.replaceAll("[", "");
                            //   //     str = str.replaceAll(']', ',');
                            //   //     var list = str.split(',');
                            //   //     var x = int.parse(list[0]) + 10;
                            //   //     var y = int.parse(list[1]) + 10;
                            //   //     await Dio().post(
                            //   //         'http://127.0.0.1:7912/shell',
                            //   //         data: {'command': 'input tap $x $y'},
                            //   //         options: Options(contentType: Headers.formUrlEncodedContentType)
                            //   //     );
                            //   //   }
                            //   // });
                            //   // Map<String,dynamic> map = Map();
                            //   // map['output']="input tap 438 72";
                            //   // Dio().post('http://127.0.0.1:7912/shell', data: map);
                            //   // await Dio().post(
                            //   //     'http://127.0.0.1:7912/shell',
                            //   //     data: {'command': 'input tap 438 72'},
                            //   //     options: Options(contentType: Headers.formUrlEncodedContentType)
                            //   // );
                            // });
                          }
                          if(index == 2){
                            var dio = await Dio().get('https://www.douyin.com/search/%E5%86%B0%E9%9B%AA%E4%BC%A0%E5%A5%87?publish_time=0&sort_type=0&source=switch_tab&type=video');
                            print( dio );
                          }
                          if( index == 3 ){
                            var dio = await Dio().get("http://39.108.162.8:8089/api/video/status/0");
                            var data = dio.data['data'];
                            var awemeid = data['awemeid'];
                            // var awemeid = '7045556215404924171';
                            if( awemeid == null ){
                              return;
                            }
                            // var scheme = 'snssdk1128://user/profile/72673737181?refer=web&gd_label=click_wap_profile_bottom&type=need_follow&needlaunchlog=1';
                            var scheme = 'snssdk1128://aweme/detail/$awemeid?refer=web&gd_label=click_wap_profile_bottom&type=need_follow&appParam=&needlaunchlog=1';
                            await launch(scheme);
                            sleep(Duration(seconds: 4));
                            //await launch('snssdk1128://user/profile/72673737181?refer=web&gd_label=click_wap_download_follow&type=need_follow&needlaunchlog=1');
                            await Dio().post('http://39.108.162.8:8089/api/video/update/status?status=1&awemeid=$awemeid');
                            var device = await Dio().get('http://127.0.0.1:7912/info');
                            var udid = device.data["udid"];
                            var url = 'http://39.108.162.8:8089/api/point/device?device=$udid';
                            var point = await Dio().get(url);
                            print( point.data['data'] );

                            var gxa = point.data['data']['gx'];
                            var gya = point.data['data']['gy'];
                            var dxa = point.data['data']['dx'];
                            var dya = point.data['data']['dy'];

                            if( gxa == 0 ){
                              await launch('scheme://mtime/goodsDetail');
                              Fluttertoast.showToast(msg: '未采集数据');
                              _timer?.cancel();
                            }

                            await Dio().post(
                                'http://127.0.0.1:7912/shell',
                                data: {'command': 'input tap $gxa $gya'},
                                options: Options(contentType: Headers.formUrlEncodedContentType)
                            );
                            sleep(Duration(seconds: 2));
                            print('$dx $dy');
                            await Dio().post(
                                'http://127.0.0.1:7912/shell',
                                data: {'command': 'input tap $dxa $dya'},
                                options: Options(contentType: Headers.formUrlEncodedContentType)
                            );
                            // const timeout = const Duration(seconds: 8);
                            // _timer = Timer.periodic(timeout, (timer) async { //callback function
                            //   var dio = await Dio().get("http://39.108.162.8:8089/api/video/status/0");
                            //   var data = dio.data['data'];
                            //   var awemeid = data['awemeid'];
                            //   if( awemeid == null ){
                            //     return;
                            //   }
                            //   await launch('snssdk1128://aweme/detail/$awemeid?refer=web&gd_label=click_wap_profile_feature&appParam=&needlaunchlog=1');
                            //   await Dio().post('http://39.108.162.8:8089/api/video/update/status?status=1&awemeid=$awemeid');
                            //   //5s 回调一次
                            //   sleep(Duration(seconds: 1));
                            //   guanzhu();
                            //   print('afterTimer='+DateTime.now().toString());
                            //   // 取消定时器
                            // });
                          }
                          if( index == 4 ){
                            _timer?.cancel();
                          }
                          if( index == 5 ){
                            Root.exec(cmd: '/data/local/tmp/atx-agent server -d');
                          }
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => new Divider(),
                    itemCount: jsonNav.length
                )
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: '设置',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: '我的',
                ),
              ],
              onTap: (index) async {


              },
            )
        )
    );
  }
}