import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/product_list/product_list_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'screens/product_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProductAssessmentApp());
}

class ProductAssessmentApp extends StatelessWidget {
  const ProductAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ProductListBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Product Catalog',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            builder: (context, child) {
              final theme = Theme.of(context);
              final overlay = theme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlay.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: theme.scaffoldBackgroundColor,
                ),
                child: child!,
              );
            },
            home: const ProductListScreen(),
          );
        },
      ),
    );
  }
}
