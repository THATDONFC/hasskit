import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/model/entity.dart';

class LightEffectSelector extends StatefulWidget {
  final String entityId;
  const LightEffectSelector({@required this.entityId});

  @override
  _LightEffectSelectorState createState() => _LightEffectSelectorState();
}

class _LightEffectSelectorState extends State<LightEffectSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[widget.entityId];
    String effect = entity.effect;
    List<DropdownMenuItem<String>> dropdownMenuItems = [];
    String selectedValue = "none";
    if (entity.isStateOn && effect != null && effect.length > 0)
      selectedValue = effect;

    var emptyDropdownMenuItem = DropdownMenuItem<String>(
      value: "none",
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
        title: Text(
          gd.textToDisplay("No Effect"),
          style: Theme.of(context).textTheme.bodyText2,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
      ),
    );
    dropdownMenuItems.add(emptyDropdownMenuItem);
    for (String effect in entity.effectList) {
      var dropdownMenuItem = DropdownMenuItem<String>(
        value: effect,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
          title: Text(
            gd.textToDisplay("$effect"),
            style: Theme.of(context).textTheme.bodyText2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
        ),
      );
      dropdownMenuItems.add(dropdownMenuItem);
    }

//    print(
//        "dropdownMenuItems ${dropdownMenuItems.length} selectedValue $selectedValue effectList ${entity.effectList}");

    return Column(
      children: <Widget>[
        SizedBox(
          width: 93.75,
          child: dropdownMenuItems.length > 1
              ? DropdownButton<String>(
//          underline: Container(),
                  isExpanded: true,
                  value: selectedValue,
                  items: dropdownMenuItems,
                  onChanged: (String newValue) {
                    setState(() {
                      selectedValue = newValue;
                      var outMsg = {
                        "id": gd.socketId,
                        "type": "call_service",
                        "domain": widget.entityId.split('.').first,
                        "service": "turn_on",
                        "service_data": {
                          "entity_id": widget.entityId,
                          "effect": selectedValue
                        },
                      };
                      var message = jsonEncode(outMsg);
                      gd.sendSocketMessage(message);
                    });
                  },
                )
              : Container(),
        ),
      ],
    );
  }
}
