import 'package:flutter/material.dart';
import 'package:sabeel/constants/maps_names.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/enums/menu_actions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/views/home_screen.dart';

class MapDownloadScreen extends StatefulWidget {
  const MapDownloadScreen({super.key});

  @override
  State<MapDownloadScreen> createState() => _MapDownloadScreenState();
}

class _MapDownloadScreenState extends State<MapDownloadScreen> {
  int size = maps_names.length;
  List<Container> maps = [];
  
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < size; i++) {
      maps.add(
      Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
        child:  TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () { 
          Navigator.of(context).pushNamedAndRemoveUntil(mapDownloadProgressRoute, (route) => false); 
          },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              maps_names[i].split('_').join(' '),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Image.network(
              'assets/maps_logos/${maps_names[i]}.png',
              height: 55,
            ),
          ],
        ),
      )
      ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: AuthService.firebase().currentUser == null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 35,
              )
            : null,
        actions: [
          if (AuthService.firebase().currentUser != null)
            PopupMenuButton<MenuAction>(
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
                })
        ],
      ),
      
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "University Map",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Choose the Map of the Desired University.",
              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 127, 127, 127)),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
            
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: maps,
                ),
              
            ),
          ],
        ),
      ),
    );
  }
}