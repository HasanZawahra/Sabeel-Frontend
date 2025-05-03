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
      child: Icon(Icons.menu, size: 35, color: Colors.black), // Styled menu icon
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Rounded corners for the menu
    ),
    color: const Color.fromARGB(255, 255, 244, 218), // Background color for the menu
    itemBuilder: (context) {
      return [
        PopupMenuItem<MenuAction>(
          value: MenuAction.discoverMoreMaps,
          child: Semantics(
            label: 'Discover more maps option',
            child: Text(
              "Discover More Maps",
              style: TextStyle(
                fontSize: 18, // Font size for the menu item
                fontWeight: FontWeight.w700, // Bold text
                color: Colors.black, // Text color for the menu item
              ),
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.logout,
          child: Semantics(
            label: 'Log Out option',
            child: Text(
              "Log Out",
              style: TextStyle(
                fontSize: 18, // Font size for the menu item
                fontWeight: FontWeight.w700, // Bold text
                color: Colors.red, // Text color for the menu item
              ),
            ),
          ),
        ),
      ];
    },
    onSelected: (value) async {
      switch (value) {
        case MenuAction.logout:
          final shouldUserLogOut = await showLogoutDialog(context);
          if (shouldUserLogOut) {
            await AuthService.firebase().logOut();
            context.go(idVerificationRoute);
          }

          case MenuAction.discoverMoreMaps:
          context.go(mapDownloadRoute);

          break;
      }
    },
  );
}