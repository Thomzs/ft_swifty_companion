import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swifty_companion/clientApi.dart';

import 'args.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {

  Timer? _debounce;
  final _controller = TextEditingController();

  var _search = [];
  final ClientApi ca = ClientApi();

  void doSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty && value.length >= 3) { //Only process at least 3 chars long queries
        var tmp = await ca.get('https://api.intra.42.fr/v2/users?range[login]=$value,$value''zzz&per_page=100');
        setState(() {
          _search = tmp ?? [];
        });
      } else {
        setState(() {
          _search = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _controller,
              onChanged: doSearch,
              onSubmitted: (value) { FocusManager.instance.primaryFocus?.unfocus(); },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    onPressed: _controller.clear,
                    icon: const Icon(Icons.clear)
                )
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _search.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          String id = _search[index]['id'].toString();
                          String url = 'https://api.intra.42.fr/v2/users/$id';
                          Navigator.pushNamed(
                              context,
                              'user',
                              arguments: Args(url, false)
                          );
                        },
                          child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(_search[index]['image_url']),
                                  ),
                                  const SizedBox(
                                      width: 18
                                  ),
                                  Text(_search[index]['login'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                        color: Colors.white70
                                    ),
                                  )
                                ],
                              )
                          )
                          )
                      );
                    },
                  )
              )
            ],
          ),
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}