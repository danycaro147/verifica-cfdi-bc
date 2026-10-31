// Consulta del estatus de un CFDI en el servicio público del SAT.
import 'dart:async';

import 'package:http/http.dart' as http;

/// Datos mínimos de un CFDI para consultarlo (los mismos que trae el QR).
class Cfdi {
  final String uuid; // folio fiscal
  final String rfcEmisor;
  final String rfcReceptor;
  final String total; // tal como viene en el QR o capturado

  const Cfdi({
    required this.uuid,
    required this.rfcEmisor,
    required this.rfcReceptor,
    required this.total,
  });

  double get totalNumero => double.tryParse(total.replaceAll(',', '')) ?? 0;

  Map<String, dynamic> toJson() =>
      {'id': uuid, 're': rfcEmisor, 'rr': rfcReceptor, 'tt': total};

  factory Cfdi.fromJson(Map m) => Cfdi(
      uuid: m['id'] as String,
      rfcEmisor: m['re'] as String,
      rfcReceptor: m['rr'] as String,
      total: m['tt'] as String);

  /// Expresión impresa que espera el servicio del SAT.
  String get expresion =>
      '?re=${_x(rfcEmisor)}&rr=${_x(rfcReceptor)}&tt=$total&id=$uuid';

  static String _x(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}

final uuidRe = RegExp(
    r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$');
final rfcRe = RegExp(r'^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$');

String normalizaRfc(String s) =>
    s.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

/// Lee el contenido de un QR de CFDI (versiones 3.2, 3.3 y 4.0).
/// Devuelve null si el QR no es de una factura del SAT.
Cfdi? cfdiDesdeQr(String raw) {
  final s = raw.trim();
  String? p(String k) {
    final m = RegExp('[?&]$k=([^&\\s]*)', caseSensitive: false).firstMatch(s);
    return m == null ? null : Uri.decodeComponent(m.group(1)!).trim();
  }

  final id = p('id')?.toUpperCase();
  final re = p('re');
  final rr = p('rr');
  final tt = p('tt');
  if (id == null || re == null || rr == null || tt == null) return null;
  if (!uuidRe.hasMatch(id)) return null;
  return Cfdi(
      uuid: id,
      rfcEmisor: normalizaRfc(re),
      rfcReceptor: normalizaRfc(rr),
      total: tt);
}

enum Estado { vigente, cancelado, noEncontrado, desconocido }

class RespuestaSat {
  final String codigo; // "S - Comprobante obtenido satisfactoriamente."
  final Estado estado;
  final String estadoTexto;
  final String esCancelable;
  final String estatusCancelacion;
  final String validacionEfos;
  final DateTime fecha;

  RespuestaSat({
    required this.codigo,
    required this.estado,
    required this.estadoTexto,
    required this.esCancelable,
    required this.estatusCancelacion,
    required this.validacionEfos,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'estado': estado.name,
        'estadoTexto': estadoTexto,
        'esCancelable': esCancelable,
        'estatusCancelacion': estatusCancelacion,
        'efos': validacionEfos,
        'fecha': fecha.millisecondsSinceEpoch,
      };

  factory RespuestaSat.fromJson(Map m) => RespuestaSat(
        codigo: (m['codigo'] ?? '') as String,
        estado: Estado.values.firstWhere((e) => e.name == m['estado'],
            orElse: () => Estado.desconocido),
        estadoTexto: (m['estadoTexto'] ?? '') as String,
        esCancelable: (m['esCancelable'] ?? '') as String,
        estatusCancelacion: (m['estatusCancelacion'] ?? '') as String,
        validacionEfos: (m['efos'] ?? '') as String,
        fecha: DateTime.fromMillisecondsSinceEpoch((m['fecha'] ?? 0) as int),
      );
}

String _tag(String xml, String name) {
  final m = RegExp('<(?:\\w+:)?$name(?:\\s[^>]*)?>([\\s\\S]*?)</(?:\\w+:)?$name>')
      .firstMatch(xml);
  if (m != null) return m.group(1)!.trim();
  return '';
}

/// Interpreta la respuesta SOAP del SAT.
RespuestaSat parseRespuesta(String xml, {DateTime? fecha}) {
  final estadoTexto = _tag(xml, 'Estado');
  final e = estadoTexto.toLowerCase();
  final estado = e.startsWith('vigente')
      ? Estado.vigente
      : e.startsWith('cancelado')
          ? Estado.cancelado
          : e.contains('no encontrado')
              ? Estado.noEncontrado
              : Estado.desconocido;
  return RespuestaSat(
    codigo: _tag(xml, 'CodigoEstatus'),
    estado: estado,
    estadoTexto: estadoTexto,
    esCancelable: _tag(xml, 'EsCancelable'),
    estatusCancelacion: _tag(xml, 'EstatusCancelacion'),
    validacionEfos: _tag(xml, 'ValidacionEFOS'),
    fecha: fecha ?? DateTime.now(),
  );
}

class SatError implements Exception {
  final String mensaje;
  SatError(this.mensaje);
  @override
  String toString() => mensaje;
}

const satEndpoint =
    'https://consultaqr.facturaelectronica.sat.gob.mx/ConsultaCFDIService.svc';

String sobreSoap(Cfdi c) => '<?xml version="1.0" encoding="utf-8"?>'
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
    'xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body>'
    '<tem:Consulta><tem:expresionImpresa><![CDATA[${c.expresion}]]>'
    '</tem:expresionImpresa></tem:Consulta></soapenv:Body></soapenv:Envelope>';

/// Consulta el estatus en el SAT. Lanza [SatError] con un mensaje claro.
Future<RespuestaSat> consultarSat(Cfdi c, {http.Client? client}) async {
  final cl = client ?? http.Client();
  try {
    final r = await cl
        .post(Uri.parse(satEndpoint),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '"http://tempuri.org/IConsultaCFDIService/Consulta"',
            },
            body: sobreSoap(c))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      throw SatError('El servicio del SAT respondió con error ${r.statusCode}. '
          'Intenta de nuevo en unos minutos.');
    }
    final res = parseRespuesta(r.body);
    if (res.estadoTexto.isEmpty && res.codigo.isEmpty) {
      throw SatError('El SAT envió una respuesta que no se pudo leer.');
    }
    return res;
  } on TimeoutException {
    throw SatError('El SAT tardó demasiado en responder. Revisa tu conexión e '
        'intenta de nuevo.');
  } on SatError {
    rethrow;
  } catch (_) {
    throw SatError('No hay conexión con el SAT. Revisa tu internet e intenta de nuevo.');
  } finally {
    if (client == null) cl.close();
  }
}

/// Agrupa el folio para leerlo mejor: 8-4-4 / 4-12.
String folioEnDosLineas(String uuid) {
  final p = uuid.split('-');
  if (p.length != 5) return uuid;
  return '${p[0]}-${p[1]}-${p[2]}\n${p[3]}-${p[4]}';
}

String dinero(double v) {
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final ent = parts[0];
  final b = StringBuffer();
  for (var i = 0; i < ent.length; i++) {
    if (i > 0 && (ent.length - i) % 3 == 0) b.write(',');
    b.write(ent[i]);
  }
  return '${v < 0 ? '-' : ''}\$$b.${parts[1]}';
}
