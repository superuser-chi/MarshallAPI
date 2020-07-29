import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:rank_marshal/src/models/route.dart';
import 'package:rank_marshal/src/views/search_page.dart';
import 'package:rank_marshal/src/utils/box.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';

import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/widget/moreButton.dart';

class KombiRoutePage extends StatefulWidget {
  const KombiRoutePage({
    Key key,
  }) : super(key: key);

  @override
  _KombiRoutePageState createState() => _KombiRoutePageState();
}

class _KombiRoutePageState extends State<KombiRoutePage>
    with SingleTickerProviderStateMixin {
  static const double _horizontalHeight = 96;

  List<KombiRoute> kombiRoutes = [];

  bool inReorder = false;

  ScrollController scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  void onReorderFinished(List<KombiRoute> newItems) {
    scrollController.jumpTo(scrollController.offset);
    setState(() {
      inReorder = false;

      kombiRoutes
        ..clear()
        ..addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        backgroundColor: theme.primaryColor,
      ),
      body: FutureBuilder<List<KombiRoute>>(
        future: fetchRoutes(http.Client()),
        builder:
            (BuildContext context, AsyncSnapshot<List<KombiRoute>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                  kombiRoutes = snapshot.data;
                  return ListView(
                    controller: scrollController,
                    // Prevent the ListView from scrolling when an item is
                    // currently being dragged.
                    physics:
                        inReorder ? const NeverScrollableScrollPhysics() : null,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: <Widget>[
                      const Divider(height: 0),
                      _buildVerticalKombiRouteList(kombiRoutes),
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
  Widget _buildVerticalKombiRouteList(List<KombiRoute> list) {
    final theme = Theme.of(context);
    const listPadding = EdgeInsets.symmetric(horizontal: 0);

    Widget buildReorderable(
      KombiRoute lang,
      Widget Function(Widget tile) transitionBuilder,
    ) {
      return Reorderable(
        key: ValueKey(lang),
        builder: (context, dragAnimation, inDrag) {
          final t = dragAnimation.value;
          final tile = _buildTile(t, lang);

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

    return ImplicitlyAnimatedReorderableList<KombiRoute>(
      items: list,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: listPadding,
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      onReorderStarted: (item, index) => setState(() => inReorder = true),
      onReorderFinished: (movedKombiRoute, from, to, newItems) {
        // Update the underlying data when the item has been reordered!
        onReorderFinished(newItems);
      },
      itemBuilder: (context, itemAnimation, lang, index) {
        return buildReorderable(lang, (tile) {
          return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: itemAnimation,
            child: tile,
          );
        });
      },
      updateItemBuilder: (context, itemAnimation, lang) {
        return buildReorderable(lang, (tile) {
          return FadeTransition(
            opacity: itemAnimation,
            child: tile,
          );
        });
      },
      footer: _buildFooter(context, theme.textTheme),
    );
  }

  Widget _buildTile(double t, KombiRoute lang) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final color = Color.lerp(Colors.white, Colors.grey.shade100, t);
    final elevation = lerpDouble(0, 8, t);

    final List<Widget> actions = kombiRoutes.length > 1
        ? [
            SlideAction(
              closeOnTap: true,
              color: Colors.white,
              onTap: () {
                setState(
                  () => kombiRoutes.remove(lang),
                );
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
                setState(
                  () => kombiRoutes.remove(lang),
                );
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
            lang.to,
            style: textTheme.body2.copyWith(
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            lang.from,
            style: textTheme.body1.copyWith(
              fontSize: 15,
            ),
          ),
          leading: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                '${kombiRoutes.indexOf(lang) + 1}',
                style: textTheme.body2.copyWith(
                  color: theme.accentColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          trailing: MoreButton()
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    return Box(
      color: Colors.white,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KombiRouteSearchPage(),
          ),
        );

        if (result != null && !kombiRoutes.contains(result)) {
          setState(() {
            kombiRoutes.add(result);
          });
        }
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
              'Add a KombiRoute',
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
