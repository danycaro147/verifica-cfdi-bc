import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paleta "papel y sello": papel bond frío, tinta verde-negra y violeta de sello.
class Tk {
  final Color papel, hoja, tinta, grafito, linea, violeta, onVioleta;
  final Color verde, rojo, ambar, bloque, onBloque;

  const Tk._({
    required this.papel,
    required this.hoja,
    required this.tinta,
    required this.grafito,
    required this.linea,
    required this.violeta,
    required this.onVioleta,
    required this.verde,
    required this.rojo,
    required this.ambar,
    required this.bloque,
    required this.onBloque,
  });

  static const light = Tk._(
    papel: Color(0xFFF4F5F1),
    hoja: Color(0xFFFFFFFF),
    tinta: Color(0xFF1C2220),
    grafito: Color(0xFF5C6662),
    linea: Color(0xFFD9DDD6),
    violeta: Color(0xFF5A3E9E),
    onVioleta: Color(0xFFFFFFFF),
    verde: Color(0xFF1E7A4C),
    rojo: Color(0xFFB3261E),
    ambar: Color(0xFF9A6B00),
    bloque: Color(0xFF1C2220),
    onBloque: Color(0xFFFFFFFF),
  );

  static const dark = Tk._(
    papel: Color(0xFF111513),
    hoja: Color(0xFF191E1C),
    tinta: Color(0xFFE7ECE9),
    grafito: Color(0xFF9BA5A0),
    linea: Color(0xFF2A322F),
    violeta: Color(0xFFB9A6F0),
    onVioleta: Color(0xFF1C1236),
    verde: Color(0xFF5CC48D),
    rojo: Color(0xFFF2867D),
    ambar: Color(0xFFE3B44E),
    bloque: Color(0xFF242B28),
    onBloque: Color(0xFFF2F5F3),
  );

  static Tk of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

const fTexto = 'Archivo';
const fTitulo = 'ArchivoExpanded';
const fMono = 'PlexMono';

ThemeData buildTheme(Brightness b) {
  final t = b == Brightness.dark ? Tk.dark : Tk.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: t.violeta,
    onPrimary: t.onVioleta,
    secondary: t.violeta,
    onSecondary: t.onVioleta,
    error: t.rojo,
    onError: Colors.white,
    surface: t.hoja,
    onSurface: t.tinta,
    onSurfaceVariant: t.grafito,
    outline: t.grafito,
    outlineVariant: t.linea,
    surfaceContainerLowest: t.hoja,
    surfaceContainerLow: t.hoja,
    surfaceContainer: t.papel,
    surfaceContainerHigh: t.papel,
    surfaceContainerHighest: t.linea,
  );
  final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fTexto,
      splashFactory: InkRipple.splashFactory);
  const btn = TextStyle(fontFamily: fTexto, fontWeight: FontWeight.w600, fontSize: 16);

  return base.copyWith(
    scaffoldBackgroundColor: t.papel,
    textTheme: base.textTheme.apply(bodyColor: t.tinta, displayColor: t.tinta),
    appBarTheme: AppBarTheme(
      backgroundColor: t.papel,
      foregroundColor: t.tinta,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 22,
      titleTextStyle: TextStyle(
          fontFamily: fTitulo, fontWeight: FontWeight.w600, fontSize: 18, color: t.tinta),
    ),
    dividerTheme: DividerThemeData(color: t.linea, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 54),
        backgroundColor: t.violeta,
        foregroundColor: t.onVioleta,
        disabledBackgroundColor: t.linea,
        disabledForegroundColor: t.grafito,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: btn,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 54),
        foregroundColor: t.tinta,
        side: BorderSide(color: t.tinta, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: btn,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: t.violeta, textStyle: btn.copyWith(fontSize: 15)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.hoja,
      hintStyle: TextStyle(color: t.grafito.withAlpha(150)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.linea)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.linea)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.violeta, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.rojo)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.rojo, width: 2)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.hoja,
      surfaceTintColor: Colors.transparent,
      indicatorColor: t.violeta.withAlpha(32),
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? t.violeta : t.grafito)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: fTexto,
          fontSize: 12.5,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? t.violeta : t.grafito)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onVioleta : t.grafito),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.violeta : t.papel),
      trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.violeta : t.linea),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.violeta : Colors.transparent),
      checkColor: WidgetStatePropertyAll(t.onVioleta),
      side: BorderSide(color: t.grafito, width: 1.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.tinta,
      contentTextStyle: TextStyle(fontFamily: fTexto, color: t.papel, fontSize: 15),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.hoja,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: t.violeta),
  );
}

