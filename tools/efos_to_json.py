#!/usr/bin/env python3
"""Descarga la lista 69-B del SAT y la convierte en assets/efos/efos.json."""
import csv, datetime, io, json, sys, urllib.request

URLS = [
    "http://omawww.sat.gob.mx/cifras_sat/Documents/Listado_Completo_69-B.csv",
    "https://omawww.sat.gob.mx/cifras_sat/Documents/Listado_Completo_69-B.csv",
]
OUT = "assets/efos/efos.json"


def descargar():
    err = None
    for u in URLS:
        try:
            req = urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0 (VerificaCFDI build)"})
            with urllib.request.urlopen(req, timeout=120) as r:
                return u, r.read()
        except Exception as e:  # noqa
            err = e
            print("Falló", u, e)
    raise SystemExit(f"No se pudo descargar la lista 69-B: {err}")


def main():
    url, data = descargar()
    for enc in ("utf-8-sig", "latin-1"):
        try:
            text = data.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    rows = list(csv.reader(io.StringIO(text)))
    hi = next(i for i, r in enumerate(rows[:20]) if any(c.strip().upper() == "RFC" for c in r))
    head = [c.strip() for c in rows[hi]]
    print("Encabezados:", head)
    low = [h.lower() for h in head]
    i_rfc = low.index("rfc")
    i_nom = next(i for i, h in enumerate(low) if "nombre" in h)
    i_sit = next(i for i, h in enumerate(low) if "situaci" in h)
    fechas = [i for i, h in enumerate(low) if "publicaci" in h and "dof" in h]
    out = []
    for r in rows[hi + 1:]:
        if len(r) <= max(i_rfc, i_nom, i_sit):
            continue
        rfc = r[i_rfc].strip().upper().replace(" ", "")
        if len(rfc) < 12:
            continue
        fecha = ""
        for i in reversed(fechas):
            if i < len(r) and r[i].strip():
                fecha = r[i].strip()
                break
        out.append([rfc, " ".join(r[i_nom].split()), r[i_sit].strip(), fecha])
    from collections import Counter
    print("Registros:", len(out), dict(Counter(x[2] for x in out)))
    print("Ejemplos:", out[:3])
    if len(out) < 3000:
        raise SystemExit("Muy pocos registros; se conserva la lista anterior.")
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({"actualizado": datetime.date.today().isoformat(), "fuente": url, "r": out},
                  f, ensure_ascii=False, separators=(",", ":"))
    print("OK ->", OUT)


if __name__ == "__main__":
    main()
