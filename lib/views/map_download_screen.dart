import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/maps_names.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/menu_action_dialog.dart';

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
      final name = maps_names[i].split('_').join(' ');
      maps.add(
      Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
        child:  Semantics(
            label: 'Map of ${maps_names[i].split('_').join(' ')}',
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                context.go(mapDownloadProgressRoute);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: '$name map',
                    child: Text(
                      name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Semantics(
                    label: '$name logo',
                    child: Image.asset(
                      'assets/maps_logos/${maps_names[i].split(' ').join('_')}.png',
                      height: 55,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            ? Semantics(
              label: 'Back',
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go(idVerificationRoute);
                  },
                ),
            )
            : null,
        actions: [
          if (AuthService.firebase().currentUser != null)
            menuActionDialog(context)
        ],
      ),
      
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'University Map title',
              child: Text(
                "Choose a Map",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Semantics(
              label: 'Instruction text, Choose the Desired Map.',
              child: Text(
                "Choose the Desired Map.",
                style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 127, 127, 127)),
              ),
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