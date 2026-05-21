;;; Datos de perks (base local en CLISP)
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


;;; Cliente HTTP minimo para hablar con el servidor Prolog
(defun http-get (host port path)
  "Hace una peticion GET a host:port/path y devuelve el cuerpo de la respuesta."
  (let ((conn (socket:socket-connect port host :element-type 'character)))
    (format conn "GET ~a HTTP/1.0~%Host: ~a~%~%" path host)
    (finish-output conn)
    ;; Saltar cabeceras HTTP (leer hasta linea en blanco)
    (loop for linea = (read-line conn nil nil)
          for limpia = (string-right-trim '(#\Return) (or linea ""))
          while (and linea (not (string= limpia ""))))
    ;; Leer y devolver el cuerpo
    (let ((cuerpo (make-string-output-stream)))
      (loop for linea = (read-line conn nil nil)
            while linea
            do (write-string (string-right-trim '(#\Return) linea) cuerpo))
      (close conn)
      (get-output-stream-string cuerpo))))


;;; Consultas al servidor Prolog (la "base de datos")
(defun consultar-paso-actual ()
  (http-get "localhost" 8000 "/que_hacer"))

(defun completar-perk (item)
  (http-get "localhost" 8000 (format nil "/completar?item=~a" item)))

(defun retroceder-perk (item)
  (http-get "localhost" 8000 (format nil "/retroceder?item=~a" item)))


;;; Consulta de info de perk (datos locales en CLISP)
(defun perk-info (nombre)
  (let ((perk (cdr (assoc nombre *perks* :test #'string=))))
    (if perk
        (format t "~a|~a|~a"
                (cdr (assoc 'costo perk))
                (cdr (assoc 'efecto perk))
                (cdr (assoc 'consejo perk)))
        (format t "0|Perk desconocido|Sin informacion disponible"))))


;;; Comandos de interfaz para Python (imprimen resultado por stdout)
(defun cmd-paso-actual ()
  (format t "~a" (consultar-paso-actual)))

(defun cmd-completar (item)
  (format t "~a" (completar-perk item)))

(defun cmd-retroceder (item)
  (format t "~a" (retroceder-perk item)))
