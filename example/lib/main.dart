import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_printer_example/parser_zpl_utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var ipController = new TextEditingController();
  var portController = new TextEditingController();

  var codeQR1 = new TextEditingController();
  var codeQR2 = new TextEditingController();
  var codeQR3 = new TextEditingController();
  var codeQR4 = new TextEditingController();
  var codeQR5 = new TextEditingController();
  var codeQR6 = new TextEditingController();
  var codeQR7 = new TextEditingController();

  int code128a = 1;
  bool code128b = true;
  var code128c = new TextEditingController();
  var code128d = new TextEditingController();
  var code128e = new TextEditingController();
  var code128f = new TextEditingController();

  String codeQRSize = '3';

  String _platformVersion = 'Unknown';

  String zpl;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    ipController.text = "192.168.3.50";
    portController.text = "9100";

    codeQR1.text = '0';
    codeQR2.text = '0';
    codeQR3.text = '3';
    codeQR4.text = 'L';
    codeQR5.text = 'http://jiutiandata.com/';
    codeQR6.text = '640';
    codeQR7.text = '160';

    code128c.text = '12345678';
    code128d.text = '0';
    code128e.text = '0';
    code128f.text = '160';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPrinter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future onConnectWifi() async {
    String ip = ipController.text;
    int port = int.parse(portController.text);
    final info = await FlutterPrinter.connectWifi(ip, port);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(info),
    ));
  }

  Future onDisconnect() async {
    final info = await FlutterPrinter.disconnect();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(info),
    ));
  }

  Future onCodeQR() async {
    int labelWidth = int.parse(codeQR6.text);
    int labelLength = int.parse(codeQR7.text);
    int row = int.parse(codeQR1.text);
    int col = int.parse(codeQR2.text);
    int size = int.parse(codeQRSize);
    String label = codeQR4.text;
    String text = codeQR5.text;
    final info = await FlutterPrinter.codeQR(
        labelWidth, labelLength, row, col, size, label, text);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(info),
    ));
  }

  Future onCode128() async {
    int labelWidth = int.parse(codeQR6.text);
    int labelLength = int.parse(code128f.text);
    int row = int.parse(code128d.text);
    int col = int.parse(code128e.text);
    String text = code128c.text;
    bool bottom = false;
    bool top = false;
    if (code128a == 2) {
      bottom = true;
    } else if (code128a == 3) {
      bottom = true;
      top = true;
    } else {
      bottom = false;
      top = false;
    }

    final info = await FlutterPrinter.code128(
        labelWidth, labelLength, row, col, bottom, top, text);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(info),
    ));
  }

  Future onPrintFace() async {
    // String cmdText = "^XA" +
    //     "" +
    //     "^CI26  //ASCII Transparency和多字节亚洲编码" +
    //     "^SEE:GB18030.DAT  //码表" +
    //     "^CW1,E:SIMSUN.FNT  //字体（宋体）" +
    //     "" +
    //     "^FX 打印顶部收货单合计" +
    //     "^FO250,20^A1N,48,48^FD收货单^FS //打印文字" +
    //     "^FT213,300^BQ2,2,10^A1N,48,48^FDR20200202^FS  //打印二维码" +
    //     "^FO92,338^A1N,36,36^FD数量合计:   34^FS" +
    //     "^FO92,415^A1N,36,36^FD采购单合计:  3^FS" +
    //     "^FO30,492^A0N,24,24^FD............................................................................^FS" +
    //     "^FO30,503^A0N,24,24^FD............................................................................^FS" +
    //     "" +
    //     "^FX 打印单个采购单数量" +
    //     "^FO34,555^A1N,26,26^FD采购单:   PO011801300004^FS" +
    //     "^FT463,610^BQ2,2,4^A1N,24,24^FDR20200202^FS" +
    //     "^FO34,635^A1N,20,20^FD采购数量^FS" +
    //     "^FO244,635^A1N,20,20^FD收货数量^FS" +
    //     "^FO461,635^A1N,20,20^FD待收数量^FS" +
    //     "^FO59,680^A1N,20,20^FD12^FS" +
    //     "^FO268,680^A1N,20,20^FD12^FS" +
    //     "^FO500,680^A1N,20,20^FD12^FSf'/" +
    //     "^FO30,730^A0N,24,24^FD.............................................................................^FS" +
    //     "" +
    //     "^XZ";
    final data = {
      "receipt_number": "FDR20200202",
      "total_quantity": 34,
      "purchase_order_total": 3,
      "item": [
        {
          "sku": "FDR20200001",
          "purchase_number": "PO011801300004",
          "purchase_total": 3,
          "receiving_total": 3,
          "received_total": 0,
        },
        {
          "sku": "FDR20200002",
          "purchase_number": "PO011801300004",
          "purchase_total": 4,
          "receiving_total": 4,
          "received_total": 0,
        },
        {
          "sku": "FDR20200202",
          "purchase_number": "PO011801300004",
          "purchase_total": 24,
          "receiving_total": 24,
          "received_total": 0,
        },
        {
          "sku": "FDR20200202",
          "purchase_number": "PO011801300004",
          "purchase_total": 12,
          "receiving_total": 13,
          "received_total": 1,
        },
      ],
      "operator_name": "张三",
      "print_time": new DateTime.now().toString(),
    };
    String cmdText = "^XA\n" +
        "\n" +
        "^FX<SETTINGS> 设置\n" +
        "^CI26  //ASCII Transparency和多字节亚洲编码\n" +
        "^SEE:GB18030.DAT  //码表\n" +
        "^CW1,E:SIMSUN.FNT  //字体（宋体）\n" +
        "^PW640^LL2010\n" +
        "^FX</SETTINGS>\n" +
        "\n" +
        "^FX<HEADER y=0 height=520> 打印顶部收货单合计\n" +
        "^FO250,20^A1N,48,48^FD收货单^FS //打印文字\n" +
        "^FT213,300^BQ2,2,10^A1N,48,48^{{receipt_number}}^FS  //打印二维码\n" +
        "^FO92,338^A1N,36,36^FD数量合计:   {{total_quantity}}^FS\n" +
        "^FO92,415^A1N,36,36^FD采购单合计:  {{purchase_order_total}}^FS\n" +
        "^FO30,482^A0N,24,24^FD............................................................................^FS\n" +
        "^FO30,493^A0N,24,24^FD............................................................................^FS\n" +
        "^FX</HEADER>\n" +
        "\n" +
        "^FX<BODY item=1 y=520 height=230> 打印单个采购单数量\n" +
        "^FX<BLOCK id=1 height=230>\n" +
        "^FO34,555^A1N,26,26^FD采购单:   {{item|sku}}^FS\n" +
        "^FT463,610^BQ2,2,4^A1N,24,24^{{item|sku}}^FS\n" +
        "^FO34,635^A1N,20,20^FD采购数量^FS\n" +
        "^FO244,635^A1N,20,20^FD收货数量^FS\n" +
        "^FO461,635^A1N,20,20^FD待收数量^FS\n" +
        "^FO59,680^A1N,20,20^FD{{item|purchase_total}}^FS\n" +
        "^FO268,680^A1N,20,20^FD{{item|receiving_total}}^FS\n" +
        "^FO500,680^A1N,20,20^FD{{item|received_total}}^FS\n" +
        "^FO30,710^A0N,24,24^FD.............................................................................^FS\n" +
        "^FX</BLOCK>\n" +
        "^FX</BODY>\n" +
        "\n" +
        "^FX<FOOTER y=760 height=80> 打印操作日志\n" +
        "^FO30,750^A0N,24,24^FD.............................................................................^FS\n" +
        "^FO34,772^A1N,20,20^FD操作人: {{operator_name}}  打印时间: {{print_time}}^FS\n" +
        "^FX</FOOTER>\n" +
        "\n" +
        "^XZ";

    String cmd = Parser.initParser(
      cmdText: cmdText,
      data: data,
    );

    await FlutterPrinter.runCmd(cmd);
  }

  Future onPrintLabel() async {
    final data = {
      "sku": "F0DD00002",
      "product_name_cn": "褐色墨镜 80S",
    };
    String cmdText = "^XA\n" +
        "^FX<SETTINGS>\n" +
        "^CI26  //ASCII Transparency和多字节亚洲编码\n" +
        "^SEE:GB18030.DAT  //码表\n" +
        "^CW1,E:SIMSUN.FNT  //字体（宋体）\n" +
        "^PW400^PL80^LL80\n" +
        "^FX</SETTINGS>\n" +
        "^FX<BODY>\n" +
        "^FT20,80^BQN,2,4^A1N,24,24^FD{{sku}}^FS\n" +
        "^FO120,0^A1N,24,24^FD{{product_name_cn}}^FS\n" +
        "^FO120,30^A1N,24,24^FD{{sku}}^FS\n" +
        "^FO120,60^A1N,24,24^FDMade In China^FS\n" +
        "^FX</BODY>\n" +
        "^XZ";

    String cmd = Parser.initParser(
        cmdText: cmdText,
        data: data,
        options: Settings(
          pagerLength: 80,
        ));
    await FlutterPrinter.runCmd(cmd);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('DP130L 打印机'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text('IP: '),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: ipController,
                    ),
                  ),
                  Text('Port: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: portController,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('标签纸宽度: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: codeQR6,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR1.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  RaisedButton(
                    child: Text('连接WIFI打印机'),
                    onPressed: () => this.onConnectWifi(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('断开WIFI'),
                    onPressed: () => this.onDisconnect(),
                  ),
                ],
              ),
              Row(
                children: [
                  RaisedButton(
                    child: Text('打印样例收货单'),
                    onPressed: () => this.onPrintFace(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('打印样例标签'),
                    onPressed: () => this.onPrintLabel(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('二维码尺寸: '),
                  Expanded(
                    flex: 1,
                    child: DropdownButton(
                      value: codeQRSize,
                      // icon: Icon(Icons.arrow_right),
                      //   value: _warehouseId,
                      //   iconSize: Global.px(80.0),
                      //   iconEnabledColor: AppColors.primaryBackground,
                      // iconDisabledColor: Colors.redAccent.withOpacity(0.7),
                      // underline: Container(height: 0),
                      items: [
                        DropdownMenuItem(
                          child: Text('3'),
                          value: '3',
                        ),
                        DropdownMenuItem(
                          child: Text('5'),
                          value: '5',
                        ),
                        DropdownMenuItem(
                          child: Text('7'),
                          value: '7',
                        ),
                        DropdownMenuItem(
                          child: Text('10'),
                          value: '10',
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          codeQRSize = value;
                          switch (value) {
                            case '3':
                              codeQR4.text = 'L';
                              codeQR7.text = '160';
                              break;
                            case '5':
                              codeQR4.text = 'Q';
                              codeQR7.text = '240';
                              break;
                            case '7':
                              codeQR4.text = 'M';
                              codeQR7.text = '320';
                              break;
                            case '10':
                              codeQR4.text = 'H';
                              codeQR7.text = '400';
                              break;
                            default:
                              codeQR4.text = 'L';
                              codeQR7.text = '480';
                          }
                        });
                        // DataUtils.setWareHouse(_warehouseId);
                      },
                    ),
                  ),
                  Text('高度: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: codeQR7,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR2.text = value;
                        });
                      },
                    ),
                  ),
                  Text('纠错级别: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: codeQR4,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR2.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('横向距离: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: codeQR1,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR1.text = value;
                        });
                      },
                    ),
                  ),
                  Text('纵向距离: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: codeQR2,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR2.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('内容: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: codeQR5,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR4.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  RaisedButton(
                    child: Text('打印二维码'),
                    onPressed: () => this.onCodeQR(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('暂停打印'),
                    // onPressed: () => this.onCodeQR(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('结束打印'),
                    // onPressed: () => this.onCodeQR(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('纸张高度: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: code128f,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR1.text = value;
                        });
                      },
                    ),
                  ),
                  Text('注释:'),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("无"),
                        Radio(
                          value: 1,
                          groupValue: code128a,
                          onChanged: (value) {
                            setState(() {
                              code128a = value;
                              code128e.text = '0';
                            });
                          },
                        ),
                        Text("下"),
                        Radio(
                          value: 2,
                          groupValue: code128a,
                          onChanged: (value) {
                            setState(() {
                              code128a = value;
                              code128e.text = '0';
                            });
                          },
                        ),
                        Text("上"),
                        Radio(
                          value: 3,
                          groupValue: code128a,
                          onChanged: (value) {
                            setState(() {
                              code128a = value;
                              int code128eNum = int.parse(code128e.text);
                              code128eNum += 40;
                              code128e.text = code128eNum.toString();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('横向距离: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: code128d,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR1.text = value;
                        });
                      },
                    ),
                  ),
                  Text('纵向距离: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: code128e,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR2.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('内容: '),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: code128c,
                      onChanged: (value) {
                        this.setState(() {
                          // this.codeQR4.text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  RaisedButton(
                    child: Text('打印一维码'),
                    onPressed: () => this.onCode128(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('暂停打印'),
                    // onPressed: () => this.onCodeQR(),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  RaisedButton(
                    child: Text('结束打印'),
                    // onPressed: () => this.onCodeQR(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
