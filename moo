#!/bin/bash

### BEGIN INIT INFO
# Provides:          moo
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      2 3 4 5
# Short-Description: LambdaMoo Server
# Description:       LambdaMoo Server
### END INIT INFO

# install this in /etc/init.d/ and:
#    chmod +x /etc/init.d/moo
#    update-rc.d -f moo defaults

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

export MOONAME=yibmoo
export MOOPORT=7777
export MOOROOT=/home/moo/MOO-1.8.1

test -f ${MOOROOT}/moo || exit 0

cd ${MOOROOT}

case "$1" in
    start)	
        echo -n "Starting ${MOONAME} MOO"
        if [ -r ${MOOROOT}/../${MOONAME}.db.new ]
        then
            DATE=`date +%Y_%m_%d_%T`
	        echo "Saving old dump as ${MOONAME}.db.$DATE"
            mv ${MOOROOT}/../${MOONAME}.db ${MOOROOT}/../${MOONAME}.db.$DATE
	        echo "renaming new dump to ${MOONAME}.db"
            mv ${MOOROOT}/../${MOONAME}.db.new ${MOOROOT}/../${MOONAME}.db
	        echo "zipping old dump"
            gzip ${MOOROOT}/../${MOONAME}.db.$DATE &
        fi
        if [ -r ${MOOROOT}/../${MOONAME}.log ]
        then
            cat ${MOOROOT}/../${MOONAME}.log >> ${MOOROOT}/../${MOONAME}.log.old
            rm ${MOOROOT}/../${MOONAME}.log
        fi
        start-stop-daemon -c moo --start --quiet --exec ${MOOROOT}/moo -- -l ${MOOROOT}/../${MOONAME}.log ${MOOROOT}/../${MOONAME}.db ${MOOROOT}/../${MOONAME}.db.new ${MOOPORT} &
        echo "." 
	    ;;
    stop)	
        echo -n "Stopping ${MOONAME} MOO"
        #killall -15 moo
        start-stop-daemon -c moo --stop --quiet --exec ${MOOROOT}/moo -- -l ${MOOROOT}/../${MOONAME}.log ${MOOROOT}/../${MOONAME}.db ${MOOPORT} 
        echo "."
        ;;
    restart) 
        echo -n "Restarting ${MOONAME} MOO"
        start-stop-daemon -c moo --stop --quiet --exec ${MOOROOT}/moo -- -l ${MOOROOT}/../${MOONAME}.log ${MOOROOT}/../${MOONAME}.db ${MOOPORT} &
	    sleep 1
        if [ -r ${MOONAME}.db.new ]
        then
            DATE=`date +%Y_%m_%d_%T`
            mv ${MOOROOT}/../${MOONAME}.db ${MOOROOT}/../${MOONAME}.db.$DATE
            mv ${MOOROOT}/../${MOONAME}.db.new ${MOOROOT}/../${MOONAME}.db
            gzip ${MOOROOT}/../${MOONAME}.db.$DATE&
        fi
        if [ -r ${MOOROOT}/../${MOONAME}.log ]
        then
            cat ${MOOROOT}/../${MOONAME}.log >> ${MOOROOT}/../${MOONAME}.log.old
            rm ${MOOROOT}/../${MOONAME}.log
        fi
        start-stop-daemon -c moo --start --quiet --exec ${MOOROOT}/moo -- -l ${MOOROOT}/../${MOONAME}.log ${MOOROOT}/../${MOONAME}.db ${MOOROOT}/../${MOONAME}.db.new ${MOOPORT}
        echo "."
        ;;
    reload|force-reload)
	    echo -n "Reloading $DESC: $NAME"
	    start-stop-daemon -c moo --stop --quiet --oknodo --signal 1 --exec ${MOOROOT}/moo -- -l ${MOOROOT}/../${MOONAME}.log ${MOOROOT}/../${MOONAME}.db ${MOOPORT} &
	    echo "."
	    ;;

    *)
	    N=/etc/init.d/$NAME
	    echo "Usage: $N start|stop|restart|reload|force-reload"
        exit 1 
        ;;
esac
exit 0
