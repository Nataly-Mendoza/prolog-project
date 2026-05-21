from flask import Flask, render_template, request, jsonify
import subprocess
import os
import re

app = Flask(__name__)

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
LISP_BRIDGE = os.path.join(BASE_DIR, 'logic', 'clisp_bridge.lisp').replace('\\', '/')
ESTADO_FILE = os.path.join(BASE_DIR, 'logic', 'estado.pl')

# Crear estado.pl vacio si no existe
if not os.path.exists(ESTADO_FILE):
    with open(ESTADO_FILE, 'w') as f:
        f.write(':- dynamic completado/1.\n')


def llamar_clisp(expr):
    """Llama a CLISP: carga clisp_bridge.lisp y evalua expr."""
    full = f'(progn (load "{LISP_BRIDGE}" :verbose nil :print nil) {expr} (values))'
    try:
        resultado = subprocess.run(
            ['clisp', '-q', '-x', full],
            capture_output=True, text=True, timeout=15
        )
        return resultado.stdout.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return ""


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/estado_inicial')
def estado_inicial():
    # Reinicia el estado y devuelve el primer paso
    paso = llamar_clisp('(cmd-reset)')
    return jsonify({"siguiente_paso": paso or "Paso 1: Activa la corriente electrica."})


@app.route('/actualizar_estado', methods=['POST'])
def actualizar_estado():
    item = request.json.get('item', '')
    paso = llamar_clisp(f'(cmd-completar "{item}")')
    return jsonify({"status": "success", "siguiente_paso": paso or "Error al consultar Prolog."})


@app.route('/retroceder_estado', methods=['POST'])
def retroceder_estado():
    item = request.json.get('item', '')
    paso = llamar_clisp(f'(cmd-retroceder "{item}")')
    return jsonify({"status": "success", "siguiente_paso": paso or "Error al consultar Prolog."})


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
