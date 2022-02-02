import 'package:flutter/material.dart';
import 'package:swifty_companion/clientApi.dart';


class FirstRoute extends StatefulWidget {  //ME
  const FirstRoute({Key? key}) : super(key: key);

  @override
  State<FirstRoute> createState() => _FirstRoute();

}

class _FirstRoute extends State<FirstRoute> {
  final ClientApi _clientApi = ClientApi();


  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}