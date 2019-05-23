import 'package:ctrip/dao/home_dao.dart';
import 'package:ctrip/model/common_model.dart';
import 'package:ctrip/model/gridnav_model.dart';
import 'package:ctrip/model/home_model.dart';
import 'package:ctrip/model/sales_box_model.dart';
import 'package:ctrip/pages/search_page.dart';
import 'package:ctrip/pages/speak_page.dart';
import 'package:ctrip/util/navigator_util.dart';
import 'package:ctrip/widgets/cache_image.dart';
import 'package:ctrip/widgets/grid_nav_widget.dart';
import 'package:ctrip/widgets/loading_container_widget.dart';
import 'package:ctrip/widgets/local_nav_widget.dart';
import 'package:ctrip/widgets/sales_box_widget.dart';
import 'package:ctrip/widgets/search_bar_widget.dart';
import 'package:ctrip/widgets/sub_nav_widget.dart';
import 'package:ctrip/widgets/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

const APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = '网红打卡地 景点 酒店 美食';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  double appBarAlpha = 0;
  List<CommonModel> bannerList = [];
  List<CommonModel> localNavList = [];
  List<CommonModel> subNavList = [];
  GridNavModel gridNavModel;
  SalesBoxModel salesBox;
  bool _loading = true; //页面加载状态

  @override
  void initState() {
    _handleRefresh();
    super.initState();
  }

  //缓存页面
  @override
  bool get wantKeepAlive => true;


  //判断滚动改变透明度
  void _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
  }

  //加载首页数据
  Future<Null> _handleRefresh() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        bannerList = model.bannerList;
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBox = model.salesBox;
        _loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
    return null;
  }

  //跳转搜索页面
  void _jumpToSearch() {
    NavigatorUtil.push(
        context,
        SearchPage(
          hint: SEARCH_BAR_DEFAULT_TEXT,
        ));
  }

  //跳转语音识别页面
  void _jumpToSpeak() {
    NavigatorUtil.push(context, SpeakPage());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: LoadingContainerWidget(
          isLoading: _loading,
          child: Stack(
            children: <Widget>[
              MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: NotificationListener(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollUpdateNotification &&
                              scrollNotification.depth == 0) {
                            //滚动并且是列表滚动的时候
                            _onScroll(scrollNotification.metrics.pixels);
                          }
                        },
                        child: _listView,
                      )
                  )
              ),
              _appBar
            ],
          )
      ),
    );
  }



  //listView列表
  Widget get _listView {
    return ListView(
      children: <Widget>[
        /*轮播图*/
        _banner,
        /*local导航*/
        Padding(
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
          child: LocalNavWidget(
            localNavList: localNavList,
          ),
        ),
        /*网格卡片*/
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: GridNavWidget(gridNavModel: gridNavModel),
        ),
        /*活动导航*/
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: SubNavWidget(subNavList: subNavList),
        ),
        /*底部卡片*/
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: SalesBoxWidget(salesBox: salesBox),
        ),
      ],
    );
  }

  /*自定义appBar*/
  Widget get _appBar {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x66000000), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80,
            decoration: BoxDecoration(
                color:
                Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255)),
            child: SearchBarWidget(
              searchBarType: appBarAlpha > 0.2
                  ? SearchBarType.homeLight
                  : SearchBarType.home,
              inputBoxClick: _jumpToSearch,
              speakClick: _jumpToSpeak,
              defaultText: SEARCH_BAR_DEFAULT_TEXT,
              leftButtonClick: () {},
            ),
          ),
        ),
        Container(
          height: appBarAlpha > 0.2 ? 0.5 : 0,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)]),
        )
      ],
    );
  }

  /*banner轮播图*/
  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        autoplay: true,
        loop: true,
        pagination: SwiperPagination(),
        itemCount: bannerList.length,
        itemBuilder: (BuildContext context, int index) {
          return CachedImage(
            imageUrl: bannerList[index].icon,
            fit: BoxFit.fill,
          );
        },
        onTap: (index) {
          NavigatorUtil.push(
              context,
              WebView(
                url: bannerList[index].url,
                hideAppBar: bannerList[index].hideAppBar,
                title: bannerList[index].title,
              ));
        },
      ),
    );
  }

}