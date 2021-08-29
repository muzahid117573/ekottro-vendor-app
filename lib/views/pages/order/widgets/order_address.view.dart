import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/list_items/parcel_order_stop.list_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/translations/order_details.i18n.dart';

class OrderAddressView extends StatelessWidget {
  const OrderAddressView(this.vm, {Key key}) : super(key: key);
  final OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //show package delivery addresses
        vm.order.isPackageDelivery
            ? VStack(
                [
                  //pickup location routing
                  ParcelOrderStopListView(
                    "Pickup Location".i18n,
                    vm.order.orderStops.first,
                    canCall: vm.order.canChatCustomer,
                    routeToLocation: vm.routeToLocation,
                  ),

                  //stops
                  ...(vm.order.orderStops.sublist(1).mapIndexed((stop, index) {
                    return ParcelOrderStopListView(
                      "Dropoff Location",
                      stop,
                      canCall: vm.order.canChatCustomer,
                      routeToLocation: vm.routeToLocation,
                    );
                  }).toList()),
                ],
              )
            :
            //regular delivery address
            HStack(
                [
                  VStack(
                    [
                      "Deliver To".i18n.text.gray500.medium.sm.make(),
                      vm.order.deliveryAddress != null
                          ? vm.order.deliveryAddress.name.text.xl.medium.make()
                          : UiSpacer.emptySpace(),
                      vm.order.deliveryAddress != null
                          ? vm.order.deliveryAddress.address.text
                              .make()
                              .pOnly(bottom: Vx.dp20)
                          : UiSpacer.emptySpace(),
                    ],
                  ).expand(),
                  //route
                  vm.order.canChatCustomer && vm.order.deliveryAddress != null
                      ? CustomButton(
                          icon: FlutterIcons.navigation_fea,
                          iconColor: Colors.white,
                          color: AppColor.primaryColor,
                          shapeRadius: Vx.dp20,
                          onPressed: () =>
                              vm.routeToLocation(vm.order.deliveryAddress),
                        ).wh(Vx.dp64, Vx.dp40).p12()
                      : UiSpacer.emptySpace(),
                ],
              ),

        //
        (!vm.order.isPackageDelivery && vm.order.deliveryAddress == null)
            ? "Customer Order Pickup"
                .i18n
                .text
                .xl
                .semiBold
                .make()
                .pOnly(bottom: Vx.dp20)
            : UiSpacer.emptySpace(),
      ],
    );
  }
}
