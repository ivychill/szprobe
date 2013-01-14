if [ $# != 2 ]; then
  echo "$0 <production|development|test> <start|stop|run> "
  exit
fi

echo "this script has to be executed within the app_home, waiting 3 seconds to continue or press control-c to stop..."
sleep 3
#APP_HOME=/home/caiqingfeng/webapps/szprobe2/current
APP_HOME=/home/www/szprobe2/current
if [ $1 == "development" ]; then
  APP_HOME=${HOME}/Desktop/workspace/szprobe-2.x
fi

script_rb="utils/fake-traffics-copy-of-201212.rb"
DAEMON="${APP_HOME}/script/daemon"
RAILS_ENV=$1 $DAEMON $2 ${script_rb}

