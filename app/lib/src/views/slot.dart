import 'dart:convert';
import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:intl/intl.dart';
import 'package:rank_marshal/src/models/day.dart';
import 'package:rank_marshal/src/models/kombi.dart';
import 'package:rank_marshal/src/models/route.dart';
import 'package:rank_marshal/src/models/slot.dart';
import 'package:rank_marshal/src/models/user.dart';
import 'package:rank_marshal/src/networking/kombi_util.dart';
import 'package:rank_marshal/src/networking/slot_util.dart';
import 'package:rank_marshal/src/utils/box.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';

import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/utils/commons.dart';
import 'package:rank_marshal/src/utils/constants.dart';
import 'package:rank_marshal/src/views/create_slot.dart';
import 'package:rank_marshal/src/views/update_slot.dart';
import 'package:rank_marshal/src/widget/moreButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlotPage extends StatefulWidget {
  const SlotPage({
    Key key,
  }) : super(key: key);

  @override
  _SlotPageState createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage>
    with SingleTickerProviderStateMixin {
  List<Slot> Slots = [];
  List<Kombi> kombis = [];
  List<KombiRoute> routes = [];
  List<Day> days = [];
  String selectedRoute;
  String selectedDay;
  String selectedKombi;
  String timePicked;

  final _formPageKey = GlobalKey<FormState>();
  final _pageKey = GlobalKey<ScaffoldState>();

  bool inReorder = false;

  ScrollController scrollController;
  final format = DateFormat("hh:mm a");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  void onReorderFinished(List<Slot> newItems) {
    scrollController.jumpTo(scrollController.offset);
    setState(() {
      inReorder = false;

      Slots
        ..clear()
        ..addAll(newItems);
    });
  }

  Future<User> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(prefs.get(Constants.userTag));
    User user = User.fromJson(userMap);
    return user;
  }
  Future<List<Slot>> fetchSlotList() async {
    User user = await _getUser();
    return fetchSlotsByRoute(http.Client(), user.routeId);
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _pageKey,
      appBar: AppBar(
        title: const Text(Constants.Schedule),
        backgroundColor: theme.primaryColor,
      ),
      body: FutureBuilder<List<Slot>>(
        future: fetchSlotList(),
        builder: (BuildContext context, AsyncSnapshot<List<Slot>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                Slots = snapshot.data;
                if (Slots.length == 0) {
                  return Center(
                      child: IconButton(
                    icon: Icon(FontAwesomeIcons.plusCircle),
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateSlotPage()));       
                    },
                  ));
                }
                return ListView(
                  controller: scrollController,
                  // Prevent the ListView from scrolling when an item is
                  // currently being dragged.
                  physics:
                      inReorder ? const NeverScrollableScrollPhysics() : null,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: <Widget>[
                    const Divider(height: 0),
                    _buildVerticalSlotList(Slots),
                    const SizedBox(height: 500),
                  ],
                );
              }
          }
        },
      ),
    );
  }

  // * An example of a vertically reorderable list.
  Widget _buildVerticalSlotList(List<Slot> list) {
    final theme = Theme.of(context);
    const listPadding = EdgeInsets.symmetric(horizontal: 0);

    Widget buildReorderable(
      Slot slot,
      Widget Function(Widget tile) transitionBuilder,
    ) {
      return Reorderable(
        key: ValueKey(slot),
        builder: (context, dragAnimation, inDrag) {
          final t = dragAnimation.value;
          final tile = _buildTile(t, slot);

          // If the item is in drag, only return the tile as the
          // SizeFadeTransition would clip the shadow.
          if (t > 0.0) {
            return tile;
          }

          return transitionBuilder(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                tile,
                const Divider(height: 0),
              ],
            ),
          );
        },
      );
    }

    return ImplicitlyAnimatedReorderableList<Slot>(
      items: list,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: listPadding,
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      onReorderStarted: (item, index) => setState(() => inReorder = true),
      onReorderFinished: (movedSlot, from, to, newItems) {
        // Update the underlying data when the item has been reordered!
        onReorderFinished(newItems);
      },
      itemBuilder: (context, itemAnimation, slot, index) {
        return buildReorderable(slot, (tile) {
          return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: itemAnimation,
            child: tile,
          );
        });
      },
      updateItemBuilder: (context, itemAnimation, slot) {
        return buildReorderable(slot, (tile) {
          return FadeTransition(
            opacity: itemAnimation,
            child: tile,
          );
        });
      },
      footer: _buildFooter(context, theme.textTheme),
    );
  }

  Widget _buildTile(double t, Slot slot) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final color = Color.lerp(Colors.white, Colors.grey.shade100, t);
    final elevation = lerpDouble(0, 8, t);

    final List<Widget> actions = Slots.length > 1
        ? [
            SlideAction(
              closeOnTap: true,
              color: Colors.white,
              onTap: () {
                deleteSlot(slot).then((onValue) {
                  _pageKey.currentState
                      .showSnackBar(SnackBar(content: Text("Slot deleted")));
                  setState(() {
                    Slots.removeWhere((i) => i.slotId == slot.slotId);
                  });
                }).catchError((onError) {
                  _pageKey.currentState.showSnackBar(
                      SnackBar(content: Text("could not delete ${slot}")));
                });
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delete',
                      style: textTheme.body2.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SlideAction(
              closeOnTap: true,
              color: Colors.white,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UpdateSlotPage(slot: slot,)));
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.pen,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edit',
                      style: textTheme.body2.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        : [];

    return Slidable(
      actionPane: const SlidableBehindActionPane(),
      actions: actions,
      secondaryActions: actions,
      child: Box(
        color: color,
        elevation: elevation,
        alignment: Alignment.center,
        child: ListTile(
            title: Text(
              slot.time
              ,
              style: textTheme.body2.copyWith(
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${slot.ownerName}(${slot.kombiPlate})",
              style: textTheme.body1.copyWith(
                fontSize: 15,
              ),
            ),
            leading: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  '${Slots.indexOf(slot) + 1}',
                  style: textTheme.body2.copyWith(
                    color: theme.accentColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            trailing: MoreButton()),
      ),
    );
  }

  Widget _kombiDropDownList() {
    return DropdownButton<String>(
        isExpanded: true,
        items: kombis.map((Kombi val) {
          String value = "$val";
          return new DropdownMenuItem<String>(
            value: val.kombiId,
            child: new Text(value),
          );
        }).toList(),
        hint: selectedKombi == null
            ? Text("Please choose a kombi")
            : Text(kombis
                .firstWhere((i) => i.kombiId == selectedKombi)
                .toString()),
        onChanged: (newVal) {
          setState(() {
            selectedKombi = newVal;
            // isLoading = false;
          });
        });
  }

  Widget _kombiField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Kombi",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          _kombiDropDownList()
        ],
      ),
    );
  }

  Widget _kombiWrapper() {
    return FutureBuilder<List<Kombi>>(
        future: fetchKombis(http.Client()),
        builder: (BuildContext context, AsyncSnapshot<List<Kombi>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return _kombiField();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                kombis = snapshot.data;
                return _kombiField();
              }
          }
        });
  }

  Widget _routeDropDownList() {
    return DropdownButton<String>(
        isExpanded: true,
        items: routes.map((KombiRoute val) {
          String value = "$val";
          return new DropdownMenuItem<String>(
            value: val.routeId,
            child: new Text(value),
          );
        }).toList(),
        hint: selectedRoute == null
            ? Text("Please choose a route")
            : Text(routes
                .firstWhere((i) => i.routeId == selectedRoute)
                .toString()),
        onChanged: (newVal) {
          setState(() {
            print(newVal);
            selectedRoute = newVal;
            // isLoading = false;
          });
        });
  }

  Widget _routeField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Route",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          _routeDropDownList()
        ],
      ),
    );
  }

  Widget _routeWrapper() {
    return FutureBuilder<List<KombiRoute>>(
        future: fetchRoutes(http.Client()),
        builder:
            (BuildContext context, AsyncSnapshot<List<KombiRoute>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return _routeField();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                routes = snapshot.data;
                return _routeField();
              }
          }
        });
  }

  Widget _dayDropDownList() {
    return DropdownButton<String>(
        isExpanded: true,
        items: days.map((Day val) {
          String value = "$val";
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        hint: selectedKombi == null
            ? Text("Please choose a day")
            : Text(days.firstWhere((i) => i.dayId == selectedDay).toString()),
        onChanged: (newVal) {
          setState(() {
            selectedDay = newVal;
            // isLoading = false;
          });
        });
  }

  Widget _dayField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Day",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          _dayDropDownList()
        ],
      ),
    );
  }

  Widget _dayWrapper() {
    return FutureBuilder<List<Day>>(
        future: fetchDays(http.Client()),
        builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return _dayField();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                days = snapshot.data;
                return _dayField();
              }
          }
        });
  }

  Widget _time() {
    return DateTimeField(
      format: format,
      onShowPicker: (context, currentValue) async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
        );
        setState(() {
          timePicked = "${time.hour}:${time.minute}";
        });
        return DateTimeField.convert(time);
      },
    );
  }

  Widget _timeField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Time",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          _time()
        ],
      ),
    );
  }


  _editSlot(BuildContext context, Slot slot) {
    Alert(
        context: context,
        title: "Add Slot",
        content: Column(
          children: <Widget>[
            Form(
              key: _formPageKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  _routeWrapper(),
                  SizedBox(height: 20),
                  _dayWrapper(),
                  SizedBox(height: 20),
                  _kombiWrapper(),
                  SizedBox(height: 20),
                  _timeField()
                ],
              ),
            )
          ],
        ),
        buttons: [
          DialogButton(
            child: Text(
              "edit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            radius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            onPressed: () {
              editSlot(slot).then((onValue) {
                Navigator.pop(context);
                int index = Slots.indexWhere((i) => i.slotId == slot.slotId);
                Slots[index] = slot;
                _pageKey.currentState
                    .showSnackBar(SnackBar(content: Text("Slot updated")));
              }).catchError((onError) {
                Navigator.pop(context);
                _pageKey.currentState
                    .showSnackBar(SnackBar(content: Text("could not update")));
              });
            },
            width: 120,
          )
        ]).show();
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Box(
      color: Colors.white,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateSlotPage()));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: SizedBox(
              height: 36,
              width: 36,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
            ),
            title: Text(
              'Add a Slot',
              style: textTheme.body1.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class Pair<A, B> {
  final A first;
  final B second;
  Pair(
    this.first,
    this.second,
  );
}
