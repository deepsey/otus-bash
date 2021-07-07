# ДЗ по теме Bash

Скрипт script.sh осуществляет обработку файла access.log. Для создания
цикла обработки исходный из исходного файла последовательно выбираются
100 строк, информация из которых затем структурируется и отсылается на
почту пользователю root. Почтовым клиентом выступает mutt. К ДЗ приложен
Vagrantfile, который провижинионируется скриптом otus-bash.sh.
Файл otus-bash.sh снабжен необходимыми комментариями.

### Описание скрипта script.sh

#!/bin/bash

#### Пишем защиту от мультизапуска

lockfile=/root/lockfile

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;   
then  
  trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT  

#### Создаем файл счетчика строк исходного файла  

  if [[ ! -e /root/count.src ]]; then count=1>/root/count.src; fi  
  source /root/count.src  

#### Проверяем, не дошли ли мы до конца файла. Если да, возвращаем значение счетчика на начальную позицию

  if [ $count -gt 670 ]; then echo count=1 > /root/count.src; count=1;fi  

#### Увеличиваем конечное значение счетчика строк

  count2=$(expr $count + 100)

#### Выводим строки в файл access1.log 

  sed -n $count,${count2}p /root/access.log > /root/access1.log

#### Пишем новое значение счетчика строк

  echo count=$count2 > /root/count.src


#### Обрабатываем файл access1.log и отправляем результаты на почту root 
  {
  echo "Statistic for period from"  
  head -n 1 /root/access1.log | awk '{print $4 " " $5}'  
  echo "to"  
  tail -n 1 /root/access1.log | awk '{print $4 " " $5}'  

  echo ""  

  echo "10 IP addresses with maximal count of requests:"  

  cat /root/access1.log | awk '{print $1}' | sort | uniq -c | sort -bgr | head -n 10  

  echo "10 URI with maximal count of requests:"  

  cat /root/access1.log | awk '{print $7}' | sort | uniq -c | sort -bgr | head -n 10  

  echo "HTTP status codes and their count:"  

  cat /root/access1.log | awk '{print $9}' | sort | uniq -c | sort -bgr | grep -v "-"  
  
  echo "Failed requests:"  
  
  cat /root/access1.log | grep -v "HTTP"  

  } | mutt -s "Analize of access.log" -- root@${HOSTNAME}  


  rm -f "${lockfile}"  
  trap - INT TERM EXIT  
 EXIT  
else    
  echo "Failed to acquire lockfile: $lockfile."  
  echo "Held by $(cat $lockfile)"  
fi  
