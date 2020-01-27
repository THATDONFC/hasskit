import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:provider/provider.dart';

class EntityControlGeneral extends StatelessWidget {
  final String entityId;

  const EntityControlGeneral({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[entityId].state}" +
          "${generalData.entities[entityId].getFriendlyName}" +
          "${generalData.entities[entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[entityId];
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                entity.mdiIcon,
                size: 200,
                color: ThemeInfo.colorIconActive,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                gd.textToDisplay(entity.getStateDisplayTranslated(context)),
                style: Theme.of(context).textTheme.title,
              ),
            ],
          ),
        );
      },
    );
  }
}
