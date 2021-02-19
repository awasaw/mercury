# Меркурий 200
### command_gen.py
Скрипт генерирующий hex команд счетчика

### mercury.sh
sh скрипт для openwrt, опрашивающий счетчик и публикующий показания посредством http-запроса. (в thingspeak.com).

```
#crontab
0-59 * * * * /root/mercury.sh uip public
0 0 * * * sleep 1s && /root/mercury.sh count public
```
