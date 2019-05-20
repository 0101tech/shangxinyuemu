import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shangxinyuemu/util/photo.dart';
import 'package:share_extend/share_extend.dart';

class Detail extends StatefulWidget {
  final List photos;
  final int initialIndex;
  bool hideAppBar;

  Detail(this.photos, this.initialIndex, {this.hideAppBar = false});

  @override
  State<StatefulWidget> createState() {
    return _DetailState(this.hideAppBar);
  }
}

class _DetailState extends State<Detail> {
  final backgroundDecoration = BoxDecoration(color: Colors.black);

  int currentIndex;
  bool hideAppBar = false;

  _DetailState(this.hideAppBar);

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    checkPermission();
  }

  Future<bool> checkPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void onPageChanged(int index) async {
    if (index + 1 == widget.photos.length) {
      List list = await PhotoUtil.queryPhoto();

      // 直接修改photos会有并发问题
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            // 从左到右的动画
            return SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: Detail(
                list,
                index,
                hideAppBar: hideAppBar,
              ),
            );
          },
        ),
      );
    }
  }

  back() {
    Navigator.of(context).pop();
  }

  share() async {
    String taskId = await download(showNotification: false);
    bool stop = false;
    do {
      List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        tasks.forEach((item) {
          if (taskId == item.taskId &&
              DownloadTaskStatus.complete == item.status) {
            ShareExtend.share('${item.savedDir}/${item.filename}', "image");
            stop = true;
          }
        });
      } else {
        stop = true;
      }
    } while (!stop);
  }

  Future<String> download({bool showNotification = true}) async {
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final downloadDir = directory.path + '/Download';

    final taskId = await FlutterDownloader.enqueue(
      url: widget.photos[currentIndex]['photoUrl'],
      savedDir: downloadDir,
      showNotification: showNotification,
      openFileFromNotification: showNotification,
    );
    return taskId;
  }

  toggleAppBar() {
    setState(() {
      this.hideAppBar = !hideAppBar;
    });
  }

  Widget appBarWidget() {
    if (hideAppBar) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      return Container(
        height: 0,
      );
    }

    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: back,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: share,
        ),
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: download,
        )
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  PhotoViewGalleryPageOptions itemWidget(BuildContext context, int index) {
    final item = widget.photos[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(item['photoUrl']),
    );
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: widget.initialIndex);

    return Container(
      decoration: backgroundDecoration,
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: GestureDetector(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: itemWidget,
              itemCount: widget.photos.length,
//              loadingChild: widget.loadingChild,
              backgroundDecoration: backgroundDecoration,
              pageController: pageController,
              onPageChanged: onPageChanged,
            ),
            Positioned(
              child: appBarWidget(),
              top: 0,
              left: 0,
              right: 0,
            )
          ],
        ),
        onTap: toggleAppBar,
      ),
    );
  }
}
