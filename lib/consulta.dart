import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'app_state.dart';
import 'efos.dart';
import 'legal.dart';
import 'sat.dart';
import 'theme.dart';

// ---------------------------------------------------------------------------
// Escáner de QR
// ---------------------------------------------------------------------------

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _ctrl = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _listo = false;
  bool _luz = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _detect(BarcodeCapture cap) {
    if (_listo) return;
    for (final b in cap.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final c = cfdiDesdeQr(raw);
      if (c != null) {
        _listo = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ResultScreen(cfdi: c)));
        return;
      }
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('Este código no es de una factura del SAT.'),
          duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctrl, onDetect: _detect),
          // Oscurece alrededor del visor
          IgnorePointer(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withAlpha(140), BlendMode.srcOut),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.transparent),
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                          color: Colors.black, borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Center(child: Visor(size: 268, linea: false)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Cerrar',
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _luz ? 'Apagar linterna' : 'Encender linterna',
                    color: Colors.white,
                    icon: Icon(_luz ? Icons.flashlight_off : Icons.flashlight_on),
                    onPressed: () {
                      _ctrl.toggleTorch();
                      setState(() => _luz = !_luz);
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Text('Apunta al código QR de la factura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: fTitulo,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Está impreso en la representación impresa o en el PDF.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: fTexto, fontSize: 14, color: Colors.white.withAlpha(190))),
                  const SizedBox(height: 18),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ManualScreen())),
                    child: const Text('Capturar los datos a mano'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Captura manual
// ---------------------------------------------------------------------------

class _Mayus extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _uuid = TextEditingController();
  final _re = TextEditingController();
  final _rr = TextEditingController();
  final _tt = TextEditingController();
  String? _eUuid, _eRe, _eRr, _eTt;

  @override
  void dispose() {
    for (final c in [_uuid, _re, _rr, _tt]) {
      c.dispose();
    }
    super.dispose();
  }

  void _consultar() {
    FocusScope.of(context).unfocus();
    final id = _uuid.text.trim().toUpperCase();
    final re = normalizaRfc(_re.text);
    final rr = normalizaRfc(_rr.text);
    final tt = double.tryParse(_tt.text.replaceAll(',', '').replaceAll(r'$', '').trim());
    setState(() {
      _eUuid = uuidRe.hasMatch(id) ? null : 'Escribe los 36 caracteres del folio, con guiones';
      _eRe = rfcRe.hasMatch(re) ? null : 'RFC no válido';
      _eRr = rfcRe.hasMatch(rr) ? null : 'RFC no válido';
      _eTt = tt == null ? 'Escribe el total de la factura' : null;
    });
    if ([_eUuid, _eRe, _eRr, _eTt].any((e) => e != null)) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
            cfdi: Cfdi(uuid: id, rfcEmisor: re, rfcReceptor: rr, total: tt!.toStringAsFixed(2)))));
  }

  Widget _campo(String label, String? help, TextEditingController c, String? error,
      {bool mono = true, TextInputType? tipo, String? hint, List<TextInputFormatter>? f}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: fTexto,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Tk.of(context).tinta)),
          if (help != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(help, style: tCuerpo(context, size: 13.5)),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            keyboardType: tipo,
            inputFormatters: f,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            style: mono ? tMono(context, size: 15.5) : null,
            decoration: InputDecoration(hintText: hint, errorText: error),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar factura')),
      bottomNavigationBar: BarraAcciones(children: [
        FilledButton(onPressed: _consultar, child: const Text('Consultar en el SAT')),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        children: [
          Text('Copia los datos tal como aparecen en la factura.',
              style: tCuerpo(context)),
          const SizedBox(height: 22),
          _campo('Folio fiscal', 'También se llama UUID', _uuid, _eUuid,
              hint: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
              f: [_Mayus(), FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f-]')),
                LengthLimitingTextInputFormatter(36)]),
          _campo('RFC del emisor', 'Quien expidió la factura', _re, _eRe,
              hint: 'AAA010101AAA', f: [_Mayus(), LengthLimitingTextInputFormatter(13)]),
          _campo('RFC del receptor', 'A quien se le facturó', _rr, _eRr,
              hint: 'XAXX010101000', f: [_Mayus(), LengthLimitingTextInputFormatter(13)]),
          _campo('Total', null, _tt, _eTt,
              mono: false,
              hint: '0.00',
              tipo: const TextInputType.numberWithOptions(decimal: true),
              f: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resultado
// ---------------------------------------------------------------------------

class ResultScreen extends StatefulWidget {
  final Cfdi cfdi;
  final RespuestaSat? inicial;
  const ResultScreen({super.key, required this.cfdi, this.inicial});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  RespuestaSat? _r;
  String? _error;
  bool _cargando = false;
  int _golpe = 0; // reinicia la animación del sello

  @override
  void initState() {
    super.initState();
    _r = widget.inicial;
    if (_r == null) _consultar();
    EfosRepo.cargar().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {});
  }

  Future<void> _consultar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await consultarSat(widget.cfdi);
      if (!mounted) return;
      setState(() {
        _r = r;
        _cargando = false;
        _golpe++;
      });
      AppScope.read(context).agregar(Consulta(widget.cfdi, r));
    } on SatError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  static const _mes = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
  ];

  (String, Color, String) _estado(Tk t, Estado e) => switch (e) {
        Estado.vigente => (
            'VIGENTE',
            t.verde,
            'El SAT registra esta factura como vigente.'
          ),
        Estado.cancelado => (
            'CANCELADO',
            t.rojo,
            'El SAT registra esta factura como cancelada. Una factura cancelada '
                'no produce efectos fiscales.'
          ),
        Estado.noEncontrado => (
            'NO ENCONTRADO',
            t.ambar,
            'El SAT no tiene una factura con estos datos. Revisa que el folio, los '
                'RFC y el total coincidan exactamente con la factura. Una factura '
                'recién emitida puede tardar hasta 72 horas en aparecer.'
          ),
        Estado.desconocido => (
            'SIN DATOS',
            t.grafito,
            'El SAT respondió sin un estado reconocible.'
          ),
      };

  String _texto(RespuestaSat r, RegistroEfos? ef) {
    final c = widget.cfdi;
    return 'Consulta de CFDI en el SAT\n'
        'Estado: ${r.estadoTexto}\n'
        'Folio fiscal: ${c.uuid}\n'
        'Emisor: ${c.rfcEmisor}\n'
        'Receptor: ${c.rfcReceptor}\n'
        'Total: ${dinero(c.totalNumero)}\n'
        'Consultado: ${r.fecha.day}/${r.fecha.month}/${r.fecha.year}\n'
        '${ef == null ? '' : 'Emisor en lista 69-B: ${ef.situacionTexto}\n'}'
        '\n${Legal.avisoCorto}\nVerifica CFDI, de BrainCode México Tech';
  }

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    final c = widget.cfdi;
    final r = _r;
    final lista = EfosRepo.actual;
    final ef = lista?.buscar(c.rfcEmisor);

    Widget campo(String k, Widget v) => Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k, style: tCuerpo(context, size: 13)),
            const SizedBox(height: 2),
            v,
          ]),
        );

    final est = r == null ? null : _estado(t, r.estado);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      bottomNavigationBar: BarraAcciones(children: [
        if (r != null && !_cargando)
          OutlinedButton(
              onPressed: () => Native.share(_texto(r, ef)), child: const Text('Compartir')),
        if (_error != null)
          FilledButton(onPressed: _consultar, child: const Text('Reintentar'))
        else
          FilledButton(
            onPressed: _cargando
                ? null
                : () => widget.inicial != null && r == widget.inicial
                    ? _consultar()
                    : Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ScanScreen())),
            child: Text(widget.inicial != null && r == widget.inicial
                ? 'Actualizar'
                : 'Verificar otra'),
          ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: HojaComprobante(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: tCuerpo(context, size: 13)),
                    const SizedBox(height: 2),
                    Text(dinero(c.totalNumero),
                        style: tTitulo(context, size: 32).copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()])),
                    campo('RFC del emisor', Text(c.rfcEmisor, style: tMono(context))),
                    campo('RFC del receptor', Text(c.rfcReceptor, style: tMono(context))),
                    campo('Folio fiscal',
                        Text(folioEnDosLineas(c.uuid), style: tMono(context, size: 14.5))),
                  ],
                ),
              )),
              Positioned(
                right: 12,
                top: 104,
                child: _cargando
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(children: [
                          const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(strokeWidth: 2.6)),
                          const SizedBox(height: 8),
                          Text('Consultando al SAT', style: tCuerpo(context, size: 12.5)),
                        ]),
                      )
                    : est == null
                        ? const SizedBox()
                        : SelloAnimado(
                            key: ValueKey(_golpe),
                            child: Sello(
                              texto: est.$1,
                              color: est.$2,
                              escala: est.$1.length > 9 ? .62 : .8,
                              arriba: 'CONSULTA SAT',
                              abajo:
                                  '${r!.fecha.day} ${_mes[r.fecha.month - 1]} ${r.fecha.year}',
                            ),
                          ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_error != null)
            Aviso(icono: Icons.wifi_off, color: t.rojo, texto: _error!)
          else if (r != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(est!.$3,
                  textAlign: TextAlign.justify,
                  style: tCuerpo(context, size: 15.5, color: t.tinta)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(children: [
                if (r.estado != Estado.noEncontrado) ...[
                  Dato('Cancelación',
                      r.esCancelable.isEmpty ? 'Sin información' : r.esCancelable),
                  Dato('Solicitud de cancelación',
                      r.estatusCancelacion.isEmpty ? 'Ninguna' : r.estatusCancelacion),
                ],
                Dato(
                  'Emisor en lista 69-B',
                  lista == null
                      ? 'Cargando'
                      : ef == null
                          ? 'No aparece'
                          : ef.situacionTexto,
                  color: ef == null
                      ? (lista == null ? null : t.verde)
                      : (ef.riesgo ? t.rojo : t.verde),
                ),
                Dato('Consultado',
                    '${r.fecha.day}/${r.fecha.month}/${r.fecha.year} a las '
                    '${r.fecha.hour.toString().padLeft(2, '0')}:${r.fecha.minute.toString().padLeft(2, '0')}'),
              ]),
            ),
            if (ef != null && ef.riesgo) ...[
              const SizedBox(height: 16),
              Aviso(
                icono: Icons.report_outlined,
                color: t.rojo,
                texto: '${ef.nombre} aparece en la lista 69-B del SAT como '
                    '${ef.situacionTexto.toLowerCase()}. El SAT considera que este '
                    'contribuyente emitió facturas por operaciones inexistentes.',
              ),
            ],
          ],
          const SizedBox(height: 22),
          Text(Legal.avisoCorto,
              textAlign: TextAlign.justify, style: tCuerpo(context, size: 12.5)),
        ],
      ),
    );
  }
}
