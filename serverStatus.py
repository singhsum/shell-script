def conn():

                UCF='/atgbcc/scripts/security/atgadmin-WebLogicConfig.properties'
                UKF='/atgbcc/scripts/security/atgadmin-WebLogicKey.properties'
                adminURL = "t3://<Hostname>:7001"

                try:

                        connect(userConfigFile=UCF,userKeyFile=UKF,url=adminURL)

                except ConnectionException,e:
                        print '\033[1;31m Connection to AdminURL failed, please check security directory under /atgbcc/scripts/security & check if both files are present ther
e\033[0m'
                        print '\033[1;31m userConfigFile=atgadmin-WebLogicConfig.properties\033[0m'
                        print '\033[1;31m userKeyFile=atgadmin-WebLogicKey.properties\033[0m'
                        print '\033[1;31m admin url is reachable at t3://exlhamppatgbc.2degreesmobile.co.nz:7001\033[0m'
                        exit()

def servrStatusCheck():
                        domainRuntime()
                        cd('ServerRuntimes')

                        servers=domainRuntimeService.getServerRuntimes()
                        for server in servers:
                             serverName=server.getName();
                             print '##### Server State         #####', server.getState(), server.getListenAddress(), server.getHealthState() , server.getListenPort()


if __name__== "main":
                redirect('/atgbcc/scripts/logs/HealthCheck.log', 'false')
                conn()
                servrStatusCheck()
                exit()

