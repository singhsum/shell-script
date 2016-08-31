#!/bin/bash
#@Author: kraken

#checking logging directories
LOG_PATH='/home/oamadm/scripts/logs'

        if [ -d "$LOG_PATH" ]; then
                touch ${LOG_PATH}/nohup.log
        else
                mkdir ${LOG_PATH}
                touch ${LOG_PATH}/nohup.log
        fi

echo "Please do a tailing on this logs : $LOG_PATH/nohup.log And $LOG_PATH/Autoscript.log"

echo "Start time of script = $(date)" >>${LOG_PATH}/Autoscript.log

#setting OHS path
OHS_PATH='/idmapp/apps/Oracle/Middleware/Oracle_WT1/instances/instance1/bin/'

#setting node manager path
weblogic_NM='/idmapp/apps/Oracle/Middleware/wlserver_10.3/server/bin'

#setting weblogic path
weblogic_bin='/idmapp/apps/Oracle/Middleware/user_projects/domains/oam_domain/bin'

#setting OUD path
OUD_PATH='/idmapp/apps/Oracle/Middleware/asinst_1/OUD/bin'

#setting server name
        if [[ ( $(hostname) = "exlhamppidmw1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdidmw1.2degreesmobile.co.nz"  ) ]]; then
                NameServer=1
                echo "Envirnoment Identified as OAM & Server : $(hostname)" >>${LOG_PATH}/Autoscript.log
        elif [[ (  $(hostname) = "exlhamppidmw2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdidmw2.2degreesmobile.co.nz" )  ]]; then
                NameServer=2
                echo "Envirnoment Identified as OAM & Server : $(hostname)" >>${LOG_PATH}/Autoscript.log
        else
                NameServer="0"
                echo "Environment Not Identified!!!" >>${LOG_PATH}/Autoscript.log
                exit 1;
        fi

#startup URL setup for managed services
        if [ $(hostname) = "exlhamppidmw1.2degreesmobile.co.nz" ]; then
                LoggedInHostName="exlhamppidmw1.2degreesmobile.co.nz"
        elif [ $(hostname) = "exlaklprdidmw1.2degreesmobile.co.nz" ]; then
                LoggedInHostName="exlaklprdidmw1.2degreesmobile.co.nz"
        elif [ $(hostname) = "exlhamppidmw2.2degreesmobile.co.nz" ]; then
                LoggedInHostName="exlhamppidmw1.2degreesmobile.co.nz"
        elif [ $(hostname) = "exlaklprdidmw2.2degreesmobile.co.nz" ]; then
                LoggedInHostName="exlaklprdidmw1.2degreesmobile.co.nz"
        fi


#AD Connection test
ADPort=636
ADTIMEOUT=10

if [[ ( $(hostname) = "exlaklprdidmw2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdidmw1.2degreesmobile.co.nz"  ) ]]; then
        ADHost1='SNZCLAKL098.nzc.co.nz'
        ADHost2='SNZCLAKL099.nzc.co.nz'
        ADHost3='SNZCLAKL100.nzc.co.nz'

        #do connection test on each of AD, if not a single AD connects, don't start the services
        if nc -w $ADTIMEOUT -z $ADHost1 $ADPort; then
                echo "Connection to AD : $ADHost1 is success" >>${LOG_PATH}/Autoscript.log
                echo "Skipping other AD connection as one AD is connecting"  >>${LOG_PATH}/Autoscript.log
        else
                if nc -w $ADTIMEOUT -z $ADHost2 $ADPort; then
                        echo "Connection to AD : $ADHost2 is success" >>${LOG_PATH}/Autoscript.log
                else
                        if nc -w $ADTIMEOUT -z $ADHost3 $ADPort; then
                                echo "Connection to AD : $ADHost3 is success" >>${LOG_PATH}/Autoscript.log
                        else
                                echo "Connection to all the AD has failed, autostart script won't run" >>${LOG_PATH}/Autoscript.log
                                exit 1;
                        fi
                fi

        fi

