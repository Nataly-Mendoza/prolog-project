;;; Directorio donde viven los archivos .pl (mismo que este archivo)
(defvar *logic-dir*
  (directory-namestring
    (truename (or *load-pathname* #p"logic/clisp_bridge.lisp"))))

(defun ruta (archivo)
  (concatenate 'string *logic-dir* archivo))


;;; Llama a SWI-Prolog con un goal y devuelve lo que imprime por stdout
(defun swipl-consulta (goal)
  (let ((temp (ruta "_query.pl")))
    (with-open-file (f temp :direction :output :if-exists :supersede)
      (format f ":- ~a.~%" goal)
      (format f ":- halt(1).~%"))
    (with-open-stream
        (pipe (ext:make-pipe-input-stream
               (format nil "swipl -q ~s ~s ~s"
                       (ruta "easter_egg.pl")
                       (ruta "estado.pl")
                       temp)))
      (string-trim '(#\Space #\Newline #\Return #\Tab)
        (with-output-to-string (s)
          (loop for c = (read-char pipe nil)
                while c do (write-char c s)))))))


;;; Estado: leer items completados del archivo estado.pl
(defun leer-completados ()
  (let ((items '()))
    (when (probe-file (ruta "estado.pl"))
      (with-open-file (f (ruta "estado.pl"))
        (loop for linea = (read-line f nil nil)
              while linea
              do (let* ((l   (string-trim '(#\Space #\Return #\Tab) linea))
                        (pos (search "completado(" l)))
                   (when pos
                     (let* ((inicio (+ pos 11))
                            (fin    (position #\) l :start inicio)))
                       (when fin
                         (pushnew (subseq l inicio fin) items :test #'string=))))))))
    (nreverse items)))

;;; Estado: guardar items en estado.pl (formato Prolog)
(defun guardar-completados (items)
  (with-open-file (f (ruta "estado.pl")
                     :direction :output :if-exists :supersede)
    (format f ":- dynamic completado/1.~%")
    (dolist (item items)
      (format f "completado(~a).~%" item))))

;;; Consulta el siguiente paso usando la logica de easter_egg.pl
(defun paso-actual ()
  (swipl-consulta "que_hacer(instruccion(X)), format('~w', [X]), halt"))


;;; Comandos de interfaz (Python llama estos via subproceso)
(defun cmd-reset ()
  (guardar-completados '())
  (format t "~a" (paso-actual)))

(defun cmd-paso-actual ()
  (format t "~a" (paso-actual)))

(defun cmd-completar (item)
  (let* ((actuales (leer-completados))
         (nuevos   (if (member item actuales :test #'string=)
                       actuales
                       (append actuales (list item)))))
    (guardar-completados nuevos)
    (format t "~a" (paso-actual))))

(defun cmd-retroceder (item)
  (let ((nuevos (remove item (leer-completados) :test #'string=)))
    (guardar-completados nuevos)
    (format t "~a" (paso-actual))))


;;; Base de datos de perks (datos propios de CLISP, sin Prolog)
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

(defun perk-info (nombre)
  (let ((perk (cdr (assoc nombre *perks* :test #'string=))))
    (if perk
        (format t "~a|~a|~a"
                (cdr (assoc 'costo perk))
                (cdr (assoc 'efecto perk))
                (cdr (assoc 'consejo perk)))
        (format t "0|Perk desconocido|Sin informacion disponible"))))
