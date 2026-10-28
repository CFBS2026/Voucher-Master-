import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<void> printVoucherSlip({
    required String wifiName,
    required String voucherCode,
    required String profileName,
    required double price,
  }) async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      bluetooth.printCustom(wifiName, 2, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom("Voucher Code:", 1, 0);
      bluetooth.printCustom(voucherCode, 2, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom("Profile: $profileName", 1, 0);
      bluetooth.printCustom("Price: ${price.toStringAsFixed(0)} Ks", 1, 0);
      bluetooth.printNewLine();
      bluetooth.printCustom("Thank You!", 1, 1);
      // bluetooth.printPaperCut();
    }
  }
}
