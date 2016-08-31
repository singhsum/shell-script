#!/bin/bash
#@Author=Kraken

#Usage: This script is used to produce the health check report for weblogic based system

#Define Color here
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#Variable declaration
WLST_Path='/atgbcc/Oracle/Middleware/Oracle_Home/wlserver/server/bin/'
LOG_PATH='/atgbcc/scripts/logs'
scriptPath='/atgbcc/scripts/'
currentPath=""
Report_Path='/atgbcc/scripts/reports'

echo "" > ${LOG_PATH}/serverStatus.log
echo "" > ${LOG_PATH}/HealthCheck.log
echo "" > ${Report_Path}/HealthCheck.report
echo "" > ${LOG_PATH}/DSStatus.log

echo "#############################################################" >> ${Report_Path}/HealthCheck.report
echo "#################### Health Check Report ####################" >> ${Report_Path}/HealthCheck.report
echo "#############################################################" >> ${Report_Path}/HealthCheck.report
echo "################## Application Name = ATG ###################" >> ${Report_Path}/HealthCheck.report
echo "#############################################################" >> ${Report_Path}/HealthCheck.report
echo "############## $(date) ################"  >> ${Report_Path}/HealthCheck.report
echo "#" >> ${Report_Path}/HealthCheck.report
echo "#" >> ${Report_Path}/HealthCheck.report
echo "#" >> ${Report_Path}/HealthCheck.report

echo "Start time of script = $(date)" >> ${LOG_PATH}/HealthCheck.log

#Settings environment variables
        currentPath=$(pwd)

        cd $WLST_Path
        . ./setWLSEnv.sh 2>>${LOG_PATH}/HealthCheck.log 1>>${LOG_PATH}/HealthCheck.log
                #echo $PATH
        cd $currentPath

processCheck(){

        statusCheck=""
        status=""

                if [ "$1" = "Admin" ]; then
                        statusCheck=$(grep -i adminserver $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok | wc -l | tr -d '')
                elif [ "$1" = "BCC" ]; then
                        statusCheck=$(grep -i store_bcc_server $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "C1" ]; then
                        statusCheck=$(grep -i store_commerce_server1 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "C2" ]; then
                        statusCheck=$(grep -i store_commerce_server2 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "L2" ]; then
                        statusCheck=$(grep -i store_lock_server2 $LOG_PATH/serverStatus.log  | grep -i running | grep -i health_ok | wc -l | tr -d '')
                elif [ "$1" = "L1" ]; then
                        statusCheck=$(grep -i store_lock_server1 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "S" ]; then
                        statusCheck=$(grep -i store_stage_server $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                fi

                if [ "$statusCheck" -gt "0" ]; then
                        status="true"
                else
                        status="false"
                fi

}

#1. Checking server status
        java weblogic.WLST ${scriptPath}serverStatus.py >${LOG_PATH}/serverStatus.log 2>&1 ${LOG_PATH}/serverStatus.log

        #check how many servers are healthy
                connectionCheck=$(grep -i "Successfully connected to Admin Server" $LOG_PATH/HealthCheck.log | wc -l | tr -d '')

                        if [ "$connectionCheck" -gt "0" ]; then
                                echo " $(date)  Connection to WLST to admin server was successful..." >> ${LOG_PATH}/serverStatus.log

                                #connection to individual servers
                                        echo "########## Server Status ##########" >> ${Report_Path}/HealthCheck.report

                                        processCheck "Admin"
                                                if [ "$status" = "true" ]; then
                                                        echo "  1. Admin server         :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  1. Admin server         :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "BCC"
                                                if [ "$status" = "true" ]; then
                                                        echo "  2. BCC server           :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  2. BCC server   :               Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "C1"
                                                if [ "$status" = "true" ]; then
                                                        echo "  3. Commerce server-1    :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  3. Commerce server-1    :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi


                                                                        processCheck "C2"
                                                if [ "$status" = "true" ]; then
                                                        echo "  4. Commerce server-2    :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  4. Commerce server-2    :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "L1"
                                                if [ "$status" = "true" ]; then
                                                        echo "  5. Lock server-1        :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  5. Lock server-1        :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi


                                                                        processCheck "L2"
                                                if [ "$status" = "true" ]; then
                                                        echo "  6. Lock server-2        :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  6. Lock server-2        :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                 fi


                                                                        processCheck "S"
                                                if [ "$status" = "true" ]; then
                                                        echo "  7. Stage Server         :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  7. Stage Server         :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                Count_Server=$(grep -i "Running" $LOG_PATH/serverStatus.log | grep -i "Server Stat" | wc -l | tr -d '')

                                        if [ "$Count_Server" = "7" ]; then
                                                echo "# Note: All the 7 servers are running, after restart it might take some time for MBEAN to be set, then status will be changed" >> ${Report_Path}/HealthCheck.report
                                        else
                                                echo "# Note: Few services are down, please start them if needed : " ${Count_Server} >> ${Report_Path}/HealthCheck.report
                                        fi

                        else
                                echo " $(date)  Connection to WLST to admin server failed..." >> ${LOG_PATH}/HealthCheck.log
                                echo "##### Connection to weblogic WLST has failed #####" >> ${Report_Path}/HealthCheck.report
                                exit 1;
                        fi
echo "#" >> ${Report_Path}/HealthCheck.report

echo "########## Data Source Status ##########" >> ${Report_Path}/HealthCheck.report

#2. Check data source status

        java weblogic.WLST ${scriptPath}dataSourceStatus.py >${LOG_PATH}/DSStatus.log 2>&1 ${LOG_PATH}/DSStatus.log

        egrep -i "Datasource|Parent|ConnectionDelay|Status" ${LOG_PATH}/DSStatus.log >> ${Report_Path}/HealthCheck.report

echo "End Time of Script = $(date)" >> ${LOG_PATH}/HealthCheck.log
echo "#" >> ${Report_Path}/HealthCheck.report
echo "############################ End ############################" >> ${Report_Path}/HealthCheck.report


cat  ${Report_Path}/HealthCheck.report


#rm $LOG_PATH/serverStatus.log
exit 0;
