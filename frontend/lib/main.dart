import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/core/network/change_password_service.dart';
import 'package:flutterproject/core/network/user_service.dart';
import 'package:flutterproject/data/repositories/change_password_repository.dart';
import 'package:flutterproject/data/repositories/user_repository.dart';
import 'package:flutterproject/data/usecases/change_password_usecase.dart';
import 'package:flutterproject/data/usecases/get_all_users_usecase.dart';
import 'package:flutterproject/viewmodel/change_password_viewmodel.dart';
import 'package:flutterproject/viewmodel/user_viewmodel.dart';
import 'package:flutterproject/views/change_password_screen.dart';
import 'package:flutterproject/ui/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/utils/shared_preferences_helper.dart'; // Import the helper class

// Core Network Services
import 'package:flutterproject/core/network/api_service.dart';
import 'package:flutterproject/core/network/main_services.dart';
import 'package:flutterproject/core/network/device_services.dart';
import 'package:flutterproject/core/network/signin_service.dart';
import 'package:flutterproject/core/network/signup_service.dart';
import 'package:flutterproject/core/network/delete_user_service.dart';

// Data Repositories
import 'package:flutterproject/data/repositories/api_repository.dart';
import 'package:flutterproject/data/repositories/device_repository.dart';
import 'package:flutterproject/data/repositories/signin_repository.dart';
import 'package:flutterproject/data/repositories/signup_repository.dart';
import 'package:flutterproject/data/repositories/main_repository.dart';
import 'package:flutterproject/data/repositories/delete_user_repository.dart';

// Use Cases
import 'package:flutterproject/data/usecases/add_device_usecase.dart';
import 'package:flutterproject/data/usecases/fetch_devices_usecase.dart';
import 'package:flutterproject/data/usecases/get_inverter_data_usecase.dart';
import 'package:flutterproject/data/usecases/signin_usecase.dart';
import 'package:flutterproject/data/usecases/signup_usecase.dart';
import 'package:flutterproject/data/usecases/delete_user_usecase.dart';

// ViewModels
import 'package:flutterproject/viewmodel/add_device_viewmodel.dart';
import 'package:flutterproject/viewmodel/devices_viewmodel.dart';
import 'package:flutterproject/viewmodel/main_viewmodel.dart';
import 'package:flutterproject/viewmodel/signin_viewmodel.dart';
import 'package:flutterproject/viewmodel/signup_viewmodel.dart';
import 'package:flutterproject/viewmodel/delete_user_viewmodel.dart';

// Views
import 'package:flutterproject/views/signup_screen.dart';
import 'package:flutterproject/views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Initializing App...");

  String initialRoute = await _getInitialRoute();
  debugPrint("Determined initial route: $initialRoute");

  // Initialize Core Services
  final apiService = ApiService();
  final mainService = MainServices();
  final deviceService = DeviceServices();
  final signinService = SigninService();
  final signupService = SignupService();
  final deleteUserService = DeleteUserService();
  final changePasswordService = ChangePasswordService();
  final userService = UserService();

  // Initialize Repositories
  final signinRepository = SigninRepository(signinService);
  final signupRepository = SignupRepository(signupService);
  final mainRepository = MainRepository(mainService);
  final deviceRepository = DeviceRepository(deviceService);
  final apiRepository = ApiRepository(apiService);
  final deleteUserRepository = DeleteUserRepository(deleteUserService);
  final changePasswordRepository =
      ChangePasswordRepository(changePasswordService);
  final userRepository = UserRepository(userService);

  // Initialize Use Cases
  final signinUseCase = SigninUseCase(signinRepository);
  final signupUseCase = SignupUseCase(signupRepository);
  final fetchDevicesUseCase = FetchDevicesUseCase(apiRepository);
  final addDeviceUseCase = AddDeviceUseCase(deviceRepository);
  final getInverterDataUseCase = GetInverterDataUseCase(mainRepository);
  final deleteUserUseCase = DeleteUserUseCase(deleteUserRepository);
  final changePasswordUseCase = ChangePasswordUseCase(changePasswordRepository);
  final getAllUserUseCase = GetAllUsersUseCase(userRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel(signupUseCase)),
        ChangeNotifierProvider(create: (_) => SigninViewModel(signinUseCase)),
        ChangeNotifierProvider(
            create: (_) => AddDeviceViewModel(addDeviceUseCase)),
        ChangeNotifierProvider(
            create: (_) => MainViewModel(getInverterDataUseCase)),
        ChangeNotifierProvider(
            create: (_) => DevicesViewModel(fetchDevicesUseCase)),
        ChangeNotifierProvider(
            create: (_) => DeleteUserViewModel(deleteUserUseCase)),
        ChangeNotifierProvider(
            create: (_) => ChangePasswordViewModel(changePasswordUseCase)),
        ChangeNotifierProvider(create: (_) => UserViewModel(getAllUserUseCase)),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building MyApp with initial route: $initialRoute");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      title: 'Flutter App',
      home: initialRoute == 'main' ? MainScreen() : SignupScreen(),
    );
  }
}

// Function to check stored token and determine initial route
Future<String> _getInitialRoute() async {
  debugPrint("Checking for stored token...");

  String? token = await SharedPreferencesHelper.getToken();

  if (token != null && token.isNotEmpty) {
    debugPrint("Token found: $token");
    return 'main'; // Navigate to MainScreen
  } else {
    debugPrint("No token found. Navigating to SignupScreen.");
    return 'signup'; // Navigate to SignupScreen
  }
}
