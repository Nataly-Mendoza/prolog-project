var NOMBRES_PERK = {
    'juggernog': 'Juggernog',
    'speed_cola': 'Speed Cola',
    'staminup': 'Stamin-Up',
    'quick_revive': 'Quick Revive',
    'electric_cherry': 'Electric Cherry',
    'widows_wine': "Widow's Wine"
};

function adquirirPerk(item) {
    var perkElement = document.getElementById(item);

    if (perkElement.classList.contains('active')) {
        fetch('/retroceder_estado', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ item: item })
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            document.getElementById('instruccion').innerText = data.siguiente_paso;
            perkElement.classList.remove('active');
            perkElement.classList.add('locked');
        })
        .catch(function(err) { console.error('Error al retroceder:', err); });
    } else {
        fetch('/actualizar_estado', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ item: item })
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            document.getElementById('instruccion').innerText = data.siguiente_paso;
            perkElement.classList.remove('locked');
            perkElement.classList.add('active');
        })
        .catch(function(err) { console.error('Error al avanzar:', err); });
    }
}

function mostrarInfoPerk(item) {
    fetch('/info_perk?perk=' + item)
        .then(function(res) { return res.json(); })
        .then(function(data) {
            document.getElementById('perk-info-nombre').innerText = NOMBRES_PERK[item] || item;
            document.getElementById('perk-info-costo').innerText = data.costo;
            document.getElementById('perk-info-efecto').innerText = data.efecto;
            document.getElementById('perk-info-consejo').innerText = data.consejo;
            document.getElementById('perk-info-panel').classList.remove('perk-info-oculto');
        })
        .catch(function(err) { console.log('Error al obtener info:', err); });
}

function ocultarInfoPerk() {
    document.getElementById('perk-info-panel').classList.add('perk-info-oculto');
}

window.onload = function() {
    fetch('/estado_inicial')
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.siguiente_paso) {
                document.getElementById('instruccion').innerText = data.siguiente_paso;
            }
        })
        .catch(function(err) { console.log('Error al iniciar:', err); });
};
