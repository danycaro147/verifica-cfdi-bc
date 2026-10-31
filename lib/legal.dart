import 'package:flutter/material.dart';

import 'theme.dart';

class Legal {
  static const email = 'contacto@braincode.com.mx';
  static const fuenteSat = 'https://www.sat.gob.mx';

  static const avisoCorto =
      'Resultado obtenido del servicio público del SAT en el momento de la consulta. '
      'Es informativo y no constituye asesoría fiscal. Esta app no pertenece al gobierno.';

  static const terminos = [
    (
      'Qué hace la app',
      'Verifica CFDI, desarrollada por BrainCode México Tech, consulta el estatus de '
          'facturas electrónicas en el servicio público de verificación del Servicio '
          'de Administración Tributaria (SAT) y busca RFC en la lista de contribuyentes '
          'publicada por el SAT conforme al artículo 69-B del Código Fiscal de la '
          'Federación.'
    ),
    (
      'No es una app del gobierno',
      'Esta app no está afiliada, patrocinada ni avalada por el SAT ni por ninguna '
          'dependencia de gobierno. La información proviene de fuentes públicas del SAT '
          '(sat.gob.mx); ante cualquier diferencia prevalece lo que el SAT publique en '
          'sus medios oficiales.'
    ),
    (
      'Alcance de los resultados',
      'El resultado refleja lo que el SAT responde en el momento de la consulta y puede '
          'cambiar después (por ejemplo, si la factura se cancela). La lista 69-B incluida '
          'se actualiza periódicamente y puede no reflejar las publicaciones más recientes. '
          'Los resultados son informativos y no constituyen asesoría fiscal, contable ni '
          'legal. Verificar una factura no garantiza que sea deducible.'
    ),
    (
      'Disponibilidad',
      'El servicio del SAT puede no estar disponible en algunos momentos. La app se '
          'ofrece "tal cual", sin garantía de disponibilidad, exactitud o idoneidad para '
          'un fin específico.'
    ),
    (
      'Limitación de responsabilidad',
      'En la máxima medida permitida por la ley, BrainCode México Tech no será '
          'responsable por daños o perjuicios derivados del uso de la app ni de decisiones '
          'tomadas con base en sus resultados. Consulta a tu contador para decisiones '
          'fiscales.'
    ),
    (
      'Propiedad intelectual',
      'El código, diseño, íconos, textos propios, marca y logotipo son propiedad de '
          'BrainCode México Tech. Queda prohibida su copia o distribución sin autorización '
          'por escrito.'
    ),
    (
      'Ley aplicable',
      'Estos términos se rigen por las leyes de los Estados Unidos Mexicanos; cualquier '
          'controversia se someterá a los tribunales competentes de la Ciudad de México.'
    ),
    ('Contacto', 'BrainCode México Tech, $email, braincode.com.mx'),
  ];

  static const privacidad = [
    (
      'Qué se envía y a quién',
      'Para consultar una factura, la app envía directamente al servicio del SAT el '
          'folio fiscal, los RFC del emisor y receptor y el total. BrainCode México Tech '
          'no recibe, almacena ni comparte esos datos; no hay servidores intermedios.'
    ),
    (
      'Cámara',
      'La cámara se usa solo para leer el código QR. No se toman ni guardan fotografías.'
    ),
    (
      'Qué se guarda en tu teléfono',
      'Las últimas 50 consultas (folio, RFC, total y estado) y tus preferencias, en el '
          'almacenamiento privado de la app. Puedes borrar el historial en Ajustes; '
          'todo se elimina al desinstalar la app.'
    ),
    (
      'Sin rastreo',
      'La app no usa cuentas, analíticas, publicidad de terceros ni identificadores '
          'del dispositivo.'
    ),
    ('Contacto', 'BrainCode México Tech, $email'),
  ];
}

class LegalPage extends StatelessWidget {
  final String title;
  final List<(String, String)> sections;
  const LegalPage({super.key, required this.title, required this.sections});

  static Route terms() => MaterialPageRoute(
      builder: (_) => const LegalPage(title: 'Términos de uso', sections: Legal.terminos));

  static Route privacy() => MaterialPageRoute(
      builder: (_) =>
          const LegalPage(title: 'Aviso de privacidad', sections: Legal.privacidad));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
        children: [
          Text(title, style: tTitulo(context, size: 26)),
          const SizedBox(height: 6),
          Text('Actualizado el 31 de octubre de 2026', style: tCuerpo(context, size: 13.5)),
          for (final (i, s) in sections.indexed) ...[
            const SizedBox(height: 22),
            Text('${i + 1}. ${s.$1}', style: tSeccion(context)),
            const SizedBox(height: 6),
            Text(s.$2,
                textAlign: TextAlign.justify,
                style: tCuerpo(context, size: 15, color: Tk.of(context).tinta)),
          ],
        ],
      ),
    );
  }
}
