import 'package:flutter/material.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:rank_marshal/src/models/route.dart';
import 'package:rank_marshal/src/utils/box.dart';
import 'package:rank_marshal/src/utils/highlight_text.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';
import 'package:http/http.dart' as http;


class KombiRouteSearchPage extends StatefulWidget {
  const KombiRouteSearchPage({Key key}) : super(key: key);

  @override
  _KombiRouteSearchPageState createState() => _KombiRouteSearchPageState();
}

class _KombiRouteSearchPageState extends State<KombiRouteSearchPage> {
  List<KombiRoute> filteredKombiRoutes = [];
  List<KombiRoute> KombiRoutes = [];

  TextEditingController _controller;
  String get text => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    fetchRoutes(http.Client()).then((onValue) {
      filteredKombiRoutes = onValue;
      KombiRoutes = onValue;
    });
    _controller = TextEditingController()
      ..addListener(
        _onQueryChanged,
      );
  }

  void _onQueryChanged() {
    filteredKombiRoutes.clear();

    if (text.isEmpty) {
      filteredKombiRoutes
        ..clear()
        ..addAll(KombiRoutes);

      setState(() {});

      return;
    }

    final query = text.toLowerCase();
    for (final lang in KombiRoutes) {
      final from = lang.from.toLowerCase();
      final to = lang.to.toLowerCase();
      final startsWith = from.startsWith(query) || to.startsWith(query);

      if (startsWith) {
        filteredKombiRoutes.add(lang);
      }
    }

    for (final lang in KombiRoutes) {
      final from = lang.from.toLowerCase();
      final to = lang.to.toLowerCase();
      final contains = from.contains(query) || to.contains(query);

      if (contains && !filteredKombiRoutes.contains(lang)) {
        filteredKombiRoutes.add(lang);
      }
    }

    setState(() {});
  }

  Widget _buildItem(KombiRoute lang) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Box(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      color: Colors.white,
      onTap: () => Navigator.pop(context, lang),
      child: ListTile(
        title: HighlightText(
          query: text,
          text: lang.to,
          style: textTheme.body1.copyWith(
            fontSize: 16,
          ),
          activeStyle: textTheme.body2.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: HighlightText(
          query: text,
          text: lang.from,
          style: textTheme.body1.copyWith(
            fontSize: 15,
          ),
          activeStyle: textTheme.body1.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final padding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      appBar: _buildAppBar(padding, theme, textTheme),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: filteredKombiRoutes.isNotEmpty
            ? _buildList()
            : _buildNoKombiRoutesPlaceholder(),
      ),
    );
  }

  Widget _buildList() {
    return ImplicitlyAnimatedList<KombiRoute>(
      items: filteredKombiRoutes,
      updateDuration: const Duration(milliseconds: 400),
      areItemsTheSame: (a, b) => a == b,
      itemBuilder: (context, animation, lang, _) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _buildItem(lang),
        );
      },
      updateItemBuilder: (context, animation, lang) {
        return FadeTransition(
          opacity: animation,
          child: _buildItem(lang),
        );
      },
    );
  }

  Widget _buildAppBar(double padding, ThemeData theme, TextTheme textTheme) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56 + padding),
      child: Box(
        height: 56 + padding,
        width: double.infinity,
        color: theme.accentColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          children: <Widget>[
            SizedBox(height: padding),
            Expanded(
              child: Row(
                children: <Widget>[
                  const BackButton(
                    color: Colors.white,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      style: textTheme.body2.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        hintText: 'Search for a KombiRoute',
                        hintStyle: textTheme.body2.copyWith(
                          color: Colors.grey.shade200,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: text.isEmpty ? 0.0 : 1.0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () => _controller.text = '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoKombiRoutesPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.translate,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No KombiRoutes found!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
