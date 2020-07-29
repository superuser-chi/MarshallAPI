import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:rank_marshal/src/models/kombi.dart';
import 'package:rank_marshal/src/models/user.dart';
import 'package:rank_marshal/src/networking/kombi_util.dart';
import 'package:rank_marshal/src/networking/users_util.dart';
import 'package:rank_marshal/src/utils/box.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';

import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/utils/commons.dart';
import 'package:rank_marshal/src/utils/constants.dart';
import 'package:rank_marshal/src/views/create_kombi.dart';
import 'package:rank_marshal/src/views/update_kombi.dart';
import 'package:rank_marshal/src/widget/moreButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KombiPage extends StatefulWidget {
  const KombiPage({
    Key key,
  }) : super(key: key);

  @override
  _KombiPageState createState() => _KombiPageState();
}

class _KombiPageState extends State<KombiPage>
    with SingleTickerProviderStateMixin {
  static const double _horizontalHeight = 96;

  List<Kombi> Kombis = [];
  List<User> users = [];
  String selectedUser;
  final _formPageKey = GlobalKey<FormState>();
  final _pageKey = GlobalKey<ScaffoldState>();

  bool inReorder = false;

  ScrollController scrollController;
  TextEditingController _kombiPlate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _kombiPlate = TextEditingController(text: "");
  }

  Future<User> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(prefs.get(Constants.userTag));
    User user = User.fromJson(userMap);
    return user;
  }

  Future<List<Kombi>> fetchKombiList() async {
    User user = await _getUser();
    return fetchKombisByRoute(http.Client(), user.routeId);
  }

  void onReorderFinished(List<Kombi> newItems) {
    scrollController.jumpTo(scrollController.offset);
    setState(() {
      inReorder = false;

      Kombis
        ..clear()
        ..addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _pageKey,
      appBar: AppBar(
        title: const Text(Constants.Kombis),
        backgroundColor: theme.primaryColor,
      ),
      body: FutureBuilder<List<Kombi>>(
        future: fetchKombiList(),
        builder: (BuildContext context, AsyncSnapshot<List<Kombi>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                Kombis = snapshot.data;
                if (Kombis.length == 0) {
                  return Center(
                      child: IconButton(
                    icon: Icon(FontAwesomeIcons.plusCircle),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateKombiPage()));
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
                    _buildVerticalKombiList(Kombis),
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
  Widget _buildVerticalKombiList(List<Kombi> list) {
    final theme = Theme.of(context);
    const listPadding = EdgeInsets.symmetric(horizontal: 0);

    Widget buildReorderable(
      Kombi kombi,
      Widget Function(Widget tile) transitionBuilder,
    ) {
      return Reorderable(
        key: ValueKey(kombi),
        builder: (context, dragAnimation, inDrag) {
          final t = dragAnimation.value;
          final tile = _buildTile(t, kombi);

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

    return ImplicitlyAnimatedReorderableList<Kombi>(
      items: list,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: listPadding,
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      onReorderStarted: (item, index) => setState(() => inReorder = true),
      onReorderFinished: (movedKombi, from, to, newItems) {
        // Update the underlying data when the item has been reordered!
        onReorderFinished(newItems);
      },
      itemBuilder: (context, itemAnimation, kombi, index) {
        return buildReorderable(kombi, (tile) {
          return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: itemAnimation,
            child: tile,
          );
        });
      },
      updateItemBuilder: (context, itemAnimation, kombi) {
        return buildReorderable(kombi, (tile) {
          return FadeTransition(
            opacity: itemAnimation,
            child: tile,
          );
        });
      },
      footer: _buildFooter(context, theme.textTheme),
    );
  }

  Widget _buildTile(double t, Kombi kombi) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final color = Color.lerp(Colors.white, Colors.grey.shade100, t);
    final elevation = lerpDouble(0, 8, t);

    final List<Widget> actions = Kombis.length > 0
        ? [
            SlideAction(
              closeOnTap: true,
              color: Colors.white,
              onTap: () {
                deleteKombi(kombi).then((onValue) {
                  _pageKey.currentState
                      .showSnackBar(SnackBar(content: Text("Kombi deleted")));
                  setState(() {
                    Kombis.removeWhere((i) => i.kombiId == kombi.kombiId);
                  });
                }).catchError((onError) {
                  _pageKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                          "could not delete kombi with plate ${kombi.plate}")));
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
                    MaterialPageRoute(builder: (context) => UpdateKombiPage(kombi: kombi,)));
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
              kombi.plate,
              style: textTheme.body2.copyWith(
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "Owner: ${kombi.ownerName}",
              style: textTheme.body1.copyWith(
                fontSize: 15,
              ),
            ),
            leading: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  '${Kombis.indexOf(kombi) + 1}',
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

  Widget _userDropDownList() {
    return DropdownButton<String>(
        isExpanded: true,
        items: users.map((User val) {
          String value = "$val";
          return new DropdownMenuItem<String>(
            value: val.id,
            child: new Text(value),
          );
        }).toList(),
        hint: selectedUser == null
            ? Text("Please choose a user")
            : Text(users.firstWhere((i) => i.id == selectedUser).toString()),
        onChanged: (newVal) {
          setState(() {
            print(newVal);
            selectedUser = newVal;
            // isLoading = false;
          });
        });
  }

  Widget _userField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "User",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          _userDropDownList()
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    final height = MediaQuery.of(context).size.height;
    return Box(
      color: Colors.white,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateKombiPage()));
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
              'Add a Kombi',
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

  Widget _buildHeadline(String headline) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget buildDivider() => Container(
          height: 2,
          color: Colors.grey.shade300,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        buildDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            headline,
            style: textTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buildDivider(),
        const SizedBox(height: 16),
      ],
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
