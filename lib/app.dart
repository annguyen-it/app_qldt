import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '_authentication/authentication.dart';
import '_repositories/authentication_repository/authentication_repository.dart';
import '_repositories/user_repository/user_repository.dart';
import '_services/local_notification_service.dart';
import '_services/local_event_service.dart';
import '_services/token_service.dart';
import '_widgets/splash/splash.dart';
import '_widgets/user_data_model.dart';

import 'calendar/calendar.dart';
import 'home/home.dart';
import 'login/login.dart';
import 'notification/notification.dart';
import 'schedule/view/schedule_page.dart';

class Application extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  const Application({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late LocalNotificationService localNotificationService;
  late LocalEventService localEventService;

  NavigatorState? get _navigator => _navigatorKey.currentState;

  final _navigatorKey = GlobalKey<NavigatorState>();

  final _themeData = ThemeData(
    //  Brightness and colors
    brightness: Brightness.light,
    primaryColor: Color(0xff4A2A73),
    accentColor: Color(0xffF46781),
    backgroundColor: Color(0xff4A2A73),

    //  Font family
    fontFamily: 'Montserrat',

    //  Text theme
    textTheme: TextTheme(
      //  https://api.flutter.dev/flutter/material/TextTheme-class.html
      //  Headline
      headline5: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Colors.white),
      headline6: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),

      //  Body text
      bodyText1: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
      bodyText2: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
    ),
  );

  final _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final _supportedLocales = [const Locale('vi', '')];

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.authenticationRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (BuildContext context) => AuthenticationBloc(
          authenticationRepository: widget.authenticationRepository,
          userRepository: widget.userRepository,
        ),
        child: MaterialApp(
          theme: _themeData,
          navigatorKey: _navigatorKey,
          localizationsDelegates: _localizationsDelegates,
          supportedLocales: _supportedLocales,
          builder: (context, child) {
            return SafeArea(
              child: BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) async {
                  switch (state.status) {
                    case AuthenticationStatus.unauthenticated:
                      unauthenticated();
                      break;

                    case AuthenticationStatus.authenticated:
                      authenticated(state);
                      break;

                    default:
                      defaultCase();
                      break;
                  }
                },
                child: child,
              ),
            );
          },
          routes: {
            '/': (_) => SplashPage(),
            '/login': (_) => LoginPage(),
            '/home': (_) => userData(HomePage()),
            '/calendar': (_) => userData(CalendarPage()),
            '/schedule': (_) => userData(SchedulePage()),
            '/notification': (_) => userData(NotificationPage()),
          },
        ),
      ),
    );
  }

  Widget userData(Widget child) {
    return UserDataModel(
      localEventService: localEventService,
      localNotificationService: localNotificationService,
      child: child,
    );
  }

  void unauthenticated() async {
    if (ModalRoute.of(context)?.settings.name != '/') {
      _navigator!.pushNamedAndRemoveUntil('/', (_) => false);
    }

    await Future.delayed(const Duration(milliseconds: 1500), () {
      _navigator!.pushNamedAndRemoveUntil('/login', (_) => false);
    });
  }

  void authenticated(AuthenticationState state) async {
    if (ModalRoute.of(context)?.settings.name != '/') {
      _navigator!.pushNamedAndRemoveUntil('/', (_) => false);
    }

    Stopwatch stopwatch = Stopwatch()..start();
    final maxTurnAroundTime = const Duration(seconds: 2);

    /// Khởi động các service
    final tokenService = TokenService();
    await tokenService.init();
    await tokenService.upsert(state.user.id);

    localEventService = LocalEventService(state.user.id);
    localNotificationService = LocalNotificationService(state.user.id);

    await localEventService.refresh();
    await localNotificationService.refresh();

    final timeEnded = stopwatch.elapsed;

    await Future.delayed(
        timeEnded < maxTurnAroundTime ? maxTurnAroundTime - timeEnded : const Duration(seconds: 0),
        () {
      _navigator!.pushNamedAndRemoveUntil('/home', (_) => false);
    });
  }

  void defaultCase() {
    if (ModalRoute.of(context)?.settings.name != '/') {
      _navigator!.pushNamedAndRemoveUntil('/', (_) => false);
    }
  }
}
