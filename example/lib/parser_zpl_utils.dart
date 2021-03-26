/// @Author: Weisen
/// @Date: 2021-03-25 15:58
/// @Last Modified by: Weisen
/// @Last Modified time: 2021-03-25 15:58
/// @description 自定义标签分为四大部分
/// ^FX<SETTINGS>^FX</SETTINGS> 页头
/// ^FX<BODY> 页内容
///   ^FX<BLOCK>^FX</BLOCK> 动态块
/// ^FX</BODY>
/// ^FX<FOOTER>^FX</FOOTER> 页尾

class Parser {
  static String zpl;
  static ParserZpl settings;
  static ParserZpl header;
  static ParserZpl body;
  static ParserZpl footer;

  static initParser({cmdText, data, Settings options}) {
    zpl = cmdText;

    settings = hasBlock("SETTINGS") ? parserZpl('SETTINGS', cmdText) : null;
    header = hasBlock("HEADER") ? parserZpl("HEADER", cmdText) : null;
    body = hasBlock("BODY") ? parserZpl("BODY", cmdText) : null;
    footer = hasBlock("FOOTER") ? parserZpl("FOOTER", cmdText) : null;
    //
    // String startCmd = "^XA\n";
    // String settingsCmd = settings.zplText;
    // String headerCmd = header.zplText;
    // String bodyCmd = body.zplText;
    // String footerCmd = footer.zplText;
    // String endCmd = "^XZ\n";
    //
    // zpl = startCmd + settingsCmd + headerCmd + bodyCmd + footerCmd + endCmd;

    initData(data);

    return zpl;
  }

  static empty() {}

  static hasBlock(ele) {
    RegExp hasReg = new RegExp(r"\^FX\<" + ele + "");
    return zpl.contains(hasReg);
  }

  static initData(Map data) {
    setAllData(data);
    hasBlock("BLOCK") ? setBodyData(data['item']) : empty();
    hasBlock("FOOTER") ? setFooterData() : empty();
  }

  static setAllData(allData) {
    RegExp dataReg = new RegExp(r"\{\{(.+?)\}\}");

    zpl = zpl.replaceAllMapped(dataReg, (e) {
      int dataS = e.start + 2;
      int dataE = e.end - 2;
      final oldStr = e.input.substring(dataS - 2, dataE + 2);
      final matchStr = e.input.substring(dataS, dataE);
      return "${allData[matchStr] != null ? allData[matchStr] : oldStr}";
    });
  }

  static insert(index, data) {
    RegExp insertReg = new RegExp(r"\^FX\<\/BLOCK\>");
    // print(zpl);

    final insertMap = insertReg.allMatches(zpl).map((e) {
      final matchStr = e.input.substring(e.start, e.end);
      return matchStr;
    }).toSet();
  }

  static setSettings(Settings options) {
    if (options.pagerWidth != null)
      zpl = zpl.replaceAll(RegExp(r"\^PW[0-9]*"), "^PW${options.pagerWidth}");
    if (options.pagerLength != null)
      zpl = zpl.replaceAll(RegExp(r"\^LL[0-9]*"), "^LL${options.pagerLength}");
  }

  static setBodyData(data) {
    List dataList = data;

    int height = body.attrData.height;
    int y = body.attrData.y;

    String bodyCmd = "";
    for (var i = 0; i < dataList.length; i++) {
      Map item = dataList[i];

      String cmdTemp = "";
      item.forEach((key, value) {
        RegExp dataReg = new RegExp(r"\{\{(.+?)\}\}");

        cmdTemp = body.zplText.replaceAllMapped(dataReg, (e) {
          int dataS = e.start + 2;
          int dataE = e.end - 2;
          final oldStr = e.input.substring(dataS - 2, dataE + 2);
          final matchStr = e.input.substring(dataS, dataE);
          final splitStr = matchStr.split("|");
          return "${item[splitStr[1]] != null ? item[splitStr[1]] : oldStr}";
        });

        cmdTemp = setPos(y + (i * height), cmdTemp);
      });
      bodyCmd += cmdTemp;
    }

    body.attrData.height = dataList.length * height;
    body.attrData.y = header.attrData.y + header.attrData.height;

    RegExp bodyRegS = new RegExp(r"(\^FX<BODY(.*)\^FX)|(\^FX<BODY(.*)\n\^FX)");
    RegExp bodyRegE = new RegExp(r"\^FX</BODY>");

    int bodyStrS = bodyRegS.firstMatch(zpl).end - 3;
    int bodyStrE = bodyRegE.firstMatch(zpl).start - 1;

    zpl = zpl.replaceRange(bodyStrS, bodyStrE, bodyCmd);
  }

