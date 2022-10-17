param lowerAppPrefix string = ''
param longAppName string = ''
param shortAppName string = ''
@allowed(['demo','design','dev','qa','stg','prod'])
param environment string = 'demo'

output logicAppServiceName string = '${lowerAppPrefix}-${longAppName}'
output logicAppStorageAccountName string = '${lowerAppPrefix}${shortAppName}app${environment}'
output logAnalyticsWorkspaceName string = '${lowerAppPrefix}-${longAppName}-logs-${environment}'
output blobStorageAccountName string = '${lowerAppPrefix}${shortAppName}blob${environment}'
output blobStorageConnectionName string = '${lowerAppPrefix}${shortAppName}blob${environment}-blobconnection'
output keyVaultName string = '${lowerAppPrefix}${shortAppName}vault${environment}'
