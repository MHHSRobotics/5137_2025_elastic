import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/services/nt4_client.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';


class ReefScoringModel extends MultiTopicNTWidgetModel {
  @override
  String type = ReefScoringWidget.widgetType;

  late NT4Subscription _reefScoringSubscription;
  NT4Subscription get reefScoringSubscription => _reefScoringSubscription;

  String get reefScoringTopic => '$topic/ScoringJson';

  @override
  List<NT4Subscription> get subscriptions => [
        reefScoringSubscription,
      ];

  ReefScoringModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    super.dataType,
    super.period,
  }) : super();

  ReefScoringModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required super.jsonData,
  }) : super.fromJson();

  @override
  void initializeSubscriptions() {
    _reefScoringSubscription = ntConnection.subscribe(reefScoringTopic, super.period);
  }
}

class ReefScoringWidget extends NTWidget {
  static const String widgetType = 'ReefScoring';

  const ReefScoringWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    ReefScoringModel model = cast(context.watch<NTWidgetModel>());

    return Center(child:ValueListenableBuilder(
      valueListenable: model.reefScoringSubscription,
        builder: (context,value,child){
          String reefScoringJson = tryCast(value)!;
          Map<String,dynamic> map=jsonDecode(reefScoringJson);
          int total=0;
          for (value in map.values){
            int intValue=tryCast(value)!;
            if(intValue>=5){
              total++;
            }
          }
          Color boxColor=(total==4)?Colors.green:(total==3)?Colors.yellow:Colors.red;
          return ColoredBox(
            color:boxColor,
            child:Padding(
            padding: const EdgeInsets.all(10),
            child:ColoredBox(
            color:Colors.black,
            child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                const Text("L4",textScaler:TextScaler.linear(2)),
                Text(map["L4"].toString(),textScaler:const TextScaler.linear(2)),
              ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                const Text("L3",textScaler:TextScaler.linear(2)),
                Text(map["L3"].toString(),textScaler:const TextScaler.linear(2)),
              ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                const Text("L2",textScaler:TextScaler.linear(2)),
                Text(map["L2"].toString(),textScaler:const TextScaler.linear(2)),
              ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                const Text("L1",textScaler:TextScaler.linear(2)),
                Text(map["L1"].toString(),textScaler:const TextScaler.linear(2)),
              ]),
          ]))));
        }));
  }
}