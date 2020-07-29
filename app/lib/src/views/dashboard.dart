import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rank_marshal/src/models/user.dart';
import 'package:rank_marshal/src/utils/constants.dart';
import 'package:rank_marshal/src/utils/transition_route_observer.dart';
import 'package:rank_marshal/src/views/routes.dart';
import 'package:rank_marshal/src/views/slot.dart';
import 'package:rank_marshal/src/views/users/signup.dart';
import 'package:rank_marshal/src/widget/animated_numeric_text.dart';
import 'package:rank_marshal/src/widget/fade_in.dart';
import 'package:rank_marshal/src/widget/round_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kombis.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
        .pushReplacementNamed('/')
        // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }

  final routeObserver = TransitionRouteObserver<PageRoute>();
  static const headerAniInterval =
      const Interval(.1, .3, curve: Curves.easeOut);
  Animation<double> _headerScaleAnimation;
  AnimationController _loadingController;
  User user;
  String welcomeText = 'Fetching your data';
  @override
  Future<void> initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController,
      curve: headerAniInterval,
    ));
  }

  Future<User> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(prefs.get(Constants.userTag));
    user = User.fromJson(userMap);
    return user;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController.dispose();
    super.dispose();
  }

  @override
  void didPushAfterTransition() => _loadingController.forward();

  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.primaryColor,
      icon: const Icon(FontAwesomeIcons.home),
      onPressed: () {},
    );
    final signOutBtn = IconButton(
      color: theme.primaryColor,
      icon: const Icon(FontAwesomeIcons.signOutAlt),
      onPressed: () => _goToLogin(context),
    );
    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Hero(
              tag: Constants.logoTag,
              child: _title(),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );

    return AppBar(
      leading: FadeIn(
        child: menuBtn,
        controller: _loadingController,
        offset: .3,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.startToEnd,
      ),
      actions: <Widget>[
        FadeIn(
          child: signOutBtn,
          controller: _loadingController,
          offset: .3,
          curve: headerAniInterval,
          fadeDirection: FadeDirection.endToStart,
        ),
      ],
      title: title,
      backgroundColor: Colors.white,
      elevation: 0,
      textTheme: theme.accentTextTheme,
      iconTheme: theme.accentIconTheme,
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'R',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'an',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'k',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
            TextSpan(
              text: 'Mar',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'shal',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final primaryColor =
        Colors.primaries.where((c) => c == theme.primaryColor).first;
    final accentColor =
        Colors.primaries.where((c) => c == theme.accentColor).first;
    final linearGradient = LinearGradient(colors: [
      primaryColor.shade800,
      primaryColor.shade200,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 418.0, 78.0));

    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: FadeIn(
        controller: _loadingController,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.bottomToTop,
        offset: .5,
        child: FutureBuilder<User>(
              future: _getUser(),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return new Text('Press button to start');
                  case ConnectionState.waiting:
                    return new Text('Fetching data...',
                              style: theme.textTheme.display2.copyWith(
                                    foreground: Paint()..shader = linearGradient,
                                  ));
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AnimatedNumericText(
                                  initialValue: 0,
                                  targetValue: double.parse(user.phoneNumber),
                                  curve: Interval(0, .5, curve: Curves.easeOut),
                                  controller: _loadingController,
                                  style: theme.textTheme.display2.copyWith(
                                    foreground: Paint()..shader = linearGradient,
                                  ),
                                ),
                              ],
                            ),
                          Text('Welcome ${user.firstname} ${user.lastname}')
                          ]
                        );
                }
              },
            ),
        ),
      );
  }

  Widget _buildButton({Widget icon, String label, Interval interval}) {
    return RoundButton(
      icon: icon,
      label: label,
      loadingController: _loadingController,
      interval: Interval(
        interval.begin,
        interval.end,
        curve: ElasticOutCurve(0.42),
      ),
      onPressed: () {
        switch (label) {
          case Constants.Kombis:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => KombiPage()));
            break;
          case Constants.Routes:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => KombiRoutePage()));
            break;
          case Constants.Schedule:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SlotPage()));
            break;
          default:
            break;
        }
      },
    );
  }

  Widget _buildDashboardGrid() {
    const step = 0.04;
    const aniInterval = 0.75;

    return GridView.count(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 20,
      ),
      childAspectRatio: .9,
      // crossAxisSpacing: 5,
      crossAxisCount: 3,
      children: [
        _buildButton(
          icon: Icon(FontAwesomeIcons.user),
          label: 'Profile',
          interval: Interval(0, aniInterval),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.bus, size: 20),
          label: Constants.Kombis,
          interval: Interval(step, aniInterval + step),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.calendarAlt),
          label: 'Schedule',
          interval: Interval(step * 2, aniInterval + step * 2),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.route),
          label: Constants.Routes,
          interval: Interval(step, aniInterval + step),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.flag),
          label: 'Report',
          interval: Interval(0, aniInterval),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignUpPage()));
          },
          child: _buildButton(
            icon: Icon(Icons.vpn_key),
            label: 'Register',
            interval: Interval(step, aniInterval + step),
          ),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.history),
          label: 'History',
          interval: Interval(step * 2, aniInterval + step * 2),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.ellipsisH),
          label: 'Other',
          interval: Interval(0, aniInterval),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.slidersH, size: 20),
          label: 'Settings',
          interval: Interval(step * 2, aniInterval + step * 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => _goToLogin(context),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(theme),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.white,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white])),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 40),
                    Expanded(
                      flex: 2,
                      child: _buildHeader(theme),
                    ),
                    Expanded(flex: 8, child: _buildDashboardGrid()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
