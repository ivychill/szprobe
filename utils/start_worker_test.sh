echo "this script has to be executed within the app_home, waiting 3 seconds to continue or press control-c to stop..."
sleep 3
DAEMON=`pwd`/script/daemon
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-1.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-1.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-2.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-2.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-3.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-3.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-4.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-4.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-5.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-5.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-6.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-6.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-7.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-7.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-8.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-8.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-9.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-9.rb
RAILS_ENV=test $DAEMON stop utils/traffic-crawler-worker-10.rb
RAILS_ENV=test $DAEMON start utils/traffic-crawler-worker-10.rb
