import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:shangxinyuemu/util/photo.dart';
import 'package:shangxinyuemu/view/detail.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';

class Index extends StatefulWidget {
  final String title;

  Index(this.title);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List list = [];
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  @override
  void initState() {
    super.initState();
    queryPhoto();
  }

  @override
  void dispose() {
    super.dispose();
  }

  queryPhoto({int pageNo, bool clear}) async {
    List list = await PhotoUtil.queryPhoto(pageNo: pageNo, clear: clear);
    if (list != null) {
      setState(() {
        this.list = list;
      });
    }
  }

  showPhoto(index) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Detail(list, index),
        ));
  }

  showAbout() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
            title: new Text("关于"),
            content: new Text('赏心悦目 是 基于 Shot on OnePlus API 制作在线照片预览的APP。'),
            actions: <Widget>[
              new FlatButton(
                child: new Text("我知道了"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
    );
  }

  Future refresh() async {
    return queryPhoto(pageNo: 1, clear: true);
  }

  Future loadMore() async {
    return queryPhoto();
  }

  Widget bodyWidget() {
    double width = (MediaQuery.of(context).size.width - 6) / 2;

    List<Widget> children = list
        .asMap()
        .map((i, item) => MapEntry(
            i,
            GestureDetector(
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(item['smallPhotoUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: () => showPhoto(i),
            )))
        .values
        .toList();

    return EasyRefresh(
      key: _easyRefreshKey,
      child: Wrap(
        children: children,
        runSpacing: 6.0,
        alignment: WrapAlignment.spaceBetween,
      ),
      refreshHeader: BallPulseHeader(
        key: _headerKey,
        backgroundColor: Theme.of(context).primaryColor,
        color: Theme.of(context).accentTextTheme.title.color,
      ),
      refreshFooter: BallPulseFooter(
        key: _footerKey,
        backgroundColor: Theme.of(context).primaryColor,
        color: Theme.of(context).accentTextTheme.title.color,
      ),
      autoLoad: true,
      onRefresh: () => refresh(),
      loadMore: () => loadMore(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: showAbout,
          )
        ],
        elevation: 0,
      ),
      body: bodyWidget(),
    );
  }
}
