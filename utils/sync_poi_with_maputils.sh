echo "warning!!! this operation is very dangerous, it will destroy some data stored in szprobe before. Make sure you are very clear to do this..."
echo "sleep 5 seconds to contiue, press control-C if you don't want to continue"
sleep 5
SZPROBE=$HOME/webapps/szprobe2/current
MAPUTILS=$HOME/webapps/maputils/current
echo "dump out maputils's poi to json file"
(cd $MAPUTILS && RAILS_ENV=production ruby utils/dump_poi.rb>/tmp/poi.json)
echo "importing json file to database"
(cd $SZPROBE && RAILS_ENV=production ruby utils/sync_poi.rb)
