from flask import Flask, render_template, request, jsonify
from pyswip import Prolog

app = Flask(__name__)
prolog = Prolog()

# Cargamos el archivo de lógica de Prolog
# Asegúrate de que la carpeta 'logic' exista y tenga tu archivo .pl
prolog.consult("logic/easter_egg.pl")

@app.route('/')
def index():
    # Carga la página principal (HTML)
    return render_template('index.html')

@app.route('/actualizar_estado', methods=['POST'])
def actualizar_estado():
    data = request.json
    item = data.get('item')
    
    # Insertamos el hecho en Prolog
    prolog.assertz(f"completado({item})")
    
    # Consultamos qué sigue
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    
    # Extraemos el mensaje y lo decodificamos si viene en bytes
    if guia:
        mensaje = guia[0]['X']
        if isinstance(mensaje, bytes):
            mensaje = mensaje.decode('utf-8')
    else:
        mensaje = "¡Easter Egg completado!"
    
    return jsonify({
        "status": "success",
        "siguiente_paso": mensaje
    })

@app.route('/retroceder_estado', methods=['POST'])
def retroceder_estado():
    data = request.json
    item = data.get('item')
    
    # Eliminamos el hecho de la base de conocimientos (retract)
    # Esto hace que Prolog "olvide" que ese perk ya se consiguió
    prolog.retract(f"completado({item})")
    
    # Consultamos la nueva instrucción tras borrar el hecho
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    
    if guia:
        mensaje = guia[0]['X']
        if isinstance(mensaje, bytes):
            mensaje = mensaje.decode('utf-8')
    else:
        mensaje = "Regresando al inicio..."
        
    return jsonify({
        "status": "success",
        "siguiente_paso": mensaje
    })

if __name__ == '__main__':
    print("🚀 Iniciando servidor Flask en http://127.0.0.1:5000")
    # use_reloader=False es CRÍTICO para que Prolog no truene en Windows
    app.run(debug=True, use_reloader=False, port=5000)