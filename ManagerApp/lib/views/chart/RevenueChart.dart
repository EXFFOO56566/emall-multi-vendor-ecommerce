import 'package:flutter/material.dart' as Material;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class RevenueChart extends StatelessWidget {
  final List<RevenueData> revenueData;
  final bool animate;
  final Material.ThemeData themeData;


  RevenueChart(this.revenueData,this.themeData, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Material.Container(
      child: new charts.TimeSeriesChart(
        _createRevenueData(revenueData),
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

  static List<charts.Series<RevenueData, DateTime>> _createRevenueData(List<RevenueData> data) {


    return [
      new charts.Series<RevenueData, DateTime>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (RevenueData revenueData, _) => revenueData.dateTime,
        measureFn: (RevenueData revenueData, _) => revenueData.revenue,
        data: data,
      )
    ];
  }
}



class RevenueData{
  double revenue;
  DateTime dateTime;
  RevenueData(this.revenue, this.dateTime);
}

