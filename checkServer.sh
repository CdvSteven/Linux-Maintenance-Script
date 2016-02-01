#!/bin/sh

host_dir="/data/test/"

file_monitor="procMonitor.lst"

file_name="Info.log"
pid=0
function get_proc_num()
{
  num=`ps -ef | grep -w $1 | grep -v grep | grep -v tail | wc -l`
  return $num
}

function get_proc_id()
{
  pid=`ps -ef | grep -w $1 | grep -v grep | awk '{print $2}'`
}
pramters="$#"
echo "num: "$pramters
if [ "$pramters" -ne "0" ]; then
   totaltime="$1" 
   echo "runtime paramter: "$totaltime" minites"
else
   totaltime=60
fi
num_server=$[$(cat $host_dir$file_monitor|wc -l) +1]
time_each=`expr $totaltime / $num_server`
time=$[$time_each*60]
echo "time:"$time
IP=` ifconfig | grep 'inet addr:' -m 1|grep -v '127.0.0.1'|cut -d: -f2 | awk '{print $1}'`
for proc_name in `cat $host_dir$file_monitor | awk -F',' '{print $1}'`; do
  get_proc_num $proc_name
  number=$?
  echo $proc_name"   instance:  "$number
  echo $(date)" On Machine: "$IP>>$host_dir$file_name
  cpuidle=$(sar 1 $time |awk '{ssd=NF} END{print $ssd}')
  mem=`top -b -n 1|grep Mem`
  echo  "System Cpu Average idle "$cpuidle"%">>$host_dir$file_name
  echo  "System " $mem>>$host_dir$file_name

  if [ $number -ne 0 ]
  then
     pid=`pidof $proc_name`
     cpu=`top -n 1 -p $pid|tail -2|head -1|awk '{ssd=NF-4} {print $ssd}'`
     cat /proc/$pid/status|grep -e VmRSS|while read line
     do
         echo "sever name: "$proc_name " pid:" $pid $line" " cpu: "$cpu""%">>$host_dir$file_name
     done 
  elif [ $number -eq 0 ]
  then
       proc_path=`cat $host_dir$file_monitor | grep $proc_name | awk -F',' '{print $2}'`
       proc_run=`cat $host_dir$file_monitor | grep $proc_name | awk -F',' '{print $3}'`
      cd $proc_path && ./$proc_run
      echo "server name: "$proc_name " is killed ,start it now!" >>$host_dir$file_name
  
   echo $blank >> $host_dir$file_name
  fi
done

