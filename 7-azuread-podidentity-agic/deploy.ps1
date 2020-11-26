
[CmdletBinding()]
param (
	$clusterResourceGroupNameInput,
	$nodesResourceGroupNameInput,
	$subscriptionIdInput,
	$subscriptionNameInput,
	$clusterNameInput,
	$appGtwManagedIdentityNameInput,
    $applicationGatewayNameInput,
    $applicationGatewayIdInput
)

$clusterResourceGroupName = $clusterResourceGroupNameInput
$nodesResourceGroupName = $nodesResourceGroupNameInput
$subscriptionId = $subscriptionIdInput
$subscriptionName = $subscriptionNameInput
$clusterName = $clusterNameInput
$appGtwManagedIdentityName = $appGtwManagedIdentityNameInput
$applicationGatewayName = $applicationGatewayNameInput
$applicationGatewayId = $applicationGatewayIdInput

# AKS cluster with managed identity
$clusterManagedIdentityId = (az aks show -g $clusterResourceGroupName -n $clusterName --query identityProfile.kubeletidentity.clientId -otsv)

# The roles Managed Identity Operator and Virtual Machine Contributor must be assigned to the cluster managed identity or service principal, identified by the ID obtained above, 
# before deploying AAD Pod Identity so that it can assign and un-assign identities from the underlying VM/VMSS.
az role assignment create --role "Managed Identity Operator" --assignee $clusterManagedIdentityId --scope "/subscriptions/$subscriptionId/resourcegroups/$nodesResourceGroupName"
az role assignment create --role "Virtual Machine Contributor" --assignee $clusterManagedIdentityId --scope "/subscriptions/$subscriptionId/resourcegroups/$nodesResourceGroupName"

# Set the current Azure subscription
az account set --subscription "$subscriptionName"

# Connect to the AKS Cluster 
az aks get-credentials --resource-group $clusterResourceGroupName --name $clusterName

# Deploy an AAD pod identity in an RBAC-enabled cluster (comment line 62 if not using an RBAC-enabled cluster.)
kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

# Deploy AAD pod identity in non-RBAC cluster (un-comment line 64 if using a non-RBAC cluster.)
# kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment.yaml

# Create a managed identity 
az identity create -g $nodesResourceGroupName -n $appGtwManagedIdentityName

# Wait time for ID to be fully created.
Start-Sleep -Seconds 60

# Obtain clientID for the new managed identity
$identityClientId = (az identity show -g $nodesResourceGroupName -n $appGtwManagedIdentityName --query 'clientId' -o tsv)

# Obtain ResourceID for the new managed identity
$identityResourceId = (az identity show -g $nodesResourceGroupName -n $appGtwManagedIdentityName --query 'id' -o tsv)

# Obtain the Subscription ID
$subscriptionId = (az account show --query 'id' -o tsv)

# Give the identity Contributor access to the Application Gateway
az role assignment create --role Contributor --assignee $identityClientId --scope "$applicationGatewayId"

# Get the Application Gateway resource group ID
$resourceGroupId = az group list --query "[?name=='$clusterResourceGroupName']" | jq -r ".[0].id"

# Give the identity Reader access to the Application Gateway resource group.
az role assignment create --role Reader --assignee $identityClientId --scope "$resourceGroupId"

# Downloads and renames the sample-helm-config.yaml file to helm-agic-config.yaml.
wget https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-helm-config.yaml -O helm-agic-config.yaml

# Link for reference to content of the sample-helm-config.yaml file
#https://azure.github.io/application-gateway-kubernetes-ingress/examples/sample-helm-config.yaml

# Updates the helm-agic-config.yaml and sets RBAC enabled to true using Sed.
sed -i "" "s|<subscriptionId>|${subscriptionId}|g" helm-agic-config.yaml
sed -i "" "s|<resourceGroupName>|${clusterResourceGroupName}|g" helm-agic-config.yaml
sed -i "" "s|<applicationGatewayName>|${applicationGatewayName}|g" helm-agic-config.yaml
sed -i "" "s|<identityResourceId>|${identityResourceId}|g" helm-agic-config.yaml
sed -i "" "s|<identityClientId>|${identityClientId}|g" helm-agic-config.yaml
sed -i -e "" "s|enabled: false # true/false|enabled: true # true/false|" helm-agic-config.yaml

# Adds the Application Gateway Ingress Controller helm chart repo and updates the repo on the AKS cluster.
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update

# Installs the Application Gateway Ingress Controller using helm and helm-agic-config.yaml
helm upgrade --install howtoaks-ingress-azure -f helm-agic-config.yaml application-gateway-kubernetes-ingress/ingress-azure
