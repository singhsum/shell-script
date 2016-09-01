#!/bin/bash
#@Author=Kraken

#Usage: This script is used to produce the health check report for weblogic based system

#Define Color here
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#Variable declaration
WLST_Path='/idmapp/apps/Oracle/Middleware/wlserver_10.3/server/bin/'
LOG_PATH='/idmapp/scripts/logs'
scriptPath='/idmapp/scripts/'
currentPath=""
Report_Path='/idmapp/scripts/reports'

echo "" > ${LOG_PATH}/serverStatus.log
echo "" > ${LOG_PATH}/HealthCheck.log
echo "" > ${Report_Path}/HealthCheck.report
echo "" > ${LOG_PATH}/DSStatus.log

echo "#############################################################" >> ${Report_Path}/HealthCheck.report
echo "#################### Health Check Report ####################" >> ${Report_Path}/HealthCheck.report
echo "#############################################################" >> ${Report_Path}/HealthCheck.report
echo "################## Application Name : IAM ###################" >> ${Report_Path}/HealthCheck.report
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
                        statusCheck=$(grep -i AdminServer $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok | wc -l | tr -d '')
                elif [ "$1" = "OAM1" ]; then
                        statusCheck=$(grep -i oam_server1 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "OAM2" ]; then
                        statusCheck=$(grep -i oam_server2 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "ODSM1" ]; then
                        statusCheck=$(grep -i odsm_server1 $LOG_PATH/serverStatus.log | grep -i running | grep -i health_ok  | wc -l | tr -d '')
                elif [ "$1" = "ODSM2" ]; then
                        statusCheck=$(grep -i odsm_server2 $LOG_PATH/serverStatus.log  | grep -i running | grep -i health_ok | wc -l | tr -d '')
                elif [ "$1" = "OUD1" ]; then
                        statusCheck=$(ps -ef | grep -i oud | grep -i "start-ds" | grep -i "DZenoss" | grep -i "exlaklprdidmw1" | wc -l |  tr -d '')
                else
                        statusCheck='0'
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

                                                                        processCheck "OAM1"
                                                if [ "$status" = "true" ]; then
                                                        echo "  2. OAM server-1         :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  2. OAM server-1         :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "OAM2"
                                                if [ "$status" = "true" ]; then
                                                        echo "  3. OAM server-2         :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  3. OAM server-2         :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi


                                                                        processCheck "ODSM1"
                                                if [ "$status" = "true" ]; then
                                                        echo "  4. ODSM Server-1        :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  4. ODSM Server-1        :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "ODSM2"
                                                if [ "$status" = "true" ]; then
                                                        echo "  5. ODSM Server-2        :       OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  5. ODSM Server-2        :       Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                                                        processCheck "OUD1"
                                                if [ "$status" = "true" ]; then
                                                        echo "  6. OUD Server-1         :        OK" >> ${Report_Path}/HealthCheck.report
                                                else
                                                        echo "  6. OUD Server-1         :         Not OK" >> ${Report_Path}/HealthCheck.report
                                                fi

                                Count_Server=$(grep -i "Running" $LOG_PATH/serverStatus.log | grep -i "Server Stat" | wc -l | tr -d '')
                                #Count_Server=$(Count_Server + 1)
                                        if [ "$Count_Server" = "5" ]; then
                                                echo "# Note: All the 5 weblogic services are running, after restart it might take some time for MBEAN to be set, then status will be changed" >> ${Report_Path}/HealthCheck.report
                                        else
                                                echo "# Note: Few weblogic services are down, please start them if needed : " ${Count_Server} >> ${Report_Path}/HealthCheck.report
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
