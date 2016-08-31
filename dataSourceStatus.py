from java.io import FileInputStream
import java.lang
import os
import string

UCF='/atgbcc/scripts/security/atgadmin-WebLogicConfig.properties'
UKF='/atgbcc/scripts/security/atgadmin-WebLogicKey.properties'
adminURL = "t3://<Hostname>:7001"

connect(userConfigFile=UCF,userKeyFile=UKF,url=adminURL)

allServers=domainRuntimeService.getServerRuntimes();

if (len(allServers) > 0):

  for tempServer in allServers:

    jdbcServiceRT = tempServer.getJDBCServiceRuntime();

    dataSources = jdbcServiceRT.getJDBCDataSourceRuntimeMBeans();

    if (len(dataSources) > 0):

        for dataSource in dataSources:


            print 'DataSource Name -> '  ,   dataSource.getName() , '           | ', ' ConnectionDelay : ' , dataSource.getConnectionDelayTime(), 'ms' , '              | ' ,
' Status : ' , dataSource.getState()
            #print '                     Parent Name     : ' , dataSource.getParent()
            #print '                     ConnectionDelay : ' , dataSource.getConnectionDelayTime(), 'ms'
            #print '                     Status          : ' ,  dataSource.getState()

#below are different parameter's that we can use

#print 'ActiveConnectionsAverageCount      '  ,  dataSource.getActiveConnectionsAverageCount()

            #print 'ActiveConnectionsCurrentCount      '  ,  dataSource.getActiveConnectionsCurrentCount()

            #print 'ActiveConnectionsHighCount         '  ,  dataSource.getActiveConnectionsHighCount()

            #print 'ConnectionDelayTime                '  ,  dataSource.getConnectionDelayTime()

            #print 'ConnectionsTotalCount              '  ,  dataSource.getConnectionsTotalCount()

            #print 'CurrCapacity                       '  ,  dataSource.getCurrCapacity()

            #print 'CurrCapacityHighCount              '  ,  dataSource.getCurrCapacityHighCount()

            #print 'DeploymentState                    '  ,  dataSource.getDeploymentState()

            #print 'FailedReserveRequestCount          '  ,  dataSource.getFailedReserveRequestCount()

            #print 'FailuresToReconnectCount           '  ,  dataSource.getFailuresToReconnectCount()

            #print 'HighestNumAvailable                '  ,  dataSource.getHighestNumAvailable()

            #print 'HighestNumUnavailable              '  ,  dataSource.getHighestNumUnavailable()

            #print 'LeakedConnectionCount              '  ,  dataSource.getLeakedConnectionCount()

            #print 'ModuleId                           '  ,  dataSource.getModuleId()

            #print 'Name                               '  ,  dataSource.getName()

            #print 'NumAvailable                       '  ,  dataSource.getNumAvailable()

            #print 'NumUnavailable                     '  ,  dataSource.getNumUnavailable()

            #print 'Parent                             '  ,  dataSource.getParent()

            #print 'PrepStmtCacheAccessCount           '  ,  dataSource.getPrepStmtCacheAccessCount()

            #print 'PrepStmtCacheAddCount              '  ,  dataSource.getPrepStmtCacheAddCount()

            #print 'PrepStmtCacheCurrentSize           '  ,  dataSource.getPrepStmtCacheCurrentSize()

            #print 'PrepStmtCacheDeleteCount           '  ,  dataSource.getPrepStmtCacheDeleteCount()

            #print 'PrepStmtCacheHitCount              '  ,  dataSource.getPrepStmtCacheHitCount()

            #print 'PrepStmtCacheMissCount             '  ,  dataSource.getPrepStmtCacheMissCount()

            #print 'Properties                         '  ,  dataSource.getProperties()

            #print 'ReserveRequestCount                '  ,  dataSource.getReserveRequestCount()

            #print 'State                              '  ,  dataSource.getState()

            #print 'Type                               '  ,  dataSource.getType()

            #print 'VersionJDBCDriver                  '  ,  dataSource.getVersionJDBCDriver()

            #print 'WaitingForConnectionCurrentCount   '  ,  dataSource.getWaitingForConnectionCurrentCount()

            #print 'WaitingForConnectionFailureTotal   '  ,  dataSource.getWaitingForConnectionFailureTotal()

            #print 'WaitingForConnectionHighCount      '  ,  dataSource.getWaitingForConnectionHighCount()

            #print 'WaitingForConnectionSuccessTotal   '  ,  dataSource.getWaitingForConnectionSuccessTotal()

            #print 'WaitingForConnectionTotal          '  ,  dataSource.getWaitingForConnectionTotal()

            #print 'WaitSecondsHighCount               '  ,  dataSource.getWaitSecondsHighCount()
