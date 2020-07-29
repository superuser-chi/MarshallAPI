import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rank_marshal/src/models/kombi.dart';
import 'package:rank_marshal/src/models/user.dart';
import 'package:rank_marshal/src/networking/kombi_util.dart';

import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/networking/users_util.dart';
import 'package:rank_marshal/src/utils/commons.dart';

class UpdateKombiPage extends StatefulWidget {
  final Kombi kombi;
  const UpdateKombiPage({Key key, @required this.kombi})
      : super(key: key);

  @override
  _UpdateKombiPageState createState() => _UpdateKombiPageState();
}

class _UpdateKombiPageState extends State<UpdateKombiPage>
    with SingleTickerProviderStateMixin {

  List<User> users = [];
  String selectedUser;
  TextEditingController _kombiPlate;

  final _formPageKey = GlobalKey<FormState>();
  final _pageKey = GlobalKey<ScaffoldState>();
  bool inReorder = false;

  ScrollController scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _kombiPlate = TextEditingController(text: widget.kombi.plate);
    selectedUser = widget.kombi.userId;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
        key: _pageKey,
        appBar: AppBar(
          title: const Text("Edit Kombi"),
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
                            _userWrapper(),
                            SizedBox(height: 20),
                            _plateField(),
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
            await editKombi(new Kombi(userId: selectedUser, plate: _kombiPlate.text, kombiId: widget.kombi.kombiId));
            Navigator.pop(context);
          } catch (e) {
            Commons.showError(context, e.message);
            setState(() => isLoading = false);
            _pageKey.currentState
                .showSnackBar(SnackBar(content: Text("Could create kombi")));
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
          'edit kombi',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
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
        hint: users.length == 0
            ? Text("Please choose a user")
            : Text(users.firstWhere((i) => i.id == selectedUser).toString()),
        onChanged: (newVal) {
          setState(() {
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

  Widget _userWrapper() {
    return FutureBuilder<List<User>>(
        future: fetchUsers(http.Client()),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.waiting:
              return _userField();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                users = snapshot.data;
                return _userField();
              }
          }
        });
  }

  Widget _plateField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Plate",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: Commons.defaultFieldValidator,
              controller: _kombiPlate,
              obscureText: false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
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
