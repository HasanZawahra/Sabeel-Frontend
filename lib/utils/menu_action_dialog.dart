import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/enums/menu_actions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/logout_dialog.dart';

PopupMenuButton<MenuAction> menuActionDialog(BuildContext context) {
  return PopupMenuButton<MenuAction>(
    icon: Semantics(
      label: 'Menu button',
      child: Icon(Icons.menu, size: 35),
    ),
    onSelected: (value) async {
      switch (value) {
        case MenuAction.logout:
          final shouldUserLogOut = await showLogoutDialog(context);
          if (shouldUserLogOut) {
            await AuthService.firebase().logOut();
            context.go(idVerificationRoute);
          }
          break;
      }
    },
    itemBuilder: (context) {
      return [
        PopupMenuItem<MenuAction>(
          value: MenuAction.logout,
          child: Semantics(
            label: 'Log Out option',
            child: Text("Log Out"),
          ),
        ),
      ];
    },
  );
}