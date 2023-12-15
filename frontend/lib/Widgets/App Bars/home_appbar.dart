import 'package:flutter/material.dart';
import 'package:frontend/Pages/Secondary%20Pages/Home%20related/add_users_page.dart';

import '../../constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bottomBar,
      actions: [
        IconButton(
            splashColor: Colors.transparent,
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddUsersPage(),
                  ),
                ),
            icon: const Icon(Icons.person_add_alt_1_outlined))
      ],
      elevation: 0,
      centerTitle: true,
      title: SizedBox(
        width: MediaQuery.of(context).size.width / 1.9,
        child: Image.asset(
          'assets/images/WhiteTextLogo.png',
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
