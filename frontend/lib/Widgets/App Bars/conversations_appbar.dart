import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';

import '../../constants.dart';

class ConversationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final void Function() goBack;
  const ConversationsAppBar({super.key, required this.goBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          splashColor: Colors.transparent,
          onPressed: goBack,
          icon: const Icon(Icons.arrow_back)),
      elevation: 0,
      backgroundColor: AppColors.bottomBar,
      title: Text(
        User.userName!,
        style: AppTextStyles.primaryTextStyle,
      ),
    );
  }
}
