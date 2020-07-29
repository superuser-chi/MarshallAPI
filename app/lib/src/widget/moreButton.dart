import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MoreButton extends StatelessWidget {
  const MoreButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.drag_handle),
      iconSize: 20.0,
      onPressed: () => Slidable.of(context).open(),
    );
  }
}