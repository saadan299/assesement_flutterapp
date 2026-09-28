import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_assessment_app/blocs/theme/theme_cubit.dart';
import 'package:product_assessment_app/screens/product_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:product_assessment_app/main.dart';
import 'package:product_assessment_app/services/product_service.dart';
import 'package:product_assessment_app/widgets/product_card.dart';
import 'package:product_assessment_app/widgets/safe_network_image.dart';
import 'package:product_assessment_app/screens/image_viewer_screen.dart';

void main() {
  testWidgets(
    'Capture list and detail screens with live DummyJSON data',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final oldOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = oldOverrides);
      final key = GlobalKey();
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);

      await tester.runAsync(() async {
        final font = FontLoader('Plus Jakarta Sans')
          ..addFont(
            rootBundle.load('assets/fonts/PlusJakartaSans-Variable.ttf'),
          );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        final response = await ProductService().fetchProducts();
        final first = await ProductService().fetchProductDetail(
          response.products.first.id,
        );
        final urls = {
          ...response.products.map((p) => p.thumbnail),
          ...first.galleryImages,
          if (first.hasQrCode) first.qrCode!,
        };
        for (final url in urls.where((url) => url.isNotEmpty)) {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) {
            throw Exception('Image unavailable: $url');
          }
          final codec = await ui.instantiateImageCodec(response.bodyBytes);
          final frame = await codec.getNextFrame();
          final provider = CachedNetworkImageProvider(url);
          final imageKey = await provider.obtainKey(ImageConfiguration.empty);
          PaintingBinding.instance.imageCache.putIfAbsent(
            imageKey,
            () => OneFrameImageStreamCompleter(
              Future.value(ImageInfo(image: frame.image)),
            ),
          );
          codec.dispose();
        }
      });

      Future<void> settleNetwork() async {
        for (var i = 0; i < 25; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 200)),
          );
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(tester.takeException(), isNull);
      }

      Future<void> capture(String name) async {
        await tester.pump();
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/screenshots/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        debugPrint('Captured $name');
      }

      await tester.runAsync(() async {
        await tester.pumpWidget(
          RepaintBoundary(key: key, child: const ProductAssessmentApp()),
        );
      });
      await settleNetwork();
      expect(find.byType(ProductCard), findsWidgets);
      await capture('catalog-light');
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await settleNetwork();
      await capture('catalog-dark');
      await tester.runAsync(() async {
        await tester.tap(find.text('Filter'));
        await tester.pump();
      });
      await settleNetwork();
      expect(
        find.textContaining(RegExp(r'Show results \(\d+\)')),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byType(ProductCard).first);
        await tester.pump();
      });
      await settleNetwork();
      expect(find.text('Description'), findsOneWidget);
      await capture('details-light');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -480));
      await tester.pumpAndSettle();
      tester
          .element(find.byType(ProductDetailScreen))
          .read<ThemeCubit>()
          .setMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 900));
      await tester.pumpAndSettle();
      await settleNetwork();
      await capture('details-dark');
      await tester.tap(find.byType(SafeNetworkImage).first);
      await tester.pumpAndSettle();
      expect(find.byType(ImageViewerScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDisableShadows = true;
    },
    skip: !const bool.fromEnvironment('CAPTURE_SCREENSHOTS'),
  );
}
