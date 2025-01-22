import 'package:flutter/material.dart';

import '/models/music_api/track.dart';

class ChartPosition extends StatelessWidget {
  final ChartItem chartItem;

  const ChartPosition({super.key, required this.chartItem});
  static const _iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    Widget shift;

    if(chartItem.shift > 0) {
      shift = Icon(Icons.arrow_drop_up, color:Colors.green, size: _iconSize);
    }
    else if(chartItem.shift < 0) {
      shift = Icon(Icons.arrow_drop_down, color:Colors.red, size: _iconSize);
    }
    else {
      shift = const Icon(Icons.remove, color:Colors.grey, size: 14);
    }
    
    return Column(
      children: [Text(chartItem.position.toString()), shift],
    );
  }
}
