import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'consulta.dart';
import 'efos.dart';
import 'legal.dart';
import 'sat.dart';
import 'theme.dart';

class HomeShell extends StatefulWidget {
  final int initialTab;
  const HomeShell({super.key, this.initialTab = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _tab, children: [
          FacturasTab(onRevisarRfc: () => setState(() => _tab = 1)),
          const ProveedoresTab(),
          const AjustesTab(),
        ]),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.linea))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Facturas'),
            NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Proveedores'),
            NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}

(String, Color) selloDe(Tk t, Estado e) => switch (e) {
      Estado.vigente => ('VIGENTE', t.verde),
      Estado.cancelado => ('CANCELADO', t.rojo),
      Estado.noEncontrado => ('NO ENCONTRADO', t.ambar),
      Estado.desconocido => ('SIN DATOS', t.grafito),
    };

// ---------------------------------------------------------------------------
// Facturas
// ---------------------------------------------------------------------------

class FacturasTab extends StatelessWidget {
  final VoidCallback onRevisarRfc;
  const FacturasTab({super.key, required this.onRevisarRfc});

  static const _mes = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    final app = AppScope.of(context);
    final h = app.historial;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      children: [
        Text('Verifica una factura', style: tTitulo(context, size: 30)),
        const SizedBox(height: 10),
        Text('Consulta en el SAT si un CFDI está vigente o cancelado, y si su emisor '
            'aparece en la lista 69-B.',
            style: tCuerpo(context)),
        const SizedBox(height: 24),
        // Bloque principal: escanear
        Material(
          color: t.bloque,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ScanScreen())),
            child: SizedBox(
              height: 236,
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, -.45),
                    child: Visor(size: 112, color: t.onBloque),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escanear código QR',
                            style: TextStyle(
                                fontFamily: fTitulo,
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                                color: t.onBloque)),
                        const SizedBox(height: 3),
                        Text('Apunta al QR impreso en la factura',
                            style: TextStyle(
                                fontFamily: fTexto,
                                fontSize: 14,
                                color: t.onBloque.withAlpha(180))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ManualScreen())),
              child: const Text('Capturar a mano'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
                onPressed: onRevisarRfc, child: const Text('Revisar un RFC')),
          ),
        ]),
        const SizedBox(height: 32),
        Text('Consultas recientes', style: tSeccion(context)),
        const SizedBox(height: 4),
        if (h.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text('Aquí aparecerán las facturas que consultes.',
                style: tCuerpo(context, size: 14.5)),
          )
        else
          for (final c in h.take(20))
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ResultScreen(cfdi: c.cfdi, inicial: c.respuesta))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(color: t.linea))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.cfdi.rfcEmisor,
                              style: tMono(context, size: 15, w: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                              '${dinero(c.cfdi.totalNumero)}   '
                              '${c.respuesta.fecha.day} ${_mes[c.respuesta.fecha.month - 1]}',
                              style: tCuerpo(context, size: 13.5)),
                        ],
                      ),
                    ),
                    Builder(builder: (_) {
                      final s = selloDe(t, c.respuesta.estado);
                      return SelloChico(texto: s.$1, color: s.$2);
                    }),
                  ],
                ),
              ),
            ),
        if (app.showPromo) ...[
          const SizedBox(height: 32),
          BrainCodePromo(onDismiss: app.hidePromo),
        ],
        const SizedBox(height: 18),
        const FirmaBrainCode(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Proveedores (lista 69-B)
// ---------------------------------------------------------------------------

class ProveedoresTab extends StatefulWidget {
  final String? rfcInicial;
  const ProveedoresTab({super.key, this.rfcInicial});

  @override
  State<ProveedoresTab> createState() => _ProveedoresTabState();
}

class _ProveedoresTabState extends State<ProveedoresTab> {
  late final _q = TextEditingController(text: widget.rfcInicial ?? '');
  late final Future<ListaEfos> _lista = EfosRepo.cargar();
  String? _buscado = '';

  @override
  void initState() {
    super.initState();
    if (widget.rfcInicial != null) _buscado = normalizaRfc(widget.rfcInicial!);
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _buscar() {
    FocusScope.of(context).unfocus();
    setState(() => _buscado = normalizaRfc(_q.text));
  }

  (String, Color, String) _info(Tk t, RegistroEfos r) => switch (r.situacion) {
        Situacion.definitivo => (
            'DEFINITIVO',
            t.rojo,
            'El SAT confirmó que este contribuyente emitió facturas por operaciones '
                'inexistentes. Sus facturas no producen efectos fiscales.'
          ),
        Situacion.presunto => (
            'PRESUNTO',
            t.ambar,
            'El SAT presume que este contribuyente emitió facturas por operaciones '
                'inexistentes. El contribuyente aún puede aclararlo ante el SAT.'
          ),
        Situacion.desvirtuado => (
            'DESVIRTUADO',
            t.verde,
            'El contribuyente demostró ante el SAT que sus operaciones existen.'
          ),
        Situacion.sentenciaFavorable => (
            'FAVORABLE',
            t.verde,
            'Un tribunal resolvió a favor del contribuyente.'
          ),
        Situacion.otra => ('EN LISTA', t.ambar, 'Situación: ${r.situacionTexto}.'),
      };

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return FutureBuilder<ListaEfos>(
      future: _lista,
      initialData: EfosRepo.actual,
      builder: (context, snap) {
        final lista = snap.data;
        final q = _buscado ?? '';
        final valido = rfcRe.hasMatch(q);
        final reg = (lista != null && valido) ? lista.buscar(q) : null;

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          children: [
            Text('Revisa a un proveedor', style: tTitulo(context, size: 30)),
            const SizedBox(height: 10),
            Text(
                'Busca un RFC en la lista 69-B del SAT: contribuyentes que emitieron '
                'facturas por operaciones que el SAT considera inexistentes.',
                style: tCuerpo(context)),
            const SizedBox(height: 22),
            TextField(
              controller: _q,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.search,
              inputFormatters: [LengthLimitingTextInputFormatter(15)],
              style: tMono(context, size: 17, w: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'RFC del proveedor',
                hintStyle: tMono(context, size: 16, color: t.grafito.withAlpha(140)),
                suffixIcon: IconButton(
                    tooltip: 'Buscar', icon: const Icon(Icons.search), onPressed: _buscar),
              ),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 10),
            if (lista != null)
              Text(
                  lista.total == 0
                      ? 'La lista no está disponible en esta versión.'
                      : 'Lista del SAT con ${_miles(lista.total)} contribuyentes, '
                          'descargada el ${lista.actualizadoLegible}.',
                  style: tCuerpo(context, size: 13)),
            const SizedBox(height: 24),
            if (q.isNotEmpty && !valido)
              Aviso(
                  color: t.ambar,
                  texto: 'Revisa el RFC: debe tener 12 caracteres (empresa) o 13 '
                      '(persona física).')
            else if (q.isNotEmpty && lista != null && lista.total > 0)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                decoration: BoxDecoration(
                    color: t.hoja,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: t.linea)),
                child: reg == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Sello(
                              texto: 'SIN REGISTRO',
                              color: t.verde,
                              escala: .7,
                              arriba: 'LISTA 69-B',
                              angulo: -.12),
                          const SizedBox(height: 18),
                          Text(q, style: tMono(context, size: 16, w: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                              'Este RFC no aparece en la lista 69-B descargada el '
                              '${lista.actualizadoLegible}.',
                              style: tCuerpo(context, size: 15, color: t.tinta)),
                        ],
                      )
                    : Builder(builder: (_) {
                        final i = _info(t, reg);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Sello(
                                texto: i.$1,
                                color: i.$2,
                                escala: .7,
                                arriba: 'LISTA 69-B',
                                abajo: reg.fecha.isEmpty ? null : 'DOF ${reg.fecha}',
                                angulo: -.12),
                            const SizedBox(height: 18),
                            Text(reg.nombre,
                                style: TextStyle(
                                    fontFamily: fTexto,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: t.tinta,
                                    height: 1.3)),
                            const SizedBox(height: 4),
                            Text(reg.rfc, style: tMono(context, size: 15)),
                            const SizedBox(height: 12),
                            Text(i.$3,
                                textAlign: TextAlign.justify,
                                style: tCuerpo(context, size: 15, color: t.tinta)),
                          ],
                        );
                      }),
              ),
            const SizedBox(height: 28),
            Text(
                'Fuente: listado completo del artículo 69-B del Código Fiscal de la '
                'Federación, publicado por el SAT. Esta app no pertenece al gobierno.',
                textAlign: TextAlign.justify,
                style: tCuerpo(context, size: 12.5)),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ajustes
// ---------------------------------------------------------------------------

class AjustesTab extends StatelessWidget {
  const AjustesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    final app = AppScope.of(context);
    final sysDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final sigue = app.themeMode == ThemeMode.system;
    final oscuro = sigue ? sysDark : app.themeMode == ThemeMode.dark;

    Widget fila(String titulo, {String? sub, Widget? trailing, VoidCallback? onTap, Color? color}) =>
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.linea))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(titulo,
                      style: TextStyle(
                          fontFamily: fTexto,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: color ?? t.tinta)),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub, style: tCuerpo(context, size: 13.5)),
                  ],
                ]),
              ),
              trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: t.grafito) : const SizedBox()),
            ]),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      children: [
        Text('Ajustes', style: tTitulo(context, size: 30)),
        const SizedBox(height: 26),
        Text('Apariencia', style: tSeccion(context)),
        fila('Tema oscuro',
            sub: sigue ? 'Lo define tu teléfono' : null,
            trailing: Switch(
                value: oscuro,
                onChanged: sigue
                    ? null
                    : (v) => app.setThemeMode(v ? ThemeMode.dark : ThemeMode.light))),
        fila('Usar el tema del teléfono',
            trailing: Switch(
                value: sigue,
                onChanged: (v) => app.setThemeMode(
                    v ? ThemeMode.system : (sysDark ? ThemeMode.dark : ThemeMode.light)))),
        const SizedBox(height: 28),
        Text('Datos', style: tSeccion(context)),
        fila('Borrar consultas recientes',
            sub: '${app.historial.length} guardadas en este teléfono',
            color: t.rojo,
            onTap: app.historial.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Borrar las consultas recientes?'),
                        content: const Text('Esta acción no se puede deshacer.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Borrar')),
                        ],
                      ),
                    );
                    if (ok == true) app.borrarHistorial();
                  }),
        const SizedBox(height: 28),
        Text('Información legal', style: tSeccion(context)),
        fila('Términos de uso', onTap: () => Navigator.of(context).push(LegalPage.terms())),
        fila('Aviso de privacidad',
            onTap: () => Navigator.of(context).push(LegalPage.privacy())),
        fila('Sitio del SAT', sub: 'sat.gob.mx', onTap: () => Native.openUrl(Legal.fuenteSat)),
        const SizedBox(height: 28),
        Text('Desarrollador', style: tSeccion(context)),
        fila(BrainCode.name,
            sub: 'Quiénes hicimos esta app',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutPage()))),
        const SizedBox(height: 24),
        Text(
            'Esta app no pertenece al SAT ni a ninguna dependencia de gobierno.\n'
            '© 2026 ${BrainCode.name}'
            '${app.appVersion.isNotEmpty ? '. Versión ${app.appVersion}' : ''}',
            style: tCuerpo(context, size: 12.5)),
      ],
    );
  }
}

String _miles(int n) {
  final s = '$n';
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
