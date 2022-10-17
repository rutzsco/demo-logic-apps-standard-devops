param lowerAppPrefix string = ''
param longAppName string = ''
param shortAppName string = ''
@allowed(['demo','design','dev','qa','stg','prod'])
param environment string = 'demo'

output logicAppServiceName string = '${lowerAppPrefix}-${longAppName}'
output logicAppStorageAccountName string = '${lowerAppPrefix}${shortAppName}app${environment}'

var storageAccountName = '${lowerAppPrefix}${shortAppName}blob${environment}'
output storageAccountName string = storageAccountName
output blobStorageConnectionName string = '${storageAccountName}-blobconnection'

output logAnalyticsWorkspaceName string = '${lowerAppPrefix}-${longAppName}-${environment}'

output keyVaultName string = '${lowerAppPrefix}${shortAppName}vault${environment}'
