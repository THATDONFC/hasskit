import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';

class TemperatureDropdownButton extends StatefulWidget {
  final int roomIndex;
  const TemperatureDropdownButton({@required this.roomIndex});

  @override
  _TemperatureDropdownButtonState createState() =>
      _TemperatureDropdownButtonState();
}

class _TemperatureDropdownButtonState extends State<TemperatureDropdownButton> {
  @override
  Widget build(BuildContext context) {
    String selectedValue = "";
    if (gd.roomList[widget.roomIndex].tempEntityId != null &&
        gd.roomList[widget.roomIndex].tempEntityId != "" &&
        gd.roomList[widget.roomIndex].tempEntityId != "null" &&
        gd.entities[gd.roomList[widget.roomIndex].tempEntityId] != null) {
      selectedValue = gd.roomList[widget.roomIndex].tempEntityId;
    }

    List<DropdownMenuItem<String>> dropdownMenuItems = [];
    List<String> entitiyIds = [];
    var clearDropdown = DropdownMenuItem<String>(
      value: "",
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
        title: Text(
          gd.textToDisplay("Clear"),
          style: Theme.of(context).textTheme.bodyText2,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
        trailing: Text(
          "",
          style: Theme.of(context).textTheme.bodyText2,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
      ),
    );
    dropdownMenuItems.add(clearDropdown);

    List<Entity> entities = gd.entities.values
        .where((e) =>
            (e.unitOfMeasurement == "°F" || e.unitOfMeasurement == "°C") &&
            double.tryParse(e.state) != null)
        .toList();
    entities.sort((a, b) => gd
        .textToDisplay(a.getOverrideName)
        .compareTo(gd.textToDisplay(b.getOverrideName)));

    for (Entity entity in entities) {
      var dropdownMenuItem = DropdownMenuItem<String>(
        value: entity.entityId,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
          title: Text(
            gd.textToDisplay("${entity.getFriendlyName}"),
            style: Theme.of(context).textTheme.bodyText2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
          trailing: Text(
            "${double.parse(entity.state).toStringAsFixed(1)} ${entity.unitOfMeasurement.trim()}",
            style: Theme.of(context).textTheme.bodyText2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
        ),
      );

//      print(
//          "selectedValue $selectedValue dropdownMenuItems.add ${entity.entityId} ${entity.getFriendlyName}");
      if (!entitiyIds.contains(entity.entityId)) {
        dropdownMenuItems.add(dropdownMenuItem);
        entitiyIds.add(entity.entityId);
      }
    }

    if (!entitiyIds.contains(selectedValue)) selectedValue = "";
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${gd.roomList[widget.roomIndex].name} Temperature",
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                DropdownButton<String>(
                  underline: Container(),
                  isExpanded: true,
                  value: selectedValue,
                  items: dropdownMenuItems,
                  onChanged: (String newValue) {
                    setState(() {
                      gd.delayCancelEditModeTimer(300);
                      gd.roomList[widget.roomIndex].tempEntityId = newValue;
                    });
                    gd.roomListSave(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
