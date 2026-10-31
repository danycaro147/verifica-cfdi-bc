import 'package:flutter/material.dart';

import 'app_state.dart';
import 'legal.dart';
import 'theme.dart';

class BrainCode {
  static const name = 'BrainCode México Tech';
  static const tagline = 'Tecnología que mueve a tu empresa.';
  static const email = 'contacto@braincode.com.mx';
  static String site(String c) =>
      'https://braincode.com.mx/?utm_source=verifica_cfdi&utm_medium=app&utm_campaign=$c';
  static const mail =
      'mailto:contacto@braincode.com.mx?subject=Contacto%20desde%20Verifica%20CFDI';

  static const servicios = [
    ('Odoo ERP', 'Facturación CFDI 4.0, contabilidad, inventarios y nómina.'),
    ('Software a la medida', 'Portales, cotizadores y automatización de procesos.'),
    ('Apps móviles', 'Para tu equipo en campo y tus clientes.'),
    ('Nube AWS y Azure', 'Migración, respaldos y seguridad.'),
  ];

  static Future<void> open(BuildContext context, String url) async {
    final ok = await Native.openUrl(url);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace.')));
    }
  }
}

class MarcaBrainCode extends StatelessWidget {
  final double size;
  final Color? color;
  const MarcaBrainCode({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) => Image.asset('assets/images/braincode_isotipo.png',
      width: size,
      height: size,
      color: color ?? Tk.of(context).tinta,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      semanticLabel: BrainCode.name);
}

class FirmaBrainCode extends StatelessWidget {
  const FirmaBrainCode({super.key});

  @override
  Widget build(BuildContext context) {
    final g = Tk.of(context).grafito;
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Hecha por ', style: TextStyle(fontFamily: fTexto, fontSize: 13, color: g)),
            MarcaBrainCode(size: 18, color: g),
            const SizedBox(width: 4),
            Text(BrainCode.name,
                style: TextStyle(
                    fontFamily: fTexto, fontSize: 13, fontWeight: FontWeight.w600, color: g)),
          ]),
        ),
      ),
    );
  }
}

/// Recomendación propia, discreta y descartable por 30 días.
class BrainCodePromo extends StatelessWidget {
  final VoidCallback onDismiss;
  const BrainCodePromo({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
      decoration: BoxDecoration(
        color: t.violeta.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MarcaBrainCode(size: 34, color: t.violeta),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('¿Facturas en Odoo?',
                    style: TextStyle(
                        fontFamily: fTitulo,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: t.tinta)),
                const SizedBox(height: 4),
                Text(
                    'BrainCode México Tech implementa Odoo con facturación CFDI 4.0, '
                    'contabilidad y nómina para tu empresa.',
                    style: tCuerpo(context, size: 14, color: t.tinta)),
              ]),
            ),
            IconButton(
                tooltip: 'Ocultar',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 18, color: t.grafito),
                onPressed: onDismiss),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: TextButton(
              onPressed: () => BrainCode.open(context, BrainCode.site('tarjeta_inicio')),
              child: const Text('Conocer a BrainCode'),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);
    final v = AppScope.of(context).appVersion;
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BarraAcciones(children: [
        OutlinedButton(
            onPressed: () => BrainCode.open(context, BrainCode.mail),
            child: const Text('Escribir correo')),
        FilledButton(
            onPressed: () => BrainCode.open(context, BrainCode.site('acerca_de')),
            child: const Text('Visitar sitio')),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
        children: [
          MarcaBrainCode(size: 56, color: t.tinta),
          const SizedBox(height: 18),
          Text(BrainCode.name, style: tTitulo(context, size: 26)),
          const SizedBox(height: 4),
          Text(BrainCode.tagline, style: tCuerpo(context)),
          const SizedBox(height: 18),
          Text(
              'Hicimos Verifica CFDI para que contadores y empresas revisen sus facturas '
              'en segundos. Es gratuita, no tiene publicidad de terceros y no recopila '
              'datos personales.',
              textAlign: TextAlign.justify,
              style: tCuerpo(context, color: t.tinta)),
          const SizedBox(height: 26),
          Text('Servicios', style: tSeccion(context)),
          for (final s in BrainCode.servicios)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.linea))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.$1,
                    style: TextStyle(
                        fontFamily: fTexto,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: t.tinta)),
                const SizedBox(height: 2),
                Text(s.$2, style: tCuerpo(context, size: 14)),
              ]),
            ),
          const SizedBox(height: 22),
          TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              onPressed: () => Navigator.of(context).push(LegalPage.terms()),
              child: const Text('Términos de uso')),
          TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              onPressed: () => Navigator.of(context).push(LegalPage.privacy()),
              child: const Text('Aviso de privacidad')),
          const SizedBox(height: 10),
          Text('© 2026 ${BrainCode.name}. Todos los derechos reservados.'
              '${v.isNotEmpty ? '\nVerifica CFDI, versión $v' : ''}',
              style: tCuerpo(context, size: 12.5)),
        ],
      ),
    );
  }
}
