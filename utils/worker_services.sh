if [ $# != 3 ]; then
  echo "$0 <production|development|test> <start|stop|run> <all|1|2|3|n>"
  exit
fi

echo "this script has to be executed within the app_home, waiting 3 seconds to continue or press control-c to stop..."
sleep 3
APP_HOME=/home/caiqingfeng/webapps/szprobe2/current
DAEMON="${APP_HOME}/script/daemon"
if [ $3 = "all" ]; then
  for i in {1..10}; do
    script_rb="utils/traffic-crawler-worker-${i}.rb"
    echo "$0 $1 $2 ${script_rb}"
    RAILS_ENV=$1 $DAEMON $2 ${script_rb}
  done
else
  script_rb="utils/traffic-crawler-worker-$3.rb"
  echo "$0 $1 $2 ${script_rb}"
  RAILS_ENV=$1 $DAEMON $2 ${script_rb}
fi
