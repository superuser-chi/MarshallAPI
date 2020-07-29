import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rank_marshal/src/models/day.dart';
import 'package:rank_marshal/src/models/kombi.dart';
import 'package:rank_marshal/src/models/route.dart';
import 'package:rank_marshal/src/models/slot.dart';
import 'package:rank_marshal/src/networking/kombi_util.dart';
import 'package:rank_marshal/src/networking/slot_util.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';

import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/utils/commons.dart';

class UpdateSlotPage extends StatefulWidget {
  final Slot slot;
  const UpdateSlotPage({Key key, @required this.slot}) : super(key: key);

  @override
  _UpdateSlotPageState createState() => _UpdateSlotPageState();
}

class _UpdateSlotPageState extends State<UpdateSlotPage>
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
    timePicked = widget.slot.time;
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
        key: _pageKey,
        appBar: AppBar(
          title: const Text("Update Slot"),
          backgroundColor: theme.primaryColor,
        ),
        body: Container(
          height: height,
          child: LoadingOverlay(
              isLoading: isLoading,
              child: Form(
                key: _formPageKey,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 20),
                            _routeWrapper(),
                            SizedBox(height: 20),
                            _dayWrapper(),
                            SizedBox(height: 20),
                            _kombiWrapper(),
                            SizedBox(height: 20),
                            _timeField(),
                            SizedBox(height: 20),
                            _submitButton(),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () async {
        if (_formPageKey.currentState.validate()) {
          setState(() {
            isLoading = true;
          });
          try {
            await addSlot(
                routeId: selectedRoute,
                dayId: selectedDay,
                kombiId: selectedKombi,
                time: timePicked);
            Navigator.pop(context);
          } catch (e) {
            Commons.showError(context, e.message);
            setState(() => isLoading = false);
            _pageKey.currentState
                .showSnackBar(SnackBar(content: Text("Could create slot")));
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'add slot',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
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
        hint: routes.length == 0
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
            value: val.dayId,
            child: new Text(value),
          );
        }).toList(),
        hint: days.length == 0
            ? Text("Please choose a route")
            : Text(days.firstWhere((i) => i.dayId == selectedDay).toString()),
        onChanged: (newVal) {
          setState(() {
            print(newVal);
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
                selectedDay = days.first.dayId;
                return _dayField();
              }
          }
        });
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
        hint: kombis.length == 0
            ? Text("Please choose a kombi")
            : Text(kombis
                .firstWhere((i) => i.kombiId == selectedKombi)
                .toString()),
        onChanged: (newVal) {
          setState(() {
            print(newVal);
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
                selectedDay = kombis.first.kombiId;
                return _kombiField();
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
          initialTime: TimeOfDay.fromDateTime(DateTime.parse(widget.slot.time)),
        );
        setState(() {
          timePicked = time.format(context);
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
