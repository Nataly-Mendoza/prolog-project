from flask import Flask, render_template, request, jsonify
from pyswip import Prolog

app = Flask(__name__)
prolog = Prolog()

# Cargamos el archivo de Prolog que creamos antes
prolog.consult("logic/easter_egg.pl")

@app.route('/')
def index():
    # Carga la página principal (HTML)
    return render_template('index.html')

@app.route('/actualizar_estado', methods=['POST'])
def actualizar_estado():
    data = request.json
    item = data.get('item') # Ejemplo: 'pieza_fuego' o 'electricidad'
    
    # Insertamos el hecho en Prolog (assertz)
    # Esto le dice a Prolog: "El jugador ya tiene/hizo esto"
    prolog.assertz(f"completado({item})")
    prolog.assertz(f"tiene({item})")
    
    # Después de actualizar, consultamos qué sigue
    guia = list(prolog.query("que_hacer(instruccion(X))"))
    mensaje = guia[0]['X'] if guia else "¡Easter Egg completado!"
    
    return jsonify({
        "status": "success",
        "siguiente_paso": mensaje
    })

if __name__ == '__main__':
    # Asegúrate de que esta línea esté "dentro" del bloque if
    app.run(debug=True)

    # ... (todo tu código anterior)

print("Iniciando servidor Flask...")
app.run(debug=True, port=5000)