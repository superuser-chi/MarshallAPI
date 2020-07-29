import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rank_marshal/src/models/route.dart';
import 'package:rank_marshal/src/models/user.dart';
import 'package:rank_marshal/src/networking/routes_util.dart';
import 'package:rank_marshal/src/networking/users_util.dart';
import 'package:rank_marshal/src/utils/commons.dart';
import 'package:rank_marshal/src/utils/constants.dart';
import 'package:rank_marshal/src/views/users/recover.dart';
import 'package:rank_marshal/src/widget/bezierContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard.dart';
import 'loginPage.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  TextStyle style = TextStyle(fontFamily: 'Roboto', fontSize: 20.0);
  TextEditingController _userName;
  TextEditingController _userFirstname;
  TextEditingController _userLastname;
  TextEditingController _userPhone;
  TextEditingController _userPassword;
  final _formPageKey = GlobalKey<FormState>();
  final _pageKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  String selectedRouteID;

  List<KombiRoute> kombiRoutes = [];
  @override
  void initState() {
    super.initState();
    _userName = TextEditingController(text: "");
    _userFirstname = TextEditingController(text: "");
    _userLastname = TextEditingController(text: "");
    _userPhone = TextEditingController(text: "");
    _userPassword = TextEditingController(text: "");
  }

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _login(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(user.toJson());
    prefs.setString(Constants.userTag, json);
    setState(() => isLoading = false);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen()));
  }

  Widget _userNameField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Username",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultFieldValidator,
              controller: _userName,
              obscureText: false,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Phone",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultFieldValidator,
              controller: _userPhone,
              obscureText: false,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _firstNameField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Firstname",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultFieldValidator,
              controller: _userFirstname,
              obscureText: false,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _lastNameField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "LastName",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultFieldValidator,
              controller: _userLastname,
              obscureText: false,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultPasswordValidator,
              controller: _userPassword,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.lock),
                  suffixIcon: IconButton(
                    onPressed: _togglePassword,
                    icon: Icon(_obscureText
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash),
                  ),
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () async {
        if (_formPageKey.currentState.validate()) {
          setState(() {
            isLoading = true;
          });
          try {
            var user = await register(
                username: _userName.text,
                password: _userPassword.text,
                firstname: _userFirstname.text,
                lastname: _userLastname.text,
                routeId: selectedRouteID,
                phoneNumber: _userPhone.text);
            await _login(user);
          } catch (e) {
            Commons.showError(context, e.message);
            setState(() => isLoading = false);
            _pageKey.currentState
                .showSnackBar(SnackBar(content: Text("Could not register.")));
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
          'Register',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recoverAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RecoverPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Forgot Password ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Recover',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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


Widget _routeDropDownList() {
    return DropdownButton<String>(
        isExpanded: true,
        items: kombiRoutes.map((KombiRoute val) {
          String value = "$val";
          return new DropdownMenuItem<String>(
            value: val.routeId,
            child: new Text(value),
          );
        }).toList(),
        hint: selectedRouteID == null
            ? Text("Please choose a route")
            : Text(kombiRoutes
                .firstWhere((i) => i.routeId == selectedRouteID)
                .toString()),
        onChanged: (newVal) {
          setState(() {
            selectedRouteID = newVal;
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
                kombiRoutes = snapshot.data;
                return _routeField();
              }
          }
        });
  }

  Widget _registerForm(final height) {
    return Form(
      key: _formPageKey,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _title(),
                  SizedBox(height: 50),
                  _userNameField(),
                  SizedBox(height: 20),
                  _firstNameField(),
                  SizedBox(height: 20),
                  _lastNameField(),
                  SizedBox(height: 20),
                  _phoneField(),
                  SizedBox(height: 20),
                  _routeWrapper(),
                  SizedBox(height: 20),
                  _passwordField(),
                  SizedBox(height: 20),
                  _submitButton(),
                  _recoverAccountLabel(),
                  _loginAccountLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _pageKey,
        body: Container(
          height: height,
          child: LoadingOverlay(
              isLoading: isLoading, child: _registerForm(height)),
        ));
  }
}
