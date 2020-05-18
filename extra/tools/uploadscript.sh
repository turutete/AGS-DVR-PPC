#XXX Edited by jurrutia

#ejecutado por uplocad.cgi (telecarga.cgi) linea a linea
##########

#Script encargado de desempaquetar y poner en marcha las actualizaciones

echo "<p>Procesando fichero</p>"

if [ -f /usr/local/zigor/actualizacion.tmp ]
then

	#nada:	su - brihuega
	#mejor poner el bit setuid en el script (u+s), tampoco !? :-(

	#imp:
	umask ugo-rwx
	umask u+rwx,g+rx,o+rx
	#umask -S > /usr/local/zigor/umask.txt

	###necesario este tratamiento:
	cat /usr/local/zigor/actualizacion.tmp | sed -e "/^---*[^-]*\r$/,/^\r$/d" -e "/^---*[^-]*--\r$/,$ d" > /usr/local/zigor/actualizacion-sed.tar.gz

	mkdir -p /usr/local/zigor/tmp

	#Desempaquetamos en un directorio provisional y comprobamos su firma
	cd /usr/local/zigor/tmp

	#tar xzf /usr/local/zigor/actualizacion/actualizacion-sed.tar.gz &> /dev/null
	#gunzip -f /usr/local/zigor/actualizacion/temporal2.tar.gz &> gunzip.log
	#tar -xf /usr/local/zigor/actualizacion/temporal2.tar &> tar.log
	gunzip -q < /usr/local/zigor/actualizacion-sed.tar.gz | tar -xf -
	
	#md5sum:
	md5sum -c integridad.md5 &> /var/tmp/md5.txt
	if [ $? != "0" ]
	then
		# Error en la integridad de algún fichero
		echo "<p><h1>Error de integridad</h1></p>"
		echo "<p>Resultado de la comprobación de integridad:</p>"
		echo "<p><pre>"
		cat /var/tmp/md5.txt
		echo "</pre></p>"
		cd ..
		rm -rf tmp
		###rm -f ${1}
		rm -f /var/tmp/md5.txt
		rm -rf /usr/local/zigor/actualizacion*
		
		exit 1
	else
		echo "<p>Resultado de la comprobación de integridad:</p>"
		echo "<p><pre>"
		cat /var/tmp/md5.txt
		echo "</pre></p>"
	fi

	rm -f /var/tmp/md5.txt


	# Copiar al directorio de reserva...
	##########
	rm -rf /usr/local/zigor/reserva
	mkdir /usr/local/zigor/reserva

	###cp -af /usr/local/zigor/activa/* /usr/local/zigor/reserva
	cp -af /usr/local/zigor/tmp/* /usr/local/zigor/reserva
	rm -rf /usr/local/zigor/tmp
	rm -rf /usr/local/zigor/actualizacion*
	sync
	
	echo "<p><h2>Actualizaci&oacute;n almacenada</h2></p>"

	#ojo, actualizar el script de actualizacion de la version activa acorde a la nueva de reserva:
	if [ -f "/usr/local/zigor/reserva/actualizacion.sh" ]
	then
		cp /usr/local/zigor/reserva/actualizacion.sh /usr/local/zigor/activa/actualizacion.sh
	fi

else
	echo "<p><h1>${0}: No encuentro fichero ${1}</h1></p>"
	exit 2
fi
