import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sat.dart';

/// Puente con Android: preferencias, abrir enlaces y compartir.
class Native {
  static const channel = MethodChannel('app/native');

  static Future<Map<String, dynamic>> prefs() async =>
      (await channel.invokeMapMethod<String, dynamic>('getPrefs')) ?? {};

  static Future<void> setString(String k, String v) =>
      channel.invokeMethod('setString', {'key': k, 'value': v});

  static Future<bool> openUrl(String url) async =>
      (await channel.invokeMethod<bool>('openUrl', {'url': url})) ?? false;

  static Future<void> share(String text) =>
      channel.invokeMethod('share', {'text': text});
}

class Consulta {
  final Cfdi cfdi;
  final RespuestaSat respuesta;
  Consulta(this.cfdi, this.respuesta);

  Map<String, dynamic> toJson() => {'c': cfdi.toJson(), 'r': respuesta.toJson()};
  factory Consulta.fromJson(Map m) =>
      Consulta(Cfdi.fromJson(m['c'] as Map), RespuestaSat.fromJson(m['r'] as Map));
}

/// Estado global: tema, aviso legal, historial y promoción.
class AppState extends ChangeNotifier {
  static const termsVersion = '1';
  static const maxHistorial = 50;

  bool loaded = false;
  ThemeMode themeMode = ThemeMode.system;
  bool termsAccepted = false;
  int promoHiddenUntil = 0;
  String appVersion = '';
  List<Consulta> historial = [];

  Future<void> load() async {
    try {
      final p = await Native.prefs();
      themeMode = switch (p['themeMode']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      termsAccepted = p['termsAccepted'] == termsVersion;
      promoHiddenUntil = int.tryParse('${p['promoHiddenUntil'] ?? 0}') ?? 0;
      appVersion = (p['appVersion'] ?? '') as String;
      final h = p['historial'];
      if (h is String && h.isNotEmpty) {
        historial = (jsonDecode(h) as List)
            .map((e) => Consulta.fromJson(e as Map))
            .toList();
      }
    } catch (_) {}
    loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    notifyListeners();
    await Native.setString('themeMode', m.name);
  }

  Future<void> acceptTerms() async {
    termsAccepted = true;
    notifyListeners();
    await Native.setString('termsAccepted', termsVersion);
  }

  Future<void> agregar(Consulta c) async {
    historial = [
      c,
      ...historial.where((x) => x.cfdi.uuid != c.cfdi.uuid),
    ].take(maxHistorial).toList();
    notifyListeners();
    await _guardar();
  }

  Future<void> borrarHistorial() async {
    historial = [];
    notifyListeners();
    await _guardar();
  }

  Future<void> _guardar() => Native.setString(
      'historial', jsonEncode(historial.map((e) => e.toJson()).toList()));

  bool get showPromo => DateTime.now().millisecondsSinceEpoch > promoHiddenUntil;

  Future<void> hidePromo() async {
    promoHiddenUntil =
        DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    notifyListeners();
    await Native.setString('promoHiddenUntil', '$promoHiddenUntil');
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
