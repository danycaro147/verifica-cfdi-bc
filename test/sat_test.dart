import 'package:flutter_test/flutter_test.dart';
import 'package:verifica_cfdi/sat.dart';

void main() {
  test('QR de CFDI 4.0', () {
    final c = cfdiDesdeQr(
        'https://verificacfdi.facturaelectronica.sat.gob.mx/default.aspx?'
        'id=5f8a2c1e-3b7d-4e90-a1c2-7f3e9b0d4a21&re=PLU150312AB4&rr=XAXX010101000'
        '&tt=4872.00&fe=AbC12345')!;
    expect(c.uuid, '5F8A2C1E-3B7D-4E90-A1C2-7F3E9B0D4A21');
    expect(c.rfcEmisor, 'PLU150312AB4');
    expect(c.total, '4872.00');
    expect(c.totalNumero, 4872.0);
  });

  test('QR de CFDI 3.3 con total con ceros', () {
    final c = cfdiDesdeQr('?re=AAA010101AAA&rr=BBB010101BBB'
        '&tt=0000001234.560000&id=5F8A2C1E-3B7D-4E90-A1C2-7F3E9B0D4A21')!;
    expect(c.total, '0000001234.560000'); // se envía tal cual al SAT
    expect(c.totalNumero, 1234.56);
  });

  test('QR que no es de factura', () {
    expect(cfdiDesdeQr('https://braincode.com.mx'), isNull);
    expect(cfdiDesdeQr('?id=123&re=A&rr=B&tt=1'), isNull);
  });

  test('Respuesta SOAP del SAT', () {
    const xml = '<s:Envelope><s:Body><ConsultaResponse xmlns="http://tempuri.org/">'
        '<ConsultaResult xmlns:a="http://schemas.datacontract.org/2004/07/Sat.Cfdi.Negocio.ConsultaCfdi.Servicio">'
        '<a:CodigoEstatus>S - Comprobante obtenido satisfactoriamente.</a:CodigoEstatus>'
        '<a:EsCancelable>Cancelable con aceptación</a:EsCancelable>'
        '<a:Estado>Vigente</a:Estado><a:EstatusCancelacion/>'
        '<a:ValidacionEFOS>200</a:ValidacionEFOS>'
        '</ConsultaResult></ConsultaResponse></s:Body></s:Envelope>';
    final r = parseRespuesta(xml);
    expect(r.estado, Estado.vigente);
    expect(r.esCancelable, 'Cancelable con aceptación');
    expect(r.validacionEfos, '200');
  });

  test('No encontrado', () {
    final r = parseRespuesta('<a:CodigoEstatus>N - 602: Comprobante no encontrado.'
        '</a:CodigoEstatus><a:Estado>No Encontrado</a:Estado>');
    expect(r.estado, Estado.noEncontrado);
  });

  test('RFC', () {
    expect(rfcRe.hasMatch(normalizaRfc('plu150312ab4')), isTrue);
    expect(rfcRe.hasMatch(normalizaRfc('GODE561231GR8')), isTrue);
    expect(rfcRe.hasMatch('ABC'), isFalse);
    expect(dinero(1234567.5), r'$1,234,567.50');
  });
}
