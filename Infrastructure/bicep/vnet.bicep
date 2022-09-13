@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the default subnet hosting the LogicApp.')
param logicAppSubnetName string = 'LogicAppsSubnet'

@description('Specifies the address prefix of the subnet hosting the LogicApp.')
param logicAppSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

var logicAppSubnetNsgName = 'LogicAppsSubnetNsg'

resource logicAppSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: logicAppSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbound'
        properties: {
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          priority: 100
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          direction: 'Outbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          priority: 100
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: logicAppSubnetName
        properties: {
          addressPrefix: logicAppSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: logicAppSubnetNsg.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}


resource logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: logicAppSubnetName
}

output virtualNetworkResourceId string = virtualNetwork.id
output logicAppSubnetId string = logicAppSubnet.id
