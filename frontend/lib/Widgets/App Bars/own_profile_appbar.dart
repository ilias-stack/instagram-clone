import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Profile%20related/saved_posts_page.dart';
import 'package:frontend/constants.dart';

import '../../Pages/Connection Pages/login_page.dart';
import '../../Pages/Main Pages/own_profile_page.dart';
import '../../Pages/Secondary Pages/Profile related/edit_profile.dart';
import '../../Pages/Secondary Pages/Profile related/profile_settings.dart';
import 'package:http/http.dart';

class OwnProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<OwnProfilePageState> profilePageState;
  const OwnProfileAppBar({super.key, required this.profilePageState});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () => showModalBottomSheet(
                backgroundColor: AppColors.backgroundColor,
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          minLeadingWidth: 9,
                          splashColor: const Color.fromARGB(255, 8, 8, 8),
                          leading: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Edit profile',
                            style: AppTextStyles.primaryTextStyle,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfile(),
                            ),
                          ).then((value) {
                            profilePageState.currentState!.refreshPage();
                            Navigator.pop(context);
                          }),
                        ),
                        ListTile(
                          minLeadingWidth: 9,
                          splashColor: const Color.fromARGB(255, 0, 0, 0),
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Profile settings',
                            style: AppTextStyles.primaryTextStyle,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettings(),
                            ),
                          ).then((value) => Navigator.pop(context)),
                        ),
                        ListTile(
                          minLeadingWidth: 9,
                          splashColor: const Color.fromARGB(255, 8, 8, 8),
                          leading: const Icon(
                            Icons.archive_outlined,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Saved posts',
                            style: AppTextStyles.primaryTextStyle,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedPostsPage(),
                            ),
                          ).then((value) => Navigator.pop(context)),
                        ),
                        const Divider(),
                        ListTile(
                          iconColor: const Color.fromARGB(255, 255, 178, 173),
                          minLeadingWidth: 9,
                          splashColor: const Color.fromARGB(255, 0, 0, 0),
                          leading: const Icon(
                            Icons.logout,
                          ),
                          title: Text(
                            'Logout',
                            style: AppTextStyles.primaryTextStyle.copyWith(
                                color:
                                    const Color.fromARGB(255, 255, 178, 173)),
                          ),
                          onTap: () async {
                            await get(
                                Uri.parse(
                                    'http://$serverIpAddress:5000/user/logout'),
                                headers: {
                                  "Cookie": prefs.getString('cookie') ?? ''
                                });
                            User.emptyInformationFields();
                            await prefs.remove('cookie');

                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            CoreMethods.redirectToPage(
                                context, const LoginPage());
                          },
                        ),
                      ],
                    )),
            icon: const Icon(Icons.menu))
      ],
      elevation: 0,
      backgroundColor: AppColors.bottomBar,
      title: Text(
        User.userName!,
        style: AppTextStyles.primaryTextStyle,
      ),
    );
  }
}
