import 'package:flutter/material.dart';

import '../../constants.dart';

class AddPostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function() goBack;
  const AddPostAppBar({super.key, required this.goBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          splashColor: Colors.transparent,
          onPressed: goBack,
          icon: const Icon(Icons.close)),
      elevation: 0,
      backgroundColor: AppColors.bottomBar,
      title: const Text(
        'New post',
        style: AppTextStyles.primaryTextStyle,
      ),
    );
  }
}