  static setFooterData() {
    int y = body.attrData.y + body.attrData.height;
    int length = y + footer.attrData.height;

    setAttr("FOOTER", "y", y);

    RegExp footerRegS = new RegExp(r"\^FX<FOOTER");
    RegExp footerRegE = new RegExp(r"\^FX</FOOTER>");

    int footerStrS = footerRegS.firstMatch(zpl).start + 1;
    int footerStrE = footerRegE.firstMatch(zpl).end - 1;

    String footerCmd = setParserZpl("FOOTER", zpl);

    footerCmd = setPos(y - footer.attrData.y, footerCmd);

    zpl = zpl.replaceRange(footerStrS, footerStrE, footerCmd);

    setSettings(Settings(pagerLength: length));
  }

  static setData(key, data) {
    return zpl.replaceAll("{{$key}}", "$data");
  }

  static setAttr(ele, key, value) {
    RegExp attrReg = new RegExp(r"\<" + ele + "\>|(\<" + ele + "(.+?)\>)");

    int attrS = attrReg.firstMatch(zpl).start;
    int attrE = attrReg.firstMatch(zpl).end;

    int attrBlock = ("<$ele>").length;

    String attrText = zpl.substring(attrS + attrBlock, attrE - 1);

    RegExp attrKey = new RegExp(r"" + key + "=(\\w*%?)");

    bool hasAttr = attrText.contains(attrKey);

    if (hasAttr) {
      attrText = attrText.replaceAllMapped(attrKey, (e) {
        final matchStr = e.input.substring(e.start, e.end);
        return "$key=$value";
      });
    } else {
      attrText += " $key=$value";
    }

    String newAttrText = "<$ele $attrText>";

    zpl = zpl.replaceRange(attrS, attrE, newAttrText);
  }

  static setPos(y, String zpl) {
    // 处理文字坐标
    RegExp posReg1 = new RegExp(r"\^FO[0-9]*,[0-9]*");
    String nZpl = zpl;
    nZpl = nZpl.replaceAllMapped(posReg1, (e) {
      final matchStr = e.input.substring(e.start, e.end);
      final splitStr = matchStr.split(',');
      int yPos = int.parse(splitStr[1]);
      int newY = yPos + y;
      return "${splitStr[0]},$newY";
    });

    //TODO: 处理不同二维码大小的坐标
    RegExp posReg2 = new RegExp(r"\^FT[0-9]*,[0-9]*");
    nZpl = nZpl.replaceAllMapped(posReg2, (e) {
      final matchStr = e.input.substring(e.start, e.end);
      final splitStr = matchStr.split(',');
      int yPos = int.parse(splitStr[1]);
      int newY = yPos + y;
      return "${splitStr[0]},$newY";
    });

    return nZpl;
  }

  static setParserZpl(ele, String zpl) {
    RegExp parserRegS = new RegExp(r"\^FX\<" + ele + "");
    RegExp parserRegE = new RegExp(r"\^FX\</" + ele + ">");
    int parserS = parserRegS.firstMatch(zpl).start;
    int parserE = parserRegE.firstMatch(zpl).end;

    String parserText =
        (parserS == -1 || parserE == -1) ? '' : zpl.substring(parserS, parserE);

    return parserText;
  }

  static setZplText(ele, String parserText) {
    RegExp zplRegS = new RegExp(r"\^");
    RegExp zplRegE = new RegExp(r"\^FX\</" + ele + ">");

    final zplStr1 = zplRegS.allMatches(parserText).map((e) => e.end).toSet();

    int zplS = zplStr1.length < 2 ? -1 : zplStr1.elementAt(1) - 1;
    int zplE = zplRegE.firstMatch(parserText).start;

    String zplText =
        (zplS == -1 || zplE == -1) ? '' : parserText.substring(zplS, zplE);

    return zplText;
  }

  static setAttrData(ele, String parserText) {
    RegExp blockRegs = new RegExp(r"\<");
    RegExp blockRegE = new RegExp(r">");

    int attrS = blockRegs.firstMatch(parserText).start;
    int attrE = blockRegE.firstMatch(parserText).end;

    String attrText = (attrS == -1 || attrE == -1)
        ? ''
        : parserText.substring(attrS, attrE) == ("<" + ele + ">")
            ? ''
            : parserText.substring(attrS, attrE);

    int attrBlockS = ("<" + ele + " ").length;
    int attrBlockE = attrBlockS == attrText.length ? -1 : attrText.length - 1;
    String attrValue = (attrBlockS == -1 || attrBlockE == -1)
        ? ''
        : attrText.substring(attrBlockS, attrBlockE);
    List attrList = attrValue != '' ? attrValue.split(" ") : [];

    final attrObj = {};
    attrList.forEach((element) {
      final key = element.split("=")[0];
      final value = element.split("=")[1];
      attrObj[key] = value;
    });

    AttrData attrArr = AttrData.fromJSON(attrObj);

    AttrData attrData = attrList.length != 0 ? attrArr : AttrData();

    return attrData;
  }

  static setAttrText(ele, parserText) {
    RegExp blockRegs = new RegExp(r"\<");
    RegExp blockRegE = new RegExp(r">");

    int attrS = blockRegs.firstMatch(parserText).start;
    int attrE = blockRegE.firstMatch(parserText).end;

    String attrText = (attrS == -1 || attrE == -1)
        ? ''
        : parserText.substring(attrS, attrE) == ("<" + ele + ">")
            ? ''
            : parserText.substring(attrS, attrE);

    return attrText;
  }

  static getTemp(String zpl) {
    RegExp dataReg = new RegExp(r"\{\{(.+?)\}\}");

    final dataMap = dataReg.allMatches(zpl).map((e) {
      int dataS = e.start + 2;
      int dataE = e.end - 2;
      final matchStr = e.input.substring(dataS, dataE);
      return matchStr;
    }).toSet();
    return dataMap;
  }

  static parserZpl(ele, zpl) {
    String parserText = setParserZpl(ele, zpl);

    AttrData attrData = setAttrData(ele, parserText);

    String attrText = setAttrText(ele, parserText);

    String zplText = setZplText(ele, parserText);

    zplText = setPos(-attrData.y, zplText);

    final data = getTemp(zplText);

    return ParserZpl(
      parserText: parserText,
      zplText: zplText,
      attrText: attrText,
      attrData: attrData,
      data: data,
    );
  }
}

class Settings {
  final pagerWidth;
  final pagerLength;

  Settings({
    this.pagerWidth,
    this.pagerLength,
  });
}

class ParserZpl {
  final parserText;
  final zplText;
  final attrText;
  AttrData attrData;
  final data;

  ParserZpl({
    this.parserText,
    this.zplText,
    this.attrText,
    this.attrData,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'parserText': parserText,
        'zplText': zplText,
        'attrText': attrText,
        'attrData': this.attrData.toJson(),
        'data': data,
      };
}

class AttrData {
  int width;
  int height;
  int x;
  int y;
  String id;
  int item;

  AttrData({
    this.width = 0,
    this.height = 0,
    this.x = 0,
    this.y = 0,
    this.id,
    this.item = 0,
  });

  AttrData.fromJSON(Map<dynamic, dynamic> json)
      : width = json['width'] == null ? 0 : int.parse(json['width']),
        height = json['height'] == null ? 0 : int.parse(json['height']),
        x = json['x'] == null ? 0 : int.parse(json['x']),
        y = json['y'] == null ? 0 : int.parse(json['y']),
        id = json['id'],
        item = json['item'] == null ? 0 : int.parse(json['item']);

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'x': x,
        'y': y,
        'id': id,
        'item': item,
      };
}
