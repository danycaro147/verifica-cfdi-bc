// Lista 69-B del SAT (contribuyentes con operaciones presuntamente inexistentes).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sat.dart';

enum Situacion { definitivo, presunto, desvirtuado, sentenciaFavorable, otra }

class RegistroEfos {
  final String rfc;
  final String nombre;
  final String situacionTexto;
  final String fecha; // última publicación relevante, si se conoce

  RegistroEfos(this.rfc, this.nombre, this.situacionTexto, this.fecha);

  Situacion get situacion {
    final s = situacionTexto.toLowerCase();
    if (s.contains('definitiv')) return Situacion.definitivo;
    if (s.contains('presunt')) return Situacion.presunto;
    if (s.contains('desvirtu')) return Situacion.desvirtuado;
    if (s.contains('favorable')) return Situacion.sentenciaFavorable;
    return Situacion.otra;
  }

  /// ¿Representa un riesgo para deducir facturas de este emisor?
  bool get riesgo =>
      situacion == Situacion.definitivo || situacion == Situacion.presunto;
}

class ListaEfos {
  final String actualizado; // fecha de descarga (AAAA-MM-DD)
  final String fuente;
  final Map<String, RegistroEfos> registros;

  ListaEfos(this.actualizado, this.fuente, this.registros);

  RegistroEfos? buscar(String rfc) => registros[normalizaRfc(rfc)];

  int get total => registros.length;

  String get actualizadoLegible {
    final p = actualizado.split('-');
    if (p.length != 3) return actualizado;
    const m = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
      'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${int.parse(p[2])} de ${m[int.parse(p[1]) - 1]} de ${p[0]}';
  }
}

ListaEfos _parse(String raw) {
  final j = jsonDecode(raw) as Map<String, dynamic>;
  final regs = <String, RegistroEfos>{};
  for (final e in (j['r'] as List)) {
    final l = (e as List).cast<String>();
    regs[l[0]] = RegistroEfos(l[0], l[1], l[2], l.length > 3 ? l[3] : '');
  }
  return ListaEfos(j['actualizado'] as String? ?? '', j['fuente'] as String? ?? '', regs);
}

class EfosRepo {
  static Future<ListaEfos>? _f;
  static ListaEfos? actual;

  static Future<ListaEfos> cargar() => _f ??= () async {
        final raw = await rootBundle.loadString('assets/efos/efos.json');
        final l = await compute(_parse, raw);
        actual = l;
        return l;
      }();
}
