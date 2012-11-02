if [ $# != 3 ]; then
  echo "$0 <production|development|test> <start|stop|run> <all|link|1|2|3|n>"
  exit
fi

APP_HOME=/home/caiqingfeng/webapps/szprobe2/current
if [ $1 == "development" ]; then
  APP_HOME=${HOME}/Desktop/workspace/szprobe-2.x
fi

DAEMON="${APP_HOME}/script/daemon"
if [ $3 = "all" ]; then
  script_rb="utils/wap-links-crawler.rb"
  RAILS_ENV=$1 $DAEMON $2 ${script_rb}
  for i in {1..10}; do
    #script_rb="utils/traffic-crawler-worker-${i}.rb"
    script_rb="utils/wap-traffic-crawler-worker-${i}.rb"
    echo "$0 $1 $2 ${script_rb}"
    RAILS_ENV=$1 $DAEMON $2 ${script_rb}
  done
else
  if [ $3 = "link" ]; then
    script_rb="utils/wap-links-crawler.rb"
  else
    script_rb="utils/wap-traffic-crawler-worker-$3.rb"
  fi
  echo "$0 $1 $2 ${script_rb}"
  RAILS_ENV=$1 $DAEMON $2 ${script_rb}
fi
