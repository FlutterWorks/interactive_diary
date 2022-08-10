import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nartus_ui_package/nartus_ui.dart';
import 'package:interactive_diary/route/map_route.dart' as routes;
import 'package:firebase_core/firebase_core.dart';
import 'package:interactive_diary/firebase_options.dart';
import 'package:interactive_diary/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(App.adaptive(
    home: const IDHome(),
    title: 'Interactive Diary',
    theme: Theme(primaryColor: Colors.deepOrange),
    routes: routes.appRoute,
  ));
}
