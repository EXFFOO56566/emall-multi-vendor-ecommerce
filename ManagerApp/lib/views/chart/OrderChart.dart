import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart' as Material;
import 'package:flutter/material.dart';

class OrderChart extends StatelessWidget {
  final List<OrderData> orderData;
  final bool animate;
  final Material.ThemeData themeData;

  OrderChart(this.orderData, this.themeData, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Material.Container(
      child: new charts.TimeSeriesChart(_createRevenueData(orderData),
          animate: animate,
          defaultRenderer:
              new charts.LineRendererConfig(includeArea: true, stacked: true),
          domainAxis: new charts.DateTimeAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                    fontSize: 10,
                    color: charts.Color(
                      r: themeData.colorScheme.onBackground.red,
                      b: themeData.colorScheme.onBackground.blue,
                      g: themeData.colorScheme.onBackground.green,
                    ),
                  ),
                  lineStyle: charts.LineStyleSpec(
                    color: charts.MaterialPalette.gray.shadeDefault,
                  )),
              tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                  day: new charts.TimeFormatterSpec(
                      format: 'M/d', transitionFormat: 'MM/dd/yyyy'))),

          primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                    fontSize: 10,
                    color: charts.Color(
                      r: themeData.colorScheme.onBackground.red,
                      b: themeData.colorScheme.onBackground.blue,
                      g: themeData.colorScheme.onBackground.green,
                    ),
                  ),
                  lineStyle: charts.LineStyleSpec(
                    color: charts.MaterialPalette.gray.shadeDefault,
                  )),),

      ),
    );
  }

  static List<charts.Series<OrderData, DateTime>> _createRevenueData(
      List<OrderData> data) {
    return [
      new charts.Series<OrderData, DateTime>(
        id: 'Order',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrderData orderData, _) => orderData.dateTime,
        measureFn: (OrderData orderData, _) => orderData.order,
        data: data,
      )
    ];
  }
}

class OrderData{
  int order;
  DateTime dateTime;
  OrderData(this.order, this.dateTime);

  @override
  String toString() {
    return 'OrderData{order: $order, dateTime: $dateTime}';
  }
}
