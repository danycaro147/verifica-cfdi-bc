#!/usr/bin/env python3
"""Prueba el servicio público del SAT con un CFDI inexistente (debe responder 'No Encontrado')."""
import urllib.request
body = ('<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
        'xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:Consulta><tem:expresionImpresa>'
        '<![CDATA[?re=AAA010101AAA&rr=XAXX010101000&tt=100.00&id=5F8A2C1E-3B7D-4E90-A1C2-7F3E9B0D4A21]]>'
        '</tem:expresionImpresa></tem:Consulta></soapenv:Body></soapenv:Envelope>')
req = urllib.request.Request(
    "https://consultaqr.facturaelectronica.sat.gob.mx/ConsultaCFDIService.svc",
    data=body.encode(), method="POST",
    headers={"Content-Type": "text/xml; charset=utf-8",
             "SOAPAction": '"http://tempuri.org/IConsultaCFDIService/Consulta"'})
with urllib.request.urlopen(req, timeout=60) as r:
    print("HTTP", r.status)
    print(r.read().decode("utf-8", "replace")[:1500])
