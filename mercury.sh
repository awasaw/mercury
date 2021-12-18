#!/bin/sh
TRY=3
DATAFILE='/tmp/mercury.data'
UART='/dev/ttyUSB0'

if [ -z $1 ]
then
    echo "Usage: " $0 " command [public]"
    echo "command: uip, count"
    echo "------------------------------"
fi 

# DATAFILE используется в т.ч. как lock-file
while [ -f $DATAFILE ]  &&  [ $TRY -ne 0 ]   ; do
    TRY=$(($TRY - 1))
    sleep 1s
done

if [ "$TRY" -eq "0" ] 
    then 
        exit 1
fi

case $1 in
# Сюда можно добавлять свои команды
count) 
    # комманда сформированная command_gen.py
    CMD='\x00\x0B\x63\xC0\x27\xC6\x20'
    
    # Парсинг ответа счетчика.
    # Помните, что парсер выполняется командой eval, поэтому необходимо экранировать все спецсимволы.
    PARSER="T1=\${DATA:10:6}.\${DATA:16:2}; \
            T2=\${DATA:18:6}.\${DATA:24:2}; \
            T3=\${DATA:26:6}.\${DATA:32:2}; \
            T4=\${DATA:34:6}.\${DATA:40:2}; \
            printf 'Tarif1: %s  \nTarif2: %s \nTarif3: %s \nTarif4: %s \n' \
            \$T1 \$T2 \$T3 \$T4"
            
    # Команда, исполняемая когда указан ключ public
    PUBLIC="/usr/bin/wget -q -O /dev/null http://api.thingspeak.com/update?api_key=ATWRJ7K31\\&field1=\$T1\\&field2=\$T2\\&field3=\$T3\\&field4=\$T4"
    ;;
*) 
    CMD='\x00\x0B\x63\xC0\x63\xC6\x13' 
    PARSER="U=\${DATA:10:3}.\${DATA:13:1}; \
            I=\${DATA:14:2}.\${DATA:16:2}; \
            P=\$(echo \${DATA:18:6} | sed "s/^0*//"); \
            printf 'Voltage: \t%3.1f V \nCurrent: \t%.2f A \nPower: \t\t%s Watt\n' \
            \$U \$I \$P"
    PUBLIC="/usr/bin/wget -q -O /dev/null http://api.thingspeak.com/update?api_key=PFIV2BJI\\&field1=\$P\\&field2=\$U" 
    ;;
esac


stty 9600 raw -F $UART 

touch $DATAFILE
exec 3<$UART
cat <&3 > $DATAFILE &
PID=$!
echo -ne $CMD > $UART
sleep 1s
kill $PID
wait $PID 2>/dev/null
exec 3<&-

DATA=`cat $DATAFILE | xxd -p -c256`
eval $PARSER
rm -f $DATAFILE

if [ "$2" == "public" ] 
then
    eval $PUBLIC
fi
