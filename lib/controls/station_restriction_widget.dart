import 'package:flutter/material.dart';

import '/models/music_api/station.dart';

class StationOptionWidget extends StatefulWidget {
  final StationRestrictions2 restrictions;
  final String? value;
  final void Function(String value)? onChange;

  const StationOptionWidget({
    super.key,
    required this.restrictions,
    this.value,
    this.onChange
  });

  @override
  State<StationOptionWidget> createState() => _StationOptionWidgetState();
}

class _StationOptionWidgetState extends State<StationOptionWidget> {
  late Set<String> selectedRestriction;

  @override
  void initState() {
    super.initState();
    final String defaultValue = (
        widget.restrictions.possibleValues.where((i) => i.unspecified).firstOrNull
            ?? widget.restrictions.possibleValues.last).value;
    selectedRestriction = <String>{widget.value ?? defaultValue};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(widget.restrictions.name),
        SegmentedButton<String>(
          selected: selectedRestriction,
          showSelectedIcon: false,
          segments: widget.restrictions.possibleValues.map((i) => ButtonSegment(
            value: i.value,
            label: Text(i.name),
          )).toList(),
          onSelectionChanged: (Set<String> value) {
            selectedRestriction = value;
            setState(() {});

            if(widget.onChange != null) {
              widget.onChange!(value.single);
            }
          },
        )
      ],
    );
  }
}
