import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:megami/megami.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    styleCubit.setCss([CssBundle('main', 'asset://assets/style.css')]);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      final systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    return MaterialApp(
      home: StyledScaffold(builder: (context) {
        return Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   bottom: TabBar(
          //     tabs: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Image.asset(
          //             'assets/images/banner.jpg',
          //             width: 16,
          //             height: 16,
          //           ),
          //           Text('11111'),
          //         ],
          //       ),
          //       Tab(text: '2222')
          //     ],
          //     controller: _tabController,
          //   ).styled('.app-tab'),
          // ).styled('.app-bar'),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                brightness: Brightness.dark,
                expandedHeight: 320,
                backgroundColor: Colors.transparent,
                pinned: false,
                primary: true,
                title: Center(
                  child: TextField().styled('.search'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container().styled('.banner').styled('.banner-wrap'),
                      OverflowBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('NEXT SONG').styled('.appbar-subtitle'),
                            Text('Mic Drop').styled('.appbar-title'),
                            Text('BTS').styled('.appbar-text'),
                            Row(
                              children: [
                                GestureDetector(
                                    child: Container().styled('.player-cover'),
                                  onTap: () {
                                      // setState(() {
                                        styleCubit.removeStyle('main');
                                      // });
                                  },
                                ),
                              ],
                            ).styled('.player-panel'),
                          ],
                        ).styled('.appbar-content'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recently Listened Albums').styled('.section-title'),
                    Text('MORE').styled('.section-op'),
                  ],
                ).styled('.section-header'),
              ),
              SliverToBoxAdapter(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container().styled('.album-cover'),
                        Text('Between').styled('.album-title'),
                        Text('Motte').styled('.album-author'),
                      ],
                    ).styled('.album', index: min(index, 1));
                  },
                ).styled('.album-list'),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recommendations').styled('.section-title'),
                  ],
                ).styled('.section-header'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    Container().styled('.song'),
                    Container().styled('.song'),
                    Container().styled('.song'),
                    Container().styled('.song'),
                    Container().styled('.song'),
                    Container().styled('.song'),
                  ],
                ),
              ),
            ],
          ).styled('.page-container'),
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            showSelectedLabels: false,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'music',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'my',
              ),
            ],
          ),
        );
      }),
    );
  }
}