// ---------------------------------------------------------------------------
// Tipografía
// ---------------------------------------------------------------------------

TextStyle tTitulo(BuildContext c, {double size = 28}) => TextStyle(
    fontFamily: fTitulo,
    fontWeight: FontWeight.w800,
    fontSize: size,
    height: 1.1,
    letterSpacing: -.3,
    color: Tk.of(c).tinta);

TextStyle tSeccion(BuildContext c) => TextStyle(
    fontFamily: fTitulo, fontWeight: FontWeight.w600, fontSize: 16, color: Tk.of(c).tinta);

TextStyle tCuerpo(BuildContext c, {double size = 15.5, Color? color}) => TextStyle(
    fontFamily: fTexto, fontSize: size, height: 1.5, color: color ?? Tk.of(c).grafito);

TextStyle tMono(BuildContext c, {double size = 15, Color? color, FontWeight w = FontWeight.w500}) =>
    TextStyle(
        fontFamily: fMono,
        fontSize: size,
        fontWeight: w,
        height: 1.45,
        letterSpacing: .2,
        color: color ?? Tk.of(c).tinta);

// ---------------------------------------------------------------------------
// Sello de tinta: el elemento distintivo de la app
// ---------------------------------------------------------------------------

class Sello extends StatelessWidget {
  final String texto;
  final Color color;
  final String? arriba;
  final String? abajo;
  final double escala;
  final double angulo;

  const Sello({
    super.key,
    required this.texto,
    required this.color,
    this.arriba,
    this.abajo,
    this.escala = 1,
    this.angulo = -.2,
  });

  @override
  Widget build(BuildContext context) {
    final s = escala;
    final small = TextStyle(
        fontFamily: fTexto,
        fontWeight: FontWeight.w700,
        fontSize: 9.5 * s,
        letterSpacing: 1.6 * s,
        color: color);
    return Transform.rotate(
      angle: angulo,
      child: Opacity(
        opacity: .92,
        child: Container(
          padding: EdgeInsets.all(2.5 * s),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3.2 * s),
            borderRadius: BorderRadius.circular(12 * s),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 5 * s),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.4 * s),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (arriba != null) Text(arriba!, style: small),
                Text(texto,
                    style: TextStyle(
                        fontFamily: fTitulo,
                        fontWeight: FontWeight.w800,
                        fontSize: 26 * s,
                        letterSpacing: 2.6 * s,
                        height: 1.15,
                        color: color)),
                if (abajo != null) Text(abajo!, style: small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sello pequeño para listas.
class SelloChico extends StatelessWidget {
  final String texto;
  final Color color;
  const SelloChico({super.key, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -.07,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.8),
              borderRadius: BorderRadius.circular(6)),
          child: Text(texto,
              style: TextStyle(
                  fontFamily: fTitulo,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: .9,
                  color: color)),
        ),
      );
}

/// Animación de "golpe de sello": una sola vez al mostrar el resultado.
class SelloAnimado extends StatefulWidget {
  final Widget child;
  const SelloAnimado({super.key, required this.child});

  @override
  State<SelloAnimado> createState() => _SelloAnimadoState();
}

class _SelloAnimadoState extends State<SelloAnimado> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = Curves.easeOutBack.transform(_c.value);
          return Opacity(
            opacity: _c.value.clamp(0, 1),
            child: Transform.scale(scale: 1.7 - .7 * v, child: child),
          );
        },
        child: widget.child,
      );
}