elif [[ (  $(hostname) = "exlhamppidmw2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppidmw1.2degreesmobile.co.nz" )  ]]; then
        ADHost1='PNZCLHAM098.NZCPPE.co.nz'
        ADHost2='PNZCLHAM099.NZCPPE.co.nz'
        ADHost3='PNZCLHAM100.NZCPPE.co.nz'

        #do connection test on each of AD, if not a single AD connects, don't start the services
        if nc -w $ADTIMEOUT -z $ADHost1 $ADPort; then
                echo "Connection to AD : $ADHost1 is success" >>${LOG_PATH}/Autoscript.log
                echo "Skipping other AD connection as one AD is connecting"  >>${LOG_PATH}/Autoscript.log
        else
                if nc -w $ADTIMEOUT -z $ADHost2 $ADPort; then
                        echo "Connection to AD : $ADHost2 is success" >>${LOG_PATH}/Autoscript.log
                else
                        if nc -w $ADTIMEOUT -z $ADHost3 $ADPort; then
                                echo "Connection to AD : $ADHost3 is success" >>${LOG_PATH}/Autoscript.log
                        else
                                echo "Connection to all the AD has failed, autostart script won't run" >>${LOG_PATH}/Autoscript.log
                                exit 1;
                        fi
                fi

        fi

else
        echo "Environment Not Identified!!!" >>${LOG_PATH}/Autoscript.log
        exit 1;
fi

#DB Connection check
DBPort=1522
DBTIMEOUT=10

if [[ ( $(hostname) = "exlaklprdidmw2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdidmw1.2degreesmobile.co.nz"  ) ]]; then
        DBHost1='exdakldb01-ib.2degreesmobile.co.nz'
        DBHost2='exdakldb02-ib.2degreesmobile.co.nz'

        #do connection test to DB
        if nc -w $DBTIMEOUT -z $DBHost1 $DBPort; then
                echo " Connection to DB : $DBHost1 is success" >> ${LOG_PATH}/Autoscript.log
                echo "Skipping other DB connection as one is connecting"  >> ${LOG_PATH}/Autoscript.log
        else
                if nc -w $DBTIMEOUT -z $DBHost2 $DBPort; then
                        echo "Connection to DB : $DBHost2 is success"  >> ${LOG_PATH}/Autoscript.log
                else
                        echo "Connection to both DB has failed, autostart script won't run" >> ${LOG_PATH}/Autoscript.log
                        exit 1;
                fi
        fi

elif [[ (  $(hostname) = "exlhamppidmw2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppidmw1.2degreesmobile.co.nz" )  ]]; then
        DBHost1='exdhamdb01-ib.2degreesmobile.co.nz'
        DBHost2='exdhamdb02-ib.2degreesmobile.co.nz'

        #do connection test to DB
        if nc -w $DBTIMEOUT -z $DBHost1 $DBPort; then
                echo " Connection to DB : $DBHost1 is success" >> ${LOG_PATH}/Autoscript.log
                echo "Skipping other DB connection as one is connecting"  >> ${LOG_PATH}/Autoscript.log
        else
                if nc -w $DBTIMEOUT -z $DBHost2 $DBPort; then
                        echo "Connection to DB : $DBHost2 is success"  >> ${LOG_PATH}/Autoscript.log
                else
                        echo "Connection to both DB has failed, autostart script won't run" >> ${LOG_PATH}/Autoscript.log
                        exit 1;
                fi
        fi


else
        echo "Environment Not Identified!!!" >>${LOG_PATH}/Autoscript.log
        exit 1;
fi


