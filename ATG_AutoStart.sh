#!/bin/bash
#@Author:Kraken
#Usage: For ATG AutoStartup

#Start

status=""
checkProcess=""


#check which environment we are on
if [[ ( $(hostname) = "exlaklprdatgc1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdatgc2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdatgbc.2degreesmobile.co.
nz" ) || ( $(hostname) = "exlaklprdatgst.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdatgw1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdatgw2.2degreesmobile.
co.nz" )  ]]; then
        echo "Environment recognised as production"
        WebloginAdminServer="exlaklprdatgbc.2degreesmobile.co.nz"
elif [[ ( $(hostname) = "exlhamppatgc1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgc2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgbc.2degreesmobile.co.n
z" ) || ( $(hostname) = "exlhamppatgst.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgw1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgw2.2degreesmobile.co.n
z" )  ]]; then
        echo "Environment recognised as Pre-production"
        WebloginAdminServer="exlhamppatgbc.2degreesmobile.co.nz"
else
        echo "Environment not recognised... for ATG startup script"
        exit 1;
fi



#function for process check
        processCheck(){

                status=""
                checkProcess=""

                if [ "$1" = "NodeManager" ]; then

                        #check if nodemanager process is running
                        checkProcess=$(ps -ef | grep -i nodemanager | grep -iv grep  | grep -i "Xms32m" | grep -i "XmX200m" | wc -l | tr -d '')

                elif [ "$1" = "Commerce1" ]; then
                        #check if Commerce-1 process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_commerce_server1 | wc -l | tr -d '')

                elif [ "$1" = "Commerce2" ]; then
                        #check if Commerce-2 process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_commerce_server2 | wc -l | tr -d '')

                elif [ "$1" = "BCC" ]; then
                        #check if BCC process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_bcc_server | wc -l | tr -d '')

                elif [ "$1" = "Stage" ]; then
                        #check if Stage process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_stage_server | wc -l | tr -d '')

                elif [ "$1" = "Lock1" ]; then
                        #check if Lock-1 process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_lock_server1 | wc -l | tr -d '')

                elif [ "$1" = "Lock2" ]; then
                        #check if Lock-2 process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i store_lock_server2 | wc -l | tr -d '')

                elif [ "$1" = "Admin" ]; then
                        #check if Admin process is running
                        checkProcess=$(ps -ef | grep -i weblogic | grep -iv grep | grep -i AdminServer | wc -l | tr -d '')

                elif [ "$1" = "Web" ]; then
                        #check if web process is running
                        checkProcess=$(ps -ef | grep -i httpd | grep -iv grep  | grep -i apache2 | grep -i start | wc -l | tr -d '')

                fi

                        # Return status value if process is running
                        if [ "$checkProcess" -gt "0" ]; then
                                status="true"
                        else
                                status="false"
                        fi


        }


#check which server are we on and run appropriate services

        #1. Admin server, BCC & lock server-2 on exlhamppatgbc.2degreesmobile.co.nz & exlaklprdatgbc.2degreesmobile.co.nz

                if [[ ( $(hostname) = "exlhamppatgbc.2degreesmobile.co.nz" ) || ( $(hostname) = "exlaklprdatgbc.2degreesmobile.co.nz"  ) ]]; then

                        #NodeManager path : /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin


                        #a. Check if node manager is running or not

                                processCheck "NodeManager"

                                        if [ "$status" = "true" ]; then
                                                echo "NodeManager is already running..."
                                        else
                                                echo "NodeManager is not running..."

                                                #startNodeManager process
                                                nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startNodeManager.sh &

                                                #check if command executed successfully
                                                if [ "$?" = "0" ]; then
                                                        echo "Command for nodemanager executed successfully"
                                                else
                                                        echo "Command for NodeManager startup failed to execute"
                                                fi

                                        echo "Starting NodeManager process..."
                                        sleep 5s


                                                        #check if nodemanager process started successfully or not
                                                        processCheck "NodeManager"

                                                        if [ "$status" = "true" ]; then
                                                                echo "Nodemanager has been automatically restarted...s"
                                                        else
                                                                echo "Nodemanager Autorestart has failed..."
                                                                exit 1;s
                                                        fi

                                        fi


                        #b. Check if Admin server is running or not

                                processCheck "Admin"

                                        if [ "$status" = "true" ]; then
                                                echo "Weblogic Admin is already running..."
                                        else
                                                echo "Weblogic admin is not running..."

                                                #start weblogic server process
                                                nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startWebLogic.sh &

                                                #check if command executed successfully
                                                if [ "$?" = "0" ]; then
                                                        echo "Command for weblogic admin executed successfully"
                                                else
                                                        echo "Command for weblogic admin startup failed to execute"
                                                fi

                                        echo "Starting weblogic admin server..."
                                        sleep 15s

                                        #check if process restarted or not
                                        processCheck "Admin"

                                                if [ "$status" = "true" ]; then
                                                        echo "Weblogic admin server restarted automatically"
                                                else
                                                        echo "Weblogic admin server failed to restart"
                                                fi

                                        fi

                        #c. Check if BCC is running or not


                                processCheck "BCC"

                                        if [ "$status" = "true" ]; then
                                                echo "BCC is already running..."
                                        else
                                                echo "BCC is not running..."

                                                #start BCC server process
                                                nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_bcc_server htt
p://${WebloginAdminServer}:7001 &

                                                #check if command executed successfully
                                                if [ "$?" = "0" ]; then
                                                        echo "Command for BCC server executed successfully"
                                                else
                                                        echo "Command for BCC server startup failed to execute"
                                                fi


                                        echo "Starting BCC server process..."
                                        sleep 15s

                                                #check if BCC server restarted successfully or not

                                                        processCheck "BCC"

                                                                if [ "$status" = "true" ]; then
                                                                        echo "BCC server restarted Automatically..."
                                                                else
                                                                        echo "BCC servers failed to restart Automatically..."
                                                                fi

                                        fi


                        #d. Check if Lock server-2 is running or not

                                processCheck "Lock2"

                                        if [ "$status" = "true" ]; then
                                                echo "Lock server-2 is already running..."
                                        else
                                                echo "Lock server-2 is not running..."

                                                #start Lock2 server process
                                                nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_lock_server2 h
ttp://${WebloginAdminServer}:7001 &

                                                #check if command executed successfully
                                                if [ "$?" = "0" ]; then
                                                        echo "Command for Lock2 server executed successfully"
                                                else
                                                        echo "Command for Lock2 server startup failed to execute"
                                                fi

                                        echo "Starting Lock server-2 process..."
                                        sleep 15s

                                                        #check if process started running

                                                                processCheck "Lock2"

                                                                        if [ "$status" = "true" ]; then
                                                                                echo "Lock server-2 process started automatically..."
                                                                        else
                                                                                echo "Lock server-2 process failed to restart Automatically..."
                                                                        fi

                                        fi



                        status=""
                        checkProcess=""
                else
                        echo "Skipping admin, BCC & Lock-2 check..."

                        status=""
                        checkProcess=""

                fi

        #2. Stage server & lock server-1 on exlaklprdatgst.2degreesmobile.co.nz & exlhamppatgst.2degreesmobile.co.nz

                if [[ ( $(hostname) = "exlaklprdatgst.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgst.2degreesmobile.co.nz"  ) ]]; then

                        # NodeManager Path : /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin

                        #a. Check if node manager is running or not

                                processCheck "NodeManager"

                                        if [ "$status" = "true" ]; then
                                                echo "NodeManager is already running..."
                                        else
                                                echo "NodeManager is not running..."

                                                #startNodeManager process
                                                nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startNodeManager.sh &

                                                #check if command executed successfully
                                                if [ "$?" = "0" ]; then
                                                        echo "Command for nodemanager executed successfully"
                                                else
                                                        echo "Command for NodeManager startup failed to execute"
                                                fi

                                        echo "Starting NodeManager process..."
                                        sleep 5s


                                                        #check if nodemanager process started successfully or not
                                                        processCheck "NodeManager"

                                                        if [ "$status" = "true" ]; then
                                                                echo "Nodemanager has been automatically restarted...s"
                                                        else
                                                                echo "Nodemanager Autorestart has failed..."
                                                                exit 1;s
                                                        fi

                                        fi


                        #b. Check if Stage server is running or not

                                processCheck "Stage"

                                if [ "$status" = "true" ]; then
                                        echo "Stage server process is already running..."
                                else
                                        echo "Stage server process is not running..."

                                        #start stage server process
                                        nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_stage_server http://${
WebloginAdminServer}:7001 &

                                                #check if command executed successfully or not

                                                if [ "$?" = "0" ]; then
                                                        echo "Command for stage server executed successfully"
                                                else
                                                        echo "Command for Stage server startup failed to execute"
                                                fi


                                        echo "Starting Stage server process..."
                                        sleep 15s

                                                        #check if process restarted or not

                                                        processCheck "Stage"

                                                                if [ "$status" = "true" ]; then
                                                                        echo "Stage server restarted Automatically..."
                                                                else
                                                                        echo "Stage server failed to restart Automatically..."
                                                                fi

                                fi

                        #c. Check if lock server-1 is running or not

                                processCheck "Lock1"

                                if [ "$status" = "true" ]; then
                                        echo "Lock-1 server process is already running..."
                                else
                                        echo "Lock-1 server proces is not running..."

                                        #start Lock server-1 process
                                        nohup /atgbcc/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_lock_server1 http://${
WebloginAdminServer}:7001 &

                                                #check if command executed successfully or not

                                                if [ "$?" = "0" ]; then
                                                        echo "Command for Lock server-1 executed successfully"
                                                else
                                                        echo "Command for Lock server-1 startup failed to execute"
                                                fi


                                        echo "Starting Lock server-1 process..."
                                        sleep 15s


                                                        #check if process restarted automatically

                                                                processCheck "Lock1"

                                                                        if [ "$status" = "true" ]; then
                                                                                echo "Lock server-1 process started automatically..."
                                                                        else
                                                                                echo "Lock server-1 process failed to restart Automatically..."
                                                                        fi

                                fi

                        status=""
                        checkProcess=""

                else
                        echo "Skipping Stage & lock-1 server check..."

                        status=""
                        checkProcess=""

                fi

        #3. Commerce server-1 on exlaklprdatgc1.2degreesmobile.co.nz & exlhamppatgc1.2degreesmobile.co.nz

                if [[ ( $(hostname) = "exlaklprdatgc1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgc1.2degreesmobile.co.nz"  ) ]]; then


                        # NodeManager Path= /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin

                                #check if nodemanager process is running or not

                                processCheck "NodeManager"

                                if [ "$status" = "true" ]; then
                                        echo "NodeManager is already running..."
                                else
                                        echo "NodeManager is not running..."

                                        #start NodeManager process
                                        nohup /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startNodeManager.sh &

                                        #check if command run successfully
                                        if [ "$?" = "0" ]; then
                                                echo "NodeManager process startup command was successful"
                                        else
                                                echo "NodeManager process startup failed to start"
                                                exit 1;
                                        fi

                                        echo "Commerce server process starting..."
                                        sleep 10s

                                                processCheck "NodeManager"

                                                if [ "$status" = "true" ]; then
                                                        echo "NodeManager process started automatically..."
                                                else
                                                        echo "NodeManager process failed to restart automatically..."
                                                fi

                                fi

                        #a. Check if Commerce server-1 is running or not


                                #check is commerce server process is running or not
                                processCheck "Commerce1"

                                if [ "$status" = "true" ]; then
                                        echo "Commerce-1 server services are already running..."
                                else

                                        echo "Commerce-1 server services are not running..."

                                                #start commerce server services
                                                nohup /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_commerce_
server1 http://${WebloginAdminServer}:7001 &

                                        # check if above command didn't run
                                                if [ "$?" = "0" ]; then
                                                        echo "Commerce-1 process command was success"
                                                else
                                                        echo "Commerce-1 process command was failed to start"
                                                        exit 1;
                                                fi

                                        echo "Starting Commerce-1 process..."
                                        sleep 15s
                                        #check if process started or not

                                        processCheck "Commerce1"

                                        if [ "$status" = "true" ]; then
                                                echo "Commerce-1 process started automatically..."
                                        else
                                                echo "Commerce-1 process failed to restart automatically..."
                                                exit 1;
                                        fi

                                fi

                        status=""
                        checkProcess=""

                else
                        echo "Skipping Commerce server-1 check..."

                        status=""
                        checkProcess=""

                fi

        #4. Commerce server-2 on exlaklprdatgc2.2degreesmobile.co.nz & exlhamppatgc2.2degreesmobile.co.nz

                if [[ ( $(hostname) = "exlaklprdatgc2.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgc2.2degreesmobile.co.nz"  ) ]]; then

                        # NodeManager Path= /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin

                                #check if nodemanager process is running or not

                                processCheck "NodeManager"

                                if [ "$status" = "true" ]; then
                                        echo "NodeManager is already running..."
                                else
                                        echo "NodeManager is not running..."

                                        #start NodeManager process
                                        nohup /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startNodeManager.sh &

                                        #check if command run successfully
                                        if [ "$?" = "0" ]; then
                                                echo "NodeManager process startup command was successful"
                                        else
                                                echo "NodeManager process startup failed to start"
                                                exit 1;
                                        fi

                                        echo "Commerce server process starting..."
                                        sleep 10s

                                                processCheck "NodeManager"

                                                if [ "$status" = "true" ]; then
                                                        echo "NodeManager process started automatically..."
                                                else
                                                        echo "NodeManager process failed to restart automatically..."
                                                fi

                                fi

                        #a. Check if Commerce server-2 is running or not


                                #check is commerce server process is running or not
                                processCheck "Commerce2"

                                if [ "$status" = "true" ]; then
                                        echo "Commerce-2 server services are already running..."
                                else

                                        echo "Commerce-2 server services are not running..."

                                                #start commerce server services
                                                nohup /atgcommerce/Oracle/Middleware/Oracle_Home/user_projects/domains/twod_domain/bin/startManagedWebLogic.sh store_commerce_
server2 http://${WebloginAdminServer}:7001 &

                                        # check if above command didn't run
                                                if [ "$?" = "0" ]; then
                                                        echo "Commerce-2 process command was success"
                                                else
                                                        echo "Commerce-2 process command was failed to start"
                                                        exit 1;
                                                fi

                                        echo "Starting Commerce-2 process..."
                                        sleep 15s
                                        #check if process started or not

                                        processCheck "Commerce2"

                                        if [ "$status" = "true" ]; then
                                                echo "Commerce-2 process started automatically..."
                                        else
                                                echo "Commerce-2 process failed to restart automatically..."
                                                exit 1;
                                        fi

                                fi


                        status=""
                        checkProcess=""


                else

                        status=""
                        checkProcess=""

                        echo "Skipping Commerce server-2 check..."
                fi

        #5. Web server-1 & 2 on exlaklprdatgw1.2degreesmobile.co.nz & exlhamppatgw1.2degreesmobile.co.nz & exlaklprdatgw2.2degreesmobile.co.nz & exlhamppatgw2.2degreesmobile.
co.nz

                if [[ ( $(hostname) = "exlaklprdatgw1.2degreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgw1.2degreesmobile.co.nz"  ) || ( $(hostname) = "exlaklprdatgw2.2d
egreesmobile.co.nz" ) || ( $(hostname) = "exlhamppatgw2.2degreesmobile.co.nz"  ) ]]; then

                        #a. Check if web server-1 is running or not

                                processCheck "Web"

                                if [ "$status" = "true" ]; then
                                        echo "Web server is already running"
                                else

                                        echo "Web server process is not running"

                                        # start web server process
                                                /atgstaging/apache2/bin/apachectl restart

                                                # check if above command didn't run
                                                if [ "$?" = "0" ]; then
                                                        echo "Web server process restart command was successful"
                                                else
                                                        echo "Web server process restart command failed, please check logs for details"
                                                        exit 1;
                                                fi

                                        echo "Starting web server process..."
                                        sleep 10s

                                                # Check if above process actually restarted automatically or not
                                                processCheck "Web"

                                                if [ "$status" = "true" ]; then
                                                        echo "Web server process restarted Automatically..."
                                                else
                                                        echo "Web server process failed to restart automatically, please check server logs..."
                                                fi

                                fi

                        #command for process restart /atgstaging/apache2/bin/apachectl restart

                        status=""
                        checkProcess=""

                else
                        echo "Skipping Web server-1 check..."

                        status=""
                        checkProcess=""

                fi



#End
