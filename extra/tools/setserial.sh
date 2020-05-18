#!/bin/bash

#Se puede ver el estado con 'cat /proc/tty/driver/serial'
#Opciones setserial:
#port irq uart ^fourport ...
#Con 'stty' se puede configurar velocidad, etc...
#PROBAR IRQS:
#En BIOS se utilizan 3,4 p.serie, y 7 p.paralelo(378)
#Parecen OK: 10,9,5
#Parecen KO: 6
#PROBLEMAS CON IRQ 4
#----------

#Puertos placa etx:
#puerto local RS232 no utilizado:
/bin/setserial -v /dev/ttyS0 port 0x3F8 irq 3 uart 16550A
#puerto local RS232 MODEM:
/bin/setserial -v /dev/ttyS1 port 0x2F8 irq 3 uart 16550A
#----------

#Puertos uart1:
#uart1 canal A:
/bin/setserial -v /dev/ttyS5 port 0x300 irq 5 uart 16550A ^fourport

#uart1 canal B:
/bin/setserial -v /dev/ttyS4 port 0x308 irq 5 uart 16550A ^fourport
#----------

#Puertos uart2:
#uart2 canal A:
/bin/setserial -v /dev/ttyS3 port 0x310 irq 10 uart 16550A ^fourport

#uart2 canal B:
/bin/setserial -v /dev/ttyS2 port 0x318 irq 10 uart 16550A ^fourport
#----------
