import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'models.dart';
import 'screens/builder_screen.dart';
import 'screens/nutrition_screen.dart';
import 'theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Menu.load();
  final meal = Meal();
  await meal.restore();

  FlutterNativeSplash.remove();
  runApp(BjsApp(meal: meal));
}

class BjsApp extends StatelessWidget {
  final Meal meal;
  const BjsApp({super.key, required this.meal});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BJ’s Meal Builder',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: Home(meal: meal),
      );
}

class Home extends StatefulWidget {
  final Meal meal;
  const Home({super.key, required this.meal});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          ClipOval(
            child: Image.asset(
              'assets/branding/app_icon.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.red, width: 2)),
                alignment: Alignment.center,
                child: Text('BJ', style: serif(14, c: C.red)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BJ’s', style: serif(18, c: C.red)),
            const Text('Menu Guide', style: TextStyle(fontSize: 11, color: C.ink, fontWeight: FontWeight.w600)),
          ]),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: C.line)),
      ),
      body: IndexedStack(index: tab, children: [
        BuilderScreen(meal: widget.meal),
        NutritionScreen(meal: widget.meal),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Meal Builder'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: 'Nutrition'),
        ],
      ),
    );
  }
}
