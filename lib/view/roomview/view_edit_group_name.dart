import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';

class ViewEditGroupName extends StatefulWidget {
  final int roomIndex;
  const ViewEditGroupName({
    Key key,
    @required this.roomIndex,
  }) : super(key: key);

  get entityId => null;

  @override
  _ViewEditGroupNameState createState() => _ViewEditGroupNameState();
}

class _ViewEditGroupNameState extends State<ViewEditGroupName> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller1.text = gd.roomList[widget.roomIndex].row1Name;
    _controller2.text = gd.roomList[widget.roomIndex].row2Name;
    _controller3.text = gd.roomList[widget.roomIndex].row3Name;
    _controller4.text = gd.roomList[widget.roomIndex].row4Name;
  }

  @override
  Widget build(BuildContext context) {
    print("Widget build ViewEditGroupName ${widget.roomIndex}");
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: <Widget>[
              Row(children: [
                Text(
                  "Group Name",
                ),
              ]),
              Row(
                children: [
                  Icon(
                    Icons.looks_one,
                    size: 28,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.edit),
                      ),
                      controller: _controller1,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline6,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() {
                          log.w("onChanged _controller1 ${_controller1.text}");
                          gd.roomList[widget.roomIndex].row1Name =
                              _controller1.text.trim();
                          gd.delayCancelEditModeTimer(300);
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          log.w(
                              "onEditingComplete _controller1 ${_controller1.text}");
                          gd.roomList[widget.roomIndex].row1Name =
                              _controller1.text.trim();
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.looks_two,
                    size: 28,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.edit),
                      ),
                      controller: _controller2,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline6,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() {
                          log.w("onChanged _controller2 ${_controller2.text}");
                          gd.roomList[widget.roomIndex].row2Name =
                              _controller2.text.trim();
                          gd.delayCancelEditModeTimer(300);
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          gd.roomList[widget.roomIndex].row2Name =
                              _controller2.text.trim();
                          log.w(
                              "onEditingComplete _controller2 ${gd.roomList[widget.roomIndex].row2Name}");
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.looks_3,
                    size: 28,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.edit),
                      ),
                      controller: _controller3,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline6,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() {
                          log.w("onChanged _controller3 ${_controller3.text}");
                          gd.roomList[widget.roomIndex].row3Name =
                              _controller3.text.trim();
                          gd.delayCancelEditModeTimer(300);
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          log.w(
                              "onEditingComplete _controller3 ${_controller3.text}");
                          gd.roomList[widget.roomIndex].row3Name =
                              _controller3.text.trim();
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.looks_4,
                    size: 28,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.edit),
                      ),
                      controller: _controller4,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline6,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() {
                          log.w("onChanged _controller4 ${_controller4.text}");
                          gd.roomList[widget.roomIndex].row4Name =
                              _controller4.text.trim();
                          gd.delayCancelEditModeTimer(300);
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          gd.roomList[widget.roomIndex].row4Name =
                              _controller4.text.trim();
                          log.w(
                              "onEditingComplete _controller4 ${gd.roomList[widget.roomIndex].row4Name}");
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
