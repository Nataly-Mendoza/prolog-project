; Base de datos de perks para el Easter Egg de Zombis
; Cada entrada: (nombre . ((costo . N) (efecto . "texto") (consejo . "texto")))

(defvar *perks*
  '(("juggernog"
     . ((costo . 2500)
        (efecto . "Duplica tu salud maxima")
        (consejo . "Consiguelo primero, es la base de la supervivencia")))
    ("speed_cola"
     . ((costo . 3000)
        (efecto . "Recargas el arma el doble de rapido")
        (consejo . "Ideal con armas de alto calibre")))
    ("staminup"
     . ((costo . 2000)
        (efecto . "Corres mas rapido y por mas tiempo")
        (consejo . "Te ayuda a escapar de hordas grandes")))
    ("quick_revive"
     . ((costo . 1500)
        (efecto . "Te revives solo una vez por ronda")
        (consejo . "Critico en modo solitario")))
    ("electric_cherry"
     . ((costo . 2000)
        (efecto . "Descarga electrica al recargar el arma")
        (consejo . "Muy util en espacios cerrados")))
    ("widows_wine"
     . ((costo . 4000)
        (efecto . "Lanza telaranas al ser golpeado")
        (consejo . "El mas caro y el mas poderoso del Easter Egg")))))

(defun get-perk (nombre)
  (cdr (assoc nombre *perks* :test #'string=)))

(defun perk-info (nombre)
  (let ((perk (get-perk nombre)))
    (if perk
        (format t "~a|~a|~a"
                (cdr (assoc 'costo perk))
                (cdr (assoc 'efecto perk))
                (cdr (assoc 'consejo perk)))
        (format t "0|Perk desconocido|Sin informacion disponible"))))
