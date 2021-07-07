#!/bin/bash

lockfile=/root/lockfile

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; 
then
  trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

  if [[ ! -e /root/count.src ]]; then count=1>/root/count.src; fi
  source /root/count.src

    if [ $count -gt 670 ]; then echo count=1 > /root/count.src; count=1;fi

  
  count2=$(expr $count + 100)

  sed -n $count,${count2}p /root/access.log > /root/access1.log

  echo count=$count2 > /root/count.src

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
  else  
  echo "Failed to acquire lockfile: $lockfile."
  echo "Held by $(cat $lockfile)"
fi
