from flask import Flask, render_template, request, jsonify
from pyswip import Prolog
import subprocess
import os
import re

app = Flask(__name__)
prolog = Prolog()
prolog.consult("logic/easter_egg.pl")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LISP_FILE = os.path.join(BASE_DIR, 'logic', 'perks.lisp').replace('\\', '/')


def consultar_lisp(perk):
    """Llama a CLISP para obtener informacion de un perk."""
    try:
        resultado = subprocess.run(
            ['clisp', '-q', '-x', f'(progn (load "{LISP_FILE}") (perk-info "{perk}"))'],
            capture_output=True, text=True, timeout=10
        )
        salida = resultado.stdout.strip()
        if '|' in salida:
            partes = salida.split('|', 2)
            return {
                'costo': partes[0],
                'efecto': partes[1],
                'consejo': partes[2]
            }
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return {
        'costo': 'N/A',
        'efecto': 'CLISP no disponible',
        'consejo': 'Instala clisp para ver esta informacion'
    }


def _extraer_mensaje(guia, fallback):
    if guia:
        mensaje = guia[0]['X']
        if isinstance(mensaje, bytes):
            mensaje = mensaje.decode('utf-8')
        return mensaje
    return fallback


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/estado_inicial')
def estado_inicial():
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    return jsonify({"siguiente_paso": _extraer_mensaje(guia, "Paso 1: Activa la corriente electrica en el bunker.")})


@app.route('/actualizar_estado', methods=['POST'])
def actualizar_estado():
    data = request.json
    item = data.get('item')
    prolog.assertz(f"completado({item})")
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    return jsonify({
        "status": "success",
        "siguiente_paso": _extraer_mensaje(guia, "Easter Egg completado!")
    })


@app.route('/retroceder_estado', methods=['POST'])
def retroceder_estado():
    data = request.json
    item = data.get('item')
    prolog.retract(f"completado({item})")
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    return jsonify({
        "status": "success",
        "siguiente_paso": _extraer_mensaje(guia, "Regresando al inicio...")
    })


@app.route('/info_perk')
def info_perk():
    perk = request.args.get('perk', '')
    if not re.match(r'^[a-z_]+$', perk):
        return jsonify({'costo': 'N/A', 'efecto': 'Perk invalido', 'consejo': ''})
    info = consultar_lisp(perk)
    return jsonify(info)


if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)
