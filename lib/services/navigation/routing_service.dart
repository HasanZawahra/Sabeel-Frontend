import 'package:go_router/go_router.dart';
import 'package:sabeel/views/camera_screen.dart';
import 'package:sabeel/views/home_screen.dart';
import 'package:sabeel/views/id_verification_screen.dart';
import 'package:sabeel/views/map_download_screen.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/views/map_downloading_progress_screen.dart';
import 'package:sabeel/views/sos_video_revording.dart';
import 'package:sabeel/views/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: splashScreenRoute,
    routes: [
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: idVerificationRoute,
        builder: (context, state) => IdVerificationScreen(),
      ),
      GoRoute(
        path: mapDownloadRoute,
        builder: (context, state) => const MapDownloadScreen(),
      ),
      GoRoute(
        path: mapDownloadProgressRoute,
        builder: (context, state) => MapDownloadingProgress(),
      ),
      GoRoute(
        path: cameraScreenRoute,
        builder: (context, state) => CameraScreen(),
      ),
      GoRoute(
        path: splashScreenRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: videoRecorderRoute,
        builder: (context, state) => const VideoRecorderScreen(),
      )
    ],
  );
}
