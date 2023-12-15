import 'package:flutter/material.dart';
import 'package:frontend/Pages/Main%20Pages/add_post_page.dart';
import 'package:frontend/Pages/Main%20Pages/conversations_page.dart';
import 'package:frontend/Pages/Main%20Pages/discover_page.dart';
import 'package:frontend/Pages/Main%20Pages/home_page.dart';
import 'package:frontend/Pages/Main%20Pages/own_profile_page.dart';
import 'package:frontend/Widgets/App%20Bars/add_post_appbar.dart';
import 'package:frontend/Widgets/App%20Bars/conversations_appbar.dart';
import 'package:frontend/Widgets/App%20Bars/home_appbar.dart';
import 'package:frontend/Widgets/App%20Bars/own_profile_appbar.dart';
import 'package:frontend/constants.dart';
import "package:http/http.dart" as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final GlobalKey<OwnProfilePageState> _profilePageKey =
      GlobalKey<OwnProfilePageState>();
  List<Widget?>? mainPages;

  List<PreferredSizeWidget?>? appBars;

  int _selectedPageIndex = 0;
  int _previousPageIndex = -1;

  @override
  void initState() {
    super.initState();
    _changeStatus(true);
    WidgetsBinding.instance.addObserver(this);
    mainPages = [
      const HomePage(),
      const DiscoverPage(),
      AddPostPage(
        goBack: gotoPreviousPage,
      ),
      const ConversationsPage(),
      OwnProfilePage(
        key: _profilePageKey,
      )
    ];
    appBars = [
      const HomeAppBar(),
      null,
      AddPostAppBar(
        goBack: gotoPreviousPage,
      ),
      ConversationsAppBar(
        goBack: gotoPreviousPage,
      ),
      OwnProfileAppBar(
        profilePageState: _profilePageKey,
      )
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _changeStatus(bool status) async {
    final url =
        "http://$serverIpAddress:5000/user/changeOnlineStatus?status=$status";
    http.Response changeOnlineStatus = await http.get(Uri.parse(url),
        headers: {"Cookie": prefs.getString('cookie') ?? ''});

    if (changeOnlineStatus.statusCode != 200) {
      // ignore: use_build_context_synchronously
      CoreMethods.showSnackBar(context, "Something went wrong.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _changeStatus(true);
    } else {
      _changeStatus(false);
    }
  }

  void gotoPreviousPage() {
    if (_previousPageIndex != -1) {
      setState(() {
        int prev = _selectedPageIndex;
        _selectedPageIndex = _previousPageIndex;
        _previousPageIndex = prev;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBars![_selectedPageIndex],
      body: mainPages![_selectedPageIndex],
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: AppColors.bottomBar),
        child: BottomNavigationBar(
            onTap: (index) => index != _selectedPageIndex
                ? setState(() {
                    _previousPageIndex = _selectedPageIndex;
                    _selectedPageIndex = index;
                  })
                : null,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            backgroundColor: AppColors.backgroundColor,
            currentIndex: _selectedPageIndex,
            items: const [
              BottomNavigationBarItem(
                  label: "Home",
                  activeIcon: Icon(
                    Icons.home,
                  ),
                  icon: Icon(
                    Icons.home_outlined,
                  )),
              BottomNavigationBarItem(
                  label: "Discover",
                  icon: Icon(
                    Icons.search_outlined,
                  )),
              BottomNavigationBarItem(
                  label: "Add post",
                  activeIcon: Icon(
                    Icons.add_box_rounded,
                  ),
                  icon: Icon(
                    Icons.add_box_outlined,
                  )),
              BottomNavigationBarItem(
                  label: "Messages",
                  activeIcon: Icon(
                    Icons.send_sharp,
                  ),
                  icon: Icon(
                    Icons.send_outlined,
                  )),
              BottomNavigationBarItem(
                  label: "Profile",
                  activeIcon: Icon(
                    Icons.person_2,
                  ),
                  icon: Icon(
                    Icons.person_2_outlined,
                  ))
            ]),
      ),
    );
  }
}