// ---------------------------------------------------------------------------
// Hoja de comprobante con bordes de ticket
// ---------------------------------------------------------------------------

class _Festoneado extends CustomClipper<Path> {
  static const double r = 7;
  const _Festoneado();

  @override
  Path getClip(Size s) {
    final p = Path();
    final step = r * 2.6;
    final n = (s.width / step).floor();
    final off = (s.width - n * step) / 2;
    p.moveTo(0, 0);
    for (var i = 0; i < n; i++) {
      final cx = off + i * step + step / 2;
      p.lineTo(cx - r, 0);
      p.arcToPoint(Offset(cx + r, 0), radius: Radius.circular(r), clockwise: false);
    }
    p.lineTo(s.width, 0);
    p.lineTo(s.width, s.height);
    for (var i = n - 1; i >= 0; i--) {
      final cx = off + i * step + step / 2;
      p.lineTo(cx + r, s.height);
      p.arcToPoint(Offset(cx - r, s.height), radius: Radius.circular(r), clockwise: false);
    }
    p.lineTo(0, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> o) => false;
}

class HojaComprobante extends StatelessWidget {
  final Widget child;
  const HojaComprobante({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return ClipPath(
      clipper: const _Festoneado(),
      child: Container(
        color: t.hoja,
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra inferior fija y otros elementos
// ---------------------------------------------------------------------------

class BarraAcciones extends StatelessWidget {
  final List<Widget> children;
  final Widget? arriba;
  const BarraAcciones({super.key, required this.children, this.arriba});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return Container(
      decoration: BoxDecoration(
          color: t.hoja, border: Border(top: BorderSide(color: t.linea))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (arriba != null) arriba!,
              Row(children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: children[i]),
                ]
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renglón de dato: etiqueta a la izquierda, valor a la derecha, línea abajo.
class Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color? color;
  final bool mono;
  const Dato(this.etiqueta, this.valor, {super.key, this.color, this.mono = false});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.linea))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: Text(etiqueta, style: tCuerpo(context, size: 15))),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(valor,
                textAlign: TextAlign.right,
                style: mono
                    ? tMono(context, size: 14.5, color: color)
                    : TextStyle(
                        fontFamily: fTexto,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color ?? t.tinta,
                        height: 1.45)),
          ),
        ],
      ),
    );
  }
}

/// Recuadro de aviso.
class Aviso extends StatelessWidget {
  final String texto;
  final Color? color;
  final IconData icono;
  final Widget? accion;
  const Aviso(
      {super.key,
      required this.texto,
      this.color,
      this.icono = Icons.info_outline,
      this.accion});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    final c = color ?? t.grafito;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: c.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: c, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: tCuerpo(context, size: 14, color: t.tinta)),
                if (accion != null) accion!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Esquinas de visor de cámara.
class Visor extends StatelessWidget {
  final double size;
  final Color color;
  final bool linea;
  const Visor({super.key, this.size = 120, this.color = Colors.white, this.linea = true});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _VisorPainter(color, linea)),
      );
}

class _VisorPainter extends CustomPainter {
  final Color color;
  final bool linea;
  _VisorPainter(this.color, this.linea);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final l = s.width * .24;
    const r = 10.0;
    for (var i = 0; i < 4; i++) {
      c.save();
      c.translate(s.width / 2, s.height / 2);
      c.rotate(i * math.pi / 2);
      c.translate(-s.width / 2, -s.height / 2);
      final path = Path()
        ..moveTo(0, l)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(l, 0);
      c.drawPath(path, p);
      c.restore();
    }
    if (linea) {
      c.drawLine(Offset(s.width * .14, s.height / 2), Offset(s.width * .86, s.height / 2),
          Paint()
            ..color = const Color(0xFFB9A6F0)
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _VisorPainter o) => o.color != color;
}
