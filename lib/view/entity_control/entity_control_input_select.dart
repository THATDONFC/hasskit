import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';

class EntityControlInputSelect extends StatefulWidget {
  final String entityId;

  const EntityControlInputSelect({Key key, @required this.entityId})
      : super(key: key);

  @override
  _EntityControlInputSelectState createState() =>
      _EntityControlInputSelectState();
}

class _EntityControlInputSelectState extends State<EntityControlInputSelect> {
  List<DropdownMenuItem<String>> dropdownMenuItems = [];
  List<String> options = [];
  @override
  void initState() {
    super.initState();
    options = gd.entities[widget.entityId].options;
    print(options);
    for (String option in options) {
      var dropdownMenuItem = DropdownMenuItem<String>(
        value: option,
        child: Text(
          gd.textToDisplay("$option"),
//          style: Theme.of(context).textTheme.body1,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
      );
      dropdownMenuItems.add(dropdownMenuItem);
    }
  }

  @override
  Widget build(BuildContext context) {
//    print("${widget.entityId} ${gd.entities[widget.entityId].options}");

    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8)),
        child: DropdownButton<String>(
          underline: Container(),
          isExpanded: true,
          value: gd.entities[widget.entityId].state,
          items: dropdownMenuItems,
          onChanged: (String newValue) {
            setState(() {
              gd.entities[widget.entityId].state = newValue;
              var outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "input_select",
                "service": "select_option",
                "service_data": {
                  "entity_id": widget.entityId,
                  "option": newValue,
                }
              };
              var message = json.encode(outMsg);
              gd.sendSocketMessage(message);
            });
          },
        ),
      ),
    );
  }
}
