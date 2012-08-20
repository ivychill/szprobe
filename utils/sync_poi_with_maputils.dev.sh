echo "warning!!! this operation is very dangerous, it will destroy some data stored in szprobe before. Make sure you are very clear to do this..."
echo "sleep 5 seconds to contiue, press control-C if you don't want to continue"
sleep 5
SZPROBE2=$HOME/Desktop/workspace/szprobe-2.x
MAPUTILS=$HOME/Desktop/rails/fetch-traffic/maputils
echo "dump out maputils's poi to json file"
#(cd $MAPUTILS && ruby utils/dump_poi.rb>/tmp/poi.json)
echo "importing json file to database"
(cd $SZPROBE2 && ruby utils/sync_poi.rb)
