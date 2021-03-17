import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translation = Translation.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Text(Translation.of(context).asdasd),
            // Text(Translation.of(context).times(3)),
            // Text(Translation.of(context).helloThere),
            Text(translation.points(1.00))
          ],
        ),
      ),
    );
  }
}
