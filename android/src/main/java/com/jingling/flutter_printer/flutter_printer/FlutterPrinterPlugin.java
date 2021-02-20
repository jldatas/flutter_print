package com.jingling.flutter_printer.flutter_printer;

import android.graphics.Bitmap;
import android.view.View;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.dascom.print.PrintCommands.ZPL;
import com.dascom.print.Transmission.Pipe;
import com.dascom.print.Transmission.WifiPipe;
import com.dascom.print.Utils.WifiUtils;

import java.io.UnsupportedEncodingException;

import static com.dascom.print.Utils.Unit.DPI_203.CM;
import static com.dascom.print.Utils.Unit.DPI_203.MM;

/**
 * FlutterPrinterPlugin
 */
public class FlutterPrinterPlugin implements FlutterPlugin, MethodCallHandler {

    protected WifiUtils wifiUtils;
    protected Pipe pipe;
    private ZPL smartPrint;

    private MethodChannel channel;

    public final static String Dascom = "http://www.dascom.cn/front/web/";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_printer");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("connectWifi")) {
            result.success("连接WIFI中");
            String ip = call.argument("ip");
            Integer port = call.argument("port");
            connectWifi(ip, port);
        } else if (call.method.equals("disconnect")) {
            result.success("断开WIFI中");
            disconnect();
        } else if (call.method.equals("codeQR")) {
            result.success("打印二维码");
            Integer labelWidth = call.argument("labelWidth");
            Integer labelLength = call.argument("labelLength");
            Integer row = call.argument("row");
            Integer col = call.argument("col");
            Integer size = call.argument("size");
            String labelC = call.argument("label");
            char label = labelC.charAt(0);
            String text = call.argument("text");
            codeQR(labelWidth, labelLength, row, col, size, label, text);
        } else if (call.method.equals("code128")) {
            result.success("打印一维码");
            Integer labelWidth = call.argument("labelWidth");
            Integer labelLength = call.argument("labelLength");
            Integer row = call.argument("row");
            Integer col = call.argument("col");
            boolean bottom = call.argument("bottom");
            boolean top = call.argument("top");
            String text = call.argument("text");
            code128(labelWidth, labelLength, row, col, bottom, top, text);
        } else if (call.method.equals("text")) {
            result.success("打印中");
            Integer labelWidth = call.argument("labelWidth");
            Integer labelLength = call.argument("labelLength");
            Integer row = call.argument("row");
            Integer col = call.argument("col");
            Integer textWidth = call.argument("textWidth");
            Integer textHeight = call.argument("textHeight");
            String text1 = call.argument("text");
            text(labelWidth, labelLength, row, col, textWidth, textHeight, text1);
        } else if (call.method.equals("runCmd")) {
            result.success("打印中");
            String text = call.argument("text");
            runCmd(text);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    public void Pipe(Pipe pipe) {
        smartPrint = new ZPL(pipe);
    }


    public void jump(View view) {

        wifiUtils.jumpToWifiSetting();
    }

    public void connectWifi(String etIP, Integer port) {
        if (pipe != null) {
            pipe.close();
            pipe = null;
        }
        new Thread(() -> {
            try {
                pipe = new WifiPipe(etIP, port);//连接
                Pipe(pipe);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    public void disconnect() {
        if (pipe != null) {
            pipe.close();
            pipe = null;
        }
    }

    protected void printBitmap(Bitmap bitmap) {
        if (pipe == null || !pipe.isConnected()) {
            return;
        }
        new Thread(() -> {
            smartPrint.setLabelStart();
            smartPrint.setLabelWidth(bitmap.getWidth());
            smartPrint.setLabelLength(bitmap.getHeight());
            //打印图片
            smartPrint.printBitmap(0, 0, bitmap);
            boolean b = smartPrint.setLabelEnd();
        }).start();
    }

    byte[] cCException(String var1) {
        try {
            return var1.getBytes("GB2312"); //GB18030
        } catch (UnsupportedEncodingException var3) {
            var3.printStackTrace();
            return new byte[0];
        }
    }

    boolean Print_Send(byte[] var1) {
        return this.pipe.send(var1, 0, var1.length);
    }

    public boolean printTextTTF(int var1, int var2, int var3, int var4, String var5) {
        if (var1 >= 0 && var1 <= 32000 && var2 >= 0 && var2 <= 32000) {
            if (var3 >= 10 && var3 <= 3200 && var4 >= 10 && var4 <= 3200) {
                var2 += var3 / 12;
//                String var6 = "^LH0,0^MMT^FO" + var1 + "," + var2 + ",0^A0," + var3 + "," + var4 + "^CI17^F8^FD" + var5 + "^FS";
                String var6 = "^XA\n" +
                        "\n" +
                        "^CI26  //ASCII Transparency和多字节亚洲编码\n" +
                        "^SEE:GB18030.DAT  //码表\n" +
                        "^CW1,E:SIMSUN.FNT  //字体（宋体）\n" +
                        "\n" +
                        "^FO" + var1 + "," + var2 + ",20^A1N," + var3 + "," + var4 + "^FD" + var5 + "^FS" +
                        "^XZ";
                return this.Print_Send(this.cCException(var6));
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public boolean printCmd(String text) {
        return this.Print_Send(this.cCException(text));
    }

    public void runCmd(String text) {
        if (pipe == null || !pipe.isConnected()) {
//            Toast("请先连接打印机");
            return;
        }

        new Thread(() -> {
            smartPrint.setLabelStart();
            smartPrint.setLabelWidth(75 * MM);
            printCmd(text);
            smartPrint.setLabelEnd();
        }).start();
    }

    /**
     * 文字打印
     * 大小和纠错对应关系，
     * [3,L],[5,Q],[7,M],[10,H]
     *
     * @param row        横向距离
     * @param col        纵向距离
     * @param textWidth  二维码大小
     * @param textHeight 二维码纠错级别
     * @param text       二维码内容
     */
    public void text(int labelWidth, int labelLength, int row, int col, int textWidth, int textHeight, String text) {
        if (pipe == null || !pipe.isConnected()) {
//            Toast("请先连接打印机");
            return;
        }

        new Thread(() -> {

            smartPrint.setLabelStart();
//            smartPrint.setLabelWidth(75 * MM);
//            smartPrint.setLabelLength((int) (4 * CM));
            printTextTTF(row, col, textWidth, textHeight, text);
            smartPrint.setLabelEnd();

//            boolean b = smartPrint.setLabelEnd();

//            Toast(b ? "发送成功" : "发送失败");

        }).start();
    }

    /**
     * 一维码打印
     * 大小和纠错对应关系，
     * [3,L],[5,Q],[7,M],[10,H]
     *
     * @param row    横向距离
     * @param col    纵向距离
     * @param bottom 二维码大小
     * @param top    二维码纠错级别
     * @param text   二维码内容
     */
    public void code128(int labelWidth, int labelLength, int row, int col, boolean bottom, boolean top, String text) {
        if (pipe == null || !pipe.isConnected()) {
//            Toast("请先连接打印机");
            return;
        }
        new Thread(() -> {
            smartPrint.setLabelStart();
            smartPrint.setLabelWidth(labelWidth);
            smartPrint.setLabelLength(labelLength);
            smartPrint.printCode128(row, col, CM, bottom, top, text);
            smartPrint.setLabelEnd();

//            Toast(b ? "发送成功" : "发送失败");

        }).start();
    }


    /**
     * 二维码打印
     * 大小和纠错对应关系，
     * [3,L],[5,Q],[7,M],[10,H]
     *
     * @param row   横向距离
     * @param col   纵向距离
     * @param size  二维码大小
     * @param label 二维码纠错级别
     * @param text  二维码内容
     */
    public void codeQR(int labelWidth, int labelLength, int row, int col, int size, char label, String text) {
        if (pipe == null || !pipe.isConnected()) {
//            Toast("请先连接打印机");
            return;
        }
        new Thread(() -> {
            smartPrint.setLabelStart();
            smartPrint.setLabelWidth(labelWidth);
            smartPrint.setLabelLength(labelLength);
            smartPrint.printQRCode(row, col, size, label, text);
            smartPrint.setLabelEnd();

//            Toast(b ? "发送成功" : "发送失败");

        }).start();
    }
}
