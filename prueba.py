from flask import Flask, render_template, request, jsonify
import subprocess
import os
import re
import time
import socket
import atexit

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LISP_BRIDGE = os.path.join(BASE_DIR, 'logic', 'clisp_bridge.lisp').replace('\\', '/')
PROLOG_SERVER = os.path.join(BASE_DIR, 'logic', 'prolog_server.pl')


# --- Arrancar el servidor Prolog en segundo plano ---

prolog_proceso = subprocess.Popen(
    ['swipl', PROLOG_SERVER],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
)

@atexit.register
def detener_prolog():
    prolog_proceso.terminate()

def esperar_prolog(reintentos=15, espera=0.4):
    for _ in range(reintentos):
        try:
            with socket.create_connection(("localhost", 8000), timeout=1):
                return True
        except OSError:
            time.sleep(espera)
    return False

esperar_prolog()


# --- Llamar a CLISP (que a su vez consulta Prolog) ---

def llamar_clisp(expr):
    full = f'(progn (load "{LISP_BRIDGE}" :verbose nil :print nil) {expr})'
    try:
        resultado = subprocess.run(
            ['clisp', '-q', '-x', full],
            capture_output=True, text=True, timeout=10
        )
        return resultado.stdout.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return ""


# --- Rutas Flask ---

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/estado_inicial')
def estado_inicial():
    paso = llamar_clisp('(cmd-paso-actual)')
    return jsonify({"siguiente_paso": paso or "Paso 1: Activa la corriente electrica."})


@app.route('/actualizar_estado', methods=['POST'])
def actualizar_estado():
    item = request.json.get('item', '')
    paso = llamar_clisp(f'(cmd-completar "{item}")')
    return jsonify({"status": "success", "siguiente_paso": paso or "Easter Egg completado!"})


@app.route('/retroceder_estado', methods=['POST'])
def retroceder_estado():
    item = request.json.get('item', '')
    paso = llamar_clisp(f'(cmd-retroceder "{item}")')
    return jsonify({"status": "success", "siguiente_paso": paso or "Regresando al inicio..."})


@app.route('/info_perk')
def info_perk():
    perk = request.args.get('perk', '')
    if not re.match(r'^[a-z_]+$', perk):
        return jsonify({'costo': 'N/A', 'efecto': 'Perk invalido', 'consejo': ''})
    salida = llamar_clisp(f'(perk-info "{perk}")')
    if '|' in salida:
        partes = salida.split('|', 2)
        return jsonify({'costo': partes[0], 'efecto': partes[1], 'consejo': partes[2]})
    return jsonify({'costo': 'N/A', 'efecto': 'CLISP no disponible', 'consejo': ''})


if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)
