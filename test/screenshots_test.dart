// Capturas para la Play Store: flutter test --update-goldens test/screenshots_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifica_cfdi/app_state.dart';
import 'package:verifica_cfdi/consulta.dart';
import 'package:verifica_cfdi/efos.dart';
import 'package:verifica_cfdi/home.dart';
import 'package:verifica_cfdi/main.dart';
import 'package:verifica_cfdi/sat.dart';
import 'package:verifica_cfdi/welcome.dart';

Future<void> fuentes() async {
  Future<void> fam(String f, List<String> files) async {
    final l = FontLoader(f);
    for (final x in files) {
      l.addFont(rootBundle.load('assets/fonts/$x'));
    }
    await l.load();
  }

  await fam('Archivo', ['Archivo-Regular.ttf', 'Archivo-Medium.ttf', 'Archivo-SemiBold.ttf', 'Archivo-Bold.ttf']);
  await fam('ArchivoExpanded', ['ArchivoExpanded-SemiBold.ttf', 'ArchivoExpanded-ExtraBold.ttf']);
  await fam('PlexMono', ['PlexMono-Regular.ttf', 'PlexMono-Medium.ttf', 'PlexMono-SemiBold.ttf']);
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final f = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (f.existsSync()) {
      await (FontLoader('MaterialIcons')
            ..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync()))))
          .load();
    }
  }
}

RespuestaSat resp(Estado e, String texto, {int dias = 0}) => RespuestaSat(
    codigo: 'S - Comprobante obtenido satisfactoriamente.',
    estado: e,
    estadoTexto: texto,
    esCancelable: e == Estado.cancelado ? 'No cancelable' : 'Cancelable con aceptación',
    estatusCancelacion: e == Estado.cancelado ? 'Cancelado sin aceptación' : '',
    validacionEfos: '200',
    fecha: DateTime(2026, 10, 31, 10, 24).subtract(Duration(days: dias)));

const c1 = Cfdi(
    uuid: '5F8A2C1E-3B7D-4E90-A1C2-7F3E9B0D4A21',
    rfcEmisor: 'PLU150312AB4',
    rfcReceptor: 'BME200114K29',
    total: '4872.00');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await fuentes();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(Native.channel, (call) async {
      if (call.method == 'getPrefs') return {'termsAccepted': '1', 'appVersion': '1.0.0'};
      return null;
    });
  });

  Future<void> shoot(WidgetTester t, String name, Widget home,
      {ThemeMode mode = ThemeMode.light}) async {
    t.view.physicalSize = const Size(1080, 1920);
    t.view.devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    debugDisableShadows = false;
    final s = AppState();
    await t.runAsync(() async {
      await s.load();
      await EfosRepo.cargar();
    });
    s.themeMode = mode;
    s.historial = [
      Consulta(c1, resp(Estado.vigente, 'Vigente')),
      Consulta(
          const Cfdi(
              uuid: 'A1B2C3D4-0000-4E90-A1C2-7F3E9B0D4A21',
              rfcEmisor: 'SDE190801K21',
              rfcReceptor: 'BME200114K29',
              total: '18500.00'),
          resp(Estado.cancelado, 'Cancelado', dias: 2)),
      Consulta(
          const Cfdi(
              uuid: 'B1B2C3D4-0000-4E90-A1C2-7F3E9B0D4A21',
              rfcEmisor: 'GOC200115TT9',
              rfcReceptor: 'BME200114K29',
              total: '2310.40'),
          resp(Estado.vigente, 'Vigente', dias: 5)),
    ];
    await t.pumpWidget(VerificaApp(state: s, debugHome: home));
    await t.pumpAndSettle();
    await t.runAsync(() async {
      await precacheImage(const AssetImage('assets/images/braincode_isotipo.png'),
          t.element(find.byType(Scaffold).first));
    });
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('../store/screenshots/$name.png'));
    debugDisableShadows = true;
  }

  String rfcRiesgo() {
    final l = EfosRepo.actual!;
    return l.registros.values.firstWhere((r) => r.situacion == Situacion.definitivo).rfc;
  }

  testWidgets('01 inicio', (t) => shoot(t, '01_inicio', const HomeShell()));
  testWidgets('02 vigente', (t) => shoot(t, '02_vigente',
      ResultScreen(cfdi: c1, inicial: resp(Estado.vigente, 'Vigente'))));
  testWidgets('03 cancelado', (t) => shoot(
      t,
      '03_cancelado',
      ResultScreen(
          cfdi: const Cfdi(
              uuid: 'A1B2C3D4-0000-4E90-A1C2-7F3E9B0D4A21',
              rfcEmisor: 'SDE190801K21',
              rfcReceptor: 'BME200114K29',
              total: '18500.00'),
          inicial: resp(Estado.cancelado, 'Cancelado'))));
  testWidgets('04 proveedor', (t) async {
    await t.runAsync(() => EfosRepo.cargar());
    await shoot(t, '04_proveedor', Scaffold(body: SafeArea(child: ProveedoresTab(rfcInicial: rfcRiesgo()))));
  });
  testWidgets('05 captura', (t) => shoot(t, '05_captura', const ManualScreen()));
  testWidgets('06 bienvenida', (t) => shoot(t, '06_bienvenida', const WelcomeScreen()));
  testWidgets('07 oscuro', (t) => shoot(t, '07_vigente_oscuro',
      ResultScreen(cfdi: c1, inicial: resp(Estado.vigente, 'Vigente')), mode: ThemeMode.dark));
  testWidgets('08 inicio oscuro',
      (t) => shoot(t, '08_inicio_oscuro', const HomeShell(), mode: ThemeMode.dark));
}
