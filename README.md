# Verifica CFDI (Flutter · Android)

Una app de **BrainCode México Tech** — https://braincode.com.mx
© 2026 BrainCode México Tech. Todos los derechos reservados (ver `LICENSE`).

- Escanea el QR de una factura (CFDI 3.2, 3.3 y 4.0) o captura sus datos, y consulta su
  estado en el servicio público del SAT (`ConsultaCFDIService`).
- Busca RFC en la lista 69-B del SAT (incluida en la app; GitHub Actions la actualiza
  cada semana con `tools/efos_to_json.py`).
- Historial local de las últimas 50 consultas, tema claro/oscuro.

Cada push a `main` compila y publica `.apk` y `.aab` en *Releases*. Firma de Play Store
con los secretos `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.