status=""

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#function for process check
processCheck(){

status=""

#echo "Starting process check"


        if [ "$1" = "NodeManager" ]; then

                #check if Node Manager is running
                processCheck_NM=$(ps -ef | grep -i "weblogic.NodeManager" | grep -iv grep | grep -i "Xmx200m" | grep -i  "Xms32m" | wc -l | tr -d '')

                if [ "$processCheck_NM" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi

        elif [ "$1" = "AdminServer" ]; then

                #check if weblogic admin is running or not
                processCheck_Admin=$(ps -ef | grep -i weblogic | grep -i adminserver | grep -vi grep  | wc -l | tr -d '')

                if [ "$processCheck_Admin" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi

        elif [ "$1" = "ODSM" ]; then

                #check if ODSM service is running or not
                processCheck_ODSM=$(ps -ef | grep -i weblogic | grep -i odsm | grep -vi grep | wc -l | tr -d '')

                if [ "$processCheck_ODSM" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi

        elif [ "$1" = "OUD" ]; then

                #check if OUD service is running or not
                processCheck_OUD=$(ps -ef | grep -i DirectoryServer | grep -i oud | grep -iv grep | wc -l | tr -d '')

                if [ "$processCheck_OUD" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi

        elif [ "$1" = "OAM" ]; then

                #check if OAM service is running or not
                processCheck_OAM=$(ps -ef | grep -i weblogic | grep -i oam_server | grep -vi grep  | wc -l | tr -d '')

                if [ "$processCheck_OAM" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi


        fi
#echo "Process completed"

}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if [  $(hostname) = "exlhamppidmw2.2degreesmobile.co.nz" ]; then
        echo "Skipping OUD restart as we are on node-2 of pre-prod" >> ${LOG_PATH}/Autoscript.log
else

#Check if OUD services are running or not
if [ -d "$OUD_PATH" ]; then
        #echo " path is correct"

        #Check if OUD service is running
        processCheck "OUD"

        #echo "running processCheck function on OUD...."

        if [ "$status" = "true" ]; then
                echo "OUD services is already running" >>${LOG_PATH}/Autoscript.log
                status=""
        else
                echo "OUD services are not running!!!!" >>${LOG_PATH}/Autoscript.log
                echo "Starting OUD....." >>${LOG_PATH}/Autoscript.log
                status=""

                #Start OUD process
                nohup ${OUD_PATH}/start-ds 1>>${LOG_PATH}/nohup.log  2>>${LOG_PATH}/nohup.log &

                                #check if this command didn't run correctly
                                if [ "$?" = "0" ]; then
                                        echo "OUD service startup running" >>${LOG_PATH}/Autoscript.log
                                else
                                        echo "  ...there was some nohup running OUD startup command" >>${LOG_PATH}/Autoscript.log
                                fi

                #echo "Starting....."

                sleep 15s

                        #Check if OUD process started
                        processCheck "OHS"


                        if [ "$status" = "true" ]; then
                                echo "OUD service restarted Automatically" >>${LOG_PATH}/Autoscript.log
                                status=""
                        else
                                echo "OUD services failed to restart, please check oud logs" >>${LOG_PATH}/Autoscript.log
                                status=""
                        fi
        fi

else
        echo " OUD directory services bin path is not found at : $OUD_PATH " >>${LOG_PATH}/Autoscript.log
        exit 1;

fi
fi


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#check if node manager is running or not


if [ -d "$weblogic_NM" ]; then

        #check if node manager process is running or not
        processCheck "NodeManager"

                if [ "$status" = "true" ]; then
                        echo "Weblogic Node Manager is Already running" >>${LOG_PATH}/Autoscript.log
                        status=""
                else
                        echo " weblogic Node Manager is not running !!!!" >>${LOG_PATH}/Autoscript.log
                        echo "          Starting Node Manager....." >>${LOG_PATH}/Autoscript.log
                        status=""

                        # start node manager process
                        nohup ${weblogic_NM}/startNodeManager.sh 1>/home/oamadm/scripts/logs/nohup.log 2>/home/oamadm/scripts/logs/nohup.log &

                                #check if this command didn't run correctly
                                if [ "$?" = "0" ]; then
                                        echo "  Node Manager startup running" >>${LOG_PATH}/Autoscript.log
                                else
                                        echo "  ...there was some nohup running node manager command" >>${LOG_PATH}/Autoscript.log
                                        exit 1;
                                fi

                        sleep 15s

                                # check if node manager process started or not
                                processCheck "NodeManager"

                                if [ "$status" = "true" ]; then
                                        echo "Node Manager restarted Automatically" >>${LOG_PATH}/Autoscript.log
                                        status=""
                                else
                                        echo "Please check node manager logs, node manager failed or restart!!!" >>${LOG_PATH}/Autoscript.log
                                        status=""
                                        exit 1;
                                fi
                fi
else
        echo "Node manager directory not found at : $weblogic_NM" >>${LOG_PATH}/Autoscript.log
        exit 1;
        status=""
fi

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#for weblogic admin & managed servers
if [ -d "$weblogic_bin" ]; then

        #check if we are on Node-1 server, then only start weblogic admin
        if [ "$NameServer" = "1" ]; then


        #check if weblogic admin server is running
        processCheck "AdminServer"

                if [ "$status" = "true" ]; then
                        echo "Weblogic Admin is already running" >>${LOG_PATH}/Autoscript.log
                        status=""
                else
                        echo "Weblogic admin is not running !!!" >>${LOG_PATH}/Autoscript.log
                        echo "          Starting weblogic Admin server...." >>${LOG_PATH}/Autoscript.log
                        status=""

                        #start weblogic admin server
                        nohup ${weblogic_bin}/startWebLogic.sh 1>/home/oamadm/scripts/logs/nohup.log 2>/home/oamadm/scripts/logs/nohup.log &

                                #check if this command didn't run correctly
                                if [ "$?" = "0" ]; then
                                        echo " Weblogic admin startup command is running" >>${LOG_PATH}/Autoscript.log
                                else
                                        echo " ....there was some nohup while running weblogic admin command" >>${LOG_PATH}/Autoscript.log
                                fi

                        sleep 15s

                                #check if weblogic admin process started or not
                                processCheck "AdminServer"

                                if [ "$status" = "true" ]; then
                                        echo "weblogic admin started automatically" >>${LOG_PATH}/Autoscript.log
                                        status=""
                                else
                                        echo "Please check weblogic admin logs, weblogic admin failed to restart!!!!" >>${LOG_PATH}/Autoscript.log
                                        status=""
                                fi
                fi
        else
                echo "Skipping weblogic admin restart as we are on backup node" >>${LOG_PATH}/Autoscript.log

        fi

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 #check if OAM server is running or not
        processCheck "OAM"

                if [ "$status" = "true" ]; then
                        echo "OAM service is already running" >>${LOG_PATH}/Autoscript.log
                        status=""
                else
                        echo "OAM service is not running !!!" >>${LOG_PATH}/Autoscript.log
                        echo "          Starting OAM services ...." >>${LOG_PATH}/Autoscript.log
                        status=""

                                #start OAM services
                                nohup ${weblogic_bin}/startManagedWebLogic.sh oam_server${NameServer} http://${LoggedInHostName}:7001  1>/home/oamadm/scripts/logs/nohup.log 2>/home/oamadm/scripts/logs/nohup.log &

                                        #check if this command didn't run correctly
                                        if [ "$?" = "0" ]; then
                                                echo " OAM service startup command is running" >>${LOG_PATH}/Autoscript.log
                                        else
                                                echo " ....there was some nohup while running OAM command" >>${LOG_PATH}/Autoscript.log
                                        fi

                        sleep 15s

                                        #check if OAM service started or not
                                        processCheck "OAM"

                                        if [ "$status" = "true" ]; then
                                                echo "OAM started automatically" >>${LOG_PATH}/Autoscript.log
                                                status=""
                                        else
                                                echo "Please check OAM startup logs, OAM service failed to restart!!!!" >>${LOG_PATH}/Autoscript.log
                                                status=""
                                                exit 1;
                                        fi
                fi


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        #check if ODSM server is running or not
        processCheck "ODSM"

                if [ "$status" = "true" ]; then
                        echo "ODSM is already running" >>${LOG_PATH}/Autoscript.log
                        status=""
                else
                        echo "ODSM is not running !!!" >>${LOG_PATH}/Autoscript.log
                        echo "          Starting ODSM services ...." >>${LOG_PATH}/Autoscript.log
                        status=""


                                #start ODSM services
                                nohup ${weblogic_bin}/startManagedWebLogic.sh odsm_server${NameServer} http://${LoggedInHostName}:7001 1>/home/oamadm/scripts/logs/nohup.log 2>/home/oamadm/scripts/logs/nohup.log &

                                        #check if this command didn't run correctly
                                        if [ "$?" = "0" ]; then
                                                echo " ODSM service startup command is running" >>${LOG_PATH}/Autoscript.log
                                        else
                                                echo " ....there was some nohup while running ODSM command" >>${LOG_PATH}/Autoscript.log
                                        fi

                        sleep 15s

                                        #check if ODSM service started or not
                                        processCheck "ODSM"

                                        if [ "$status" = "true" ]; then
                                                echo "ODSM started automatically" >>${LOG_PATH}/Autoscript.log
                                                status=""
                                        else
                                                echo "Please check ODSM startup logs, ODSM service failed to restart!!!!" >>${LOG_PATH}/Autoscript.log
                                                status=""
                                        fi
                fi


else
        echo "weblogic admin directory not found at : $weblogic_bin " >>${LOG_PATH}/Autoscript.log
        exit 1;
        status=""
fi

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=

echo "To access console, it will take around 10 minutes & proper startup of services will be also done by that time"
echo " end time of script = $(date)"  >>${LOG_PATH}/Autoscript.log

exit 0;
