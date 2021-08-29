import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/translations/general.i18n.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderPrinterSelector extends StatefulWidget {
  OrderPrinterSelector(this.order, {Key key}) : super(key: key);
  final Order order;

  @override
  _OrderPrinterSelectorState createState() => _OrderPrinterSelectorState();
}

class _OrderPrinterSelectorState extends State<OrderPrinterSelector> {
  //START ORDER PRINTING STUFFS
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _selectedDevice;
  bool _deviceConnected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (error) {
      print("Devices search error ==> $error");
    }

    if (!mounted) return;

    try {
      setState(() {
        _devices = devices;
      });
    } catch (error) {
      print("Error ==> $error");
    }
  }

  ///view
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        "Select Printer".i18n.text.semiBold.xl2.make(),
        UiSpacer.verticalSpace(),
        //printers
        _devices.isNotEmpty
            ? CustomListView(
                dataSet: _devices,
                itemBuilder: (context, index) {
                  //
                  final currentDevice = _devices[index];
                  return HStack(
                    [
                      VStack(
                        [
                          currentDevice.name.text.make(),
                          currentDevice.address.text.xs.make(),
                        ],
                      ).expand(),
                      (_selectedDevice != null &&
                              currentDevice.address == _selectedDevice.address)
                          ? Icon(
                              FlutterIcons.check_ant,
                              color: Colors.green,
                            )
                          : UiSpacer.emptySpace(),
                    ],
                  ).py12().px8().onInkTap(() async {
                    await _disconnect();
                    setState(() {
                      _selectedDevice = currentDevice;
                    });
                    _connect();
                  });
                },
                separatorBuilder: (context, index) => UiSpacer.emptySpace(),
              ).expand()
            : ('Ops something went wrong!. Please check that your bluetooth is ON')
                .i18n
                .text
                .xl
                .makeCentered(),

        //
        UiSpacer.verticalSpace(),
        CustomButton(
          title: "Print".i18n,
          onPressed: _deviceConnected
              ? () {
                  _tesPrint();
                }
              : null,
        )
      ],
    ).p20();
  }

//for connecting to selected bluetooth device
  void _connect() {
    if (_selectedDevice == null) {
      context.showToast(msg: 'No device selected.', bgColor: Colors.red);
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_selectedDevice).then((value) {
            setState(() {
              _deviceConnected = value ?? false;
            });
          }).catchError((error) {
            setState(() {
              _deviceConnected = false;
            });
          });
        } else {
          setState(() {
            _deviceConnected = isConnected;
          });
        }
      });
    }
  }

  //disconnect from device
  void _disconnect() async {
    if (await bluetooth.isConnected) {
      await bluetooth.disconnect();
    }
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _tesPrint() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printNewLine();
        bluetooth.printCustom("${widget.order.vendor.name}", 3, 1);
        bluetooth.printCustom("${widget.order.vendor.address}", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("Code", "  ${widget.order.code}", 1);
        bluetooth.printLeftRight(
            "Status", "  ${widget.order.status.allWordsCapitilize()}", 1);
        bluetooth.printLeftRight("Customer", "  ${widget.order.user.name}", 1);
        bluetooth.printNewLine();
        //parcel order
        if (widget.order.isPackageDelivery) {
          //print stops
          widget.order.orderStops.forEachIndexed((index, orderStop) {
            if (index == 0) {
              bluetooth.printCustom("Pickup Address".i18n, 1, 0);
            } else {
              bluetooth.printCustom("Stop".i18n, 1, 0);
            }
            bluetooth.printCustom("${orderStop.deliveryAddress.name}", 2, 0);
            // recipient info
            bluetooth.printLeftRight("Name".i18n, "  ${orderStop.name}", 1);
            bluetooth.printLeftRight("Phone".i18n, "  ${orderStop.phone}", 1);
            bluetooth.printLeftRight("Note".i18n, "  ${orderStop.note}", 1);
            bluetooth.printNewLine();
          });

          //
          bluetooth.printNewLine();
          bluetooth.printCustom("Package Details".i18n, 2, 0);
          bluetooth.printLeftRight(
              "Package Type".i18n, "  ${widget.order.packageType.name}", 1);
          bluetooth.printLeftRight(
              "Width".i18n + "   ", widget.order.width + "cm", 1);
          bluetooth.printLeftRight(
              "Length".i18n + "   ", widget.order.length + "cm", 1);
          bluetooth.printLeftRight(
              "Height".i18n + "   ", widget.order.height + "cm", 1);
          bluetooth.printLeftRight(
              "Weight".i18n + "   ", widget.order.weight + "kg", 1);
        } else {
          bluetooth.printCustom("Delivery Address".i18n, 1, 0);
          bluetooth.printCustom(
              "${widget.order.deliveryAddress != null ? widget.order.deliveryAddress.name : 'Customer Pickup'}",
              2,
              0);

          //
          bluetooth.printNewLine();
          bluetooth.printCustom("Products".i18n, 2, 1);
          //products
          for (var orderProduct in widget.order.orderProducts) {
            //
            bluetooth.printLeftRight(
                "${orderProduct.product.name} x${orderProduct.quantity}",
                "    ${AppStrings.currencySymbol} ${orderProduct.price.numCurrency}",
                1);
            //product options
            if (orderProduct.options != null) {
              bluetooth.printCustom("${orderProduct.options}", 1, 0);
            }
          }
          //
          bluetooth.printNewLine();
          bluetooth.printCustom("Note".i18n, 2, 0);
          bluetooth.printCustom("${widget.order.note}", 1, 0);
        }
        bluetooth.printNewLine();
        bluetooth.printLeftRight(
          "Subtotal".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.subTotal.numCurrency}",
          1,
        );
        bluetooth.printLeftRight(
          "Discount".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.discount.numCurrency}",
          1,
        );
        bluetooth.printLeftRight(
          "Delivery Fee".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.deliveryFee.numCurrency}",
          1,
        );
        bluetooth.printLeftRight(
          "Tax".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.tax.numCurrency}",
          1,
        );
        bluetooth.printLeftRight(
          "Driver Tip".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.tip != null ? widget.order.tip.numCurrency : '0.00'}",
          1,
        );
        bluetooth.printNewLine();
        bluetooth.printLeftRight(
          "Total".i18n,
          "  ${AppStrings.currencySymbol} ${widget.order.total.numCurrency}",
          1,
        );
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("${widget.order.code}", 3, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
        bluetooth.printNewLine();
      }
    });
  }
}
