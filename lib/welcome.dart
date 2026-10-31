import 'package:flutter/material.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'legal.dart';
import 'theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _ok = false;

  @override
  Widget build(BuildContext context) {
    final t = Tk.of(context);

    Widget punto(String titulo, String texto) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo,
                style: TextStyle(
                    fontFamily: fTexto,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: t.tinta)),
            const SizedBox(height: 2),
            Text(texto, style: tCuerpo(context, size: 15)),
          ]),
        );

    return Scaffold(
      bottomNavigationBar: BarraAcciones(
        arriba: InkWell(
          onTap: () => setState(() => _ok = !_ok),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                  value: _ok,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (v) => setState(() => _ok = v ?? false)),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('Acepto los términos de uso y el aviso de privacidad.',
                      style: tCuerpo(context, size: 14.5, color: t.tinta)),
                ),
              ),
            ]),
          ),
        ),
        children: [
          FilledButton(
              onPressed: _ok ? () => AppScope.read(context).acceptTerms() : null,
              child: const Text('Empezar')),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text('Verifica\nCFDI', style: tTitulo(context, size: 44))),
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 4),
                  child: Sello(
                      texto: 'VIGENTE',
                      color: t.violeta,
                      escala: .62,
                      arriba: 'CONSULTA SAT',
                      angulo: .16),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Revisa en segundos si una factura es válida ante el SAT y si tu '
                'proveedor está en la lista negra.',
                style: tCuerpo(context, size: 17, color: t.tinta)),
            const SizedBox(height: 30),
            punto('Escanea el código QR',
                'El estado de la factura llega directo del servicio público del SAT.'),
            punto('Revisa la lista 69-B',
                'Sabrás si el emisor está señalado por facturar operaciones inexistentes.'),
            punto('Guarda tus consultas',
                'Las últimas consultas quedan solo en tu teléfono.'),
            const SizedBox(height: 8),
            Aviso(
              texto: 'Esta app no pertenece al SAT ni al gobierno. Los resultados son '
                  'informativos y no sustituyen la revisión de tu contador.',
              accion: Wrap(spacing: 18, children: [
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => Navigator.of(context).push(LegalPage.terms()),
                    child: const Text('Términos de uso')),
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => Navigator.of(context).push(LegalPage.privacy()),
                    child: const Text('Aviso de privacidad')),
              ]),
            ),
            const SizedBox(height: 18),
            const FirmaBrainCode(),
          ],
        ),
      ),
    );
  }
}
