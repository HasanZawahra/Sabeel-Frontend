import 'package:flutter/material.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/enums/menu_actions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/logout_dialog.dart';

PopupMenuButton<MenuAction> menuActionDialog(BuildContext context) {
  return PopupMenuButton<MenuAction>(
          icon: Icon(Icons.menu, size: 35,), // Change the icon to a burger menu
          onSelected: (value) async {
            switch (value) {
          case MenuAction.logout:
            final shouldUserLogOUt = await showLogoutDialog(context);
            if (shouldUserLogOUt) {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
              idVerificationRoute, (route) => false);
            }
            break;
            }
          },
          itemBuilder: (context) {
            return const [
          PopupMenuItem<MenuAction>(
              value: MenuAction.logout, child: Text("Log Out"))
            ];
          },
        );
}