// Función para enviar los clics de los Perks a Python/Prolog
function adquirirPerk(item) {
    const perkElement = document.getElementById(item);
    
    // SI EL PERK YA ESTÁ ACTIVO: Vamos a retroceder (quitar el hecho)
    if (perkElement.classList.contains('active')) {
        console.log("Retrocediendo estado para:", item);
        
        fetch('/retroceder_estado', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ item: item }),
        })
        .then(response => response.json())
        .then(data => {
            // Actualizamos la instrucción con el paso anterior
            document.getElementById('instruccion').innerText = data.siguiente_paso;
            
            // Regresamos el icono a estado bloqueado (gris)
            perkElement.classList.remove('active');
            perkElement.classList.add('locked');
        })
        .catch(error => console.error('Error al retroceder:', error));
    } 
    
    // SI EL PERK ESTÁ BLOQUEADO: Avanzamos (agregar el hecho)
    else {
        console.log("Avanzando estado para:", item);
        
        fetch('/actualizar_estado', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ item: item }),
        })
        .then(response => response.json())
        .then(data => {
            document.getElementById('instruccion').innerText = data.siguiente_paso;
            
            // Iluminamos el icono
            perkElement.classList.remove('locked');
            perkElement.classList.add('active');
        })
        .catch(error => console.error('Error al avanzar:', error));
    }
}

// Cargar el estado inicial al abrir la página
window.onload = () => {
    fetch('/actualizar_estado', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ item: 'inicio_partida' }) 
    })
    .then(res => response => response.json())
    .then(data => {
        // Aseguramos que el texto inicial sea el correcto
        if(data.siguiente_paso) {
            document.getElementById('instruccion').innerText = data.siguiente_paso;
        }
    })
    .catch(err => console.log("Iniciando partida..."));
};