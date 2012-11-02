#!/bin/bash
#
RETVAL=0;

do_start() {
echo "Starting szprobe"
#APP_HOME=/home/caiqingfeng/webapps/szprobe2/current
#su - caiqingfeng -c "cd $APP_HOME && script/daemon start utils/goagent/proxy.rb"
#su - caiqingfeng -c "cd $APP_HOME && utils/worker.sh production start all"
APP_HOME=/home/www/szprobe2/current
su - roadclouding -c "cd $APP_HOME && script/daemon start utils/goagent/proxy.rb"
su - roadclouding -c "cd $APP_HOME && utils/worker.sh production start all"
}

do_stop() {
echo "Stopping szprobe"
#APP_HOME=/home/caiqingfeng/webapps/szprobe2/current
#su - caiqingfeng -c "cd $APP_HOME && script/daemon stop utils/goagent/proxy.rb"
#su - caiqingfeng -c "cd $APP_HOME && utils/worker.sh production stop all"
APP_HOME=/home/www/szprobe2/current
su - roadclouding -c "cd $APP_HOME && utils/worker.sh production stop all"
su - roadclouding -c "cd $APP_HOME && script/daemon stop utils/goagent/proxy.rb"
}

do_restart() {
do_stop
do_start
}

case "$1" in
start)
  do_start
;;
stop)
  do_stop
;;
restart)
  do_restart
;;
*)
echo $"Usage: $0 {start|stop|restart}"
exit 1
esac

exit $RETVAL
