import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/services/nt4_client.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

import 'dart:math' as math;


class ReefModel extends MultiTopicNTWidgetModel {
  @override
  String type = ReefWidget.widgetType;

  late NT4Subscription _reefSubscription;
  NT4Subscription get reefSubscription => _reefSubscription;

  String get reefTopic => '$topic/ReefJson';

  @override
  List<NT4Subscription> get subscriptions => [
        reefSubscription,
      ];

  ReefModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    super.dataType,
    super.period,
  }) : super();

  ReefModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required super.jsonData,
  }) : super.fromJson();

  @override
  void initializeSubscriptions() {
    _reefSubscription = ntConnection.subscribe(reefTopic, super.period);
  }
}

class ReefWidget extends NTWidget {
  static const String widgetType = 'Reef';

  const ReefWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    ReefModel model = cast(context.watch<NTWidgetModel>());

    return Center(child:ValueListenableBuilder(
      valueListenable: model.reefSubscription,
        builder: (context,value,child){
          String reefJson = tryCast(value)!;
          Map<String,dynamic> map=jsonDecode(reefJson);
          return CustomPaint(painter: ReefPainter(map));
        }));
  }
}

class ReefPainter extends CustomPainter {
  Map<String, dynamic> reefData;
  ReefPainter(this.reefData);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(2*math.pi/3);
    Paint paint = Paint();
    Path path = createHexagonPath(70);
    drawPathWithStroke(canvas, path, paint, 2, Colors.purple, Colors.black);
    for(int layer=2; layer<=4; layer++) {
      for(int side=0; side<6; side++) {
        colorRect(canvas, paint, layer, side, true, reefData);
        colorRect(canvas, paint, layer, side, false, reefData);
      }
    }
  }

  Offset fromPolar(double radius, double angle) {
    return Offset(radius * math.cos(angle), radius * math.sin(angle));
  }

  void colorRect(Canvas canvas, Paint paint,int layer,int side,bool isLeft,Map<String,dynamic> reefData){
    int branch=isLeft?2*side:(2*side+1);
    String dataStr="Branch $branch L$layer";
    Color color=Colors.grey;
    if(reefData.containsKey(dataStr)){
      String status=reefData[dataStr]!;
      if(status=="Blocked"){
        color=Colors.blue;
      }else if(status=="Open"){
        color=Colors.red;
      }else{
        color=Colors.green;
      }
    }
    double angle=-math.pi/3;
    Offset left=fromPolar(70,angle*side);
    Offset right=fromPolar(70,angle*(side+1));
    Offset mid=(left+right)/2;
    double shift=140.0-layer*35.0;
    Offset shiftOff=fromPolar(shift,angle*(side+1/2));
    Offset shiftOffEnd=fromPolar(shift+35,angle*(side+1/2));
    Path path=Path();
    if(isLeft){
      path.addPolygon([left+shiftOff,left+shiftOffEnd,mid+shiftOffEnd,mid+shiftOff], true);
    }else{
      path.addPolygon([mid+shiftOff,mid+shiftOffEnd,right+shiftOffEnd,right+shiftOff], true);
    }
    drawPathWithStroke(canvas, path, paint, 2, color, Colors.black);
  }

  void drawPathWithStroke(Canvas canvas, Path path, Paint paint, double strokeWidth, Color fillColor, Color strokeColor) {
    paint.style=PaintingStyle.fill;
    paint.color=fillColor;
    canvas.drawPath(path, paint);
    paint.style=PaintingStyle.stroke;
    paint.strokeJoin=StrokeJoin.bevel;
    paint.strokeWidth=strokeWidth;
    paint.color=strokeColor;
    canvas.drawPath(path, paint);
  }
  Path createHexagonPath(double radius) {
    final path = Path();
    var angle = math.pi/3;
    List<Offset> points=[];
    for (int i = 0; i < 6; i++) {
      points.add(fromPolar(radius, angle*i));
    }
    path.addPolygon(points, true);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
