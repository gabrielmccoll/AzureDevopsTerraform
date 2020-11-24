$name = "jekyllstatictest"
$location = "westeurope"
$subscriptionid = "?????"

#set the variables

Set-AzContext -SubscriptionId $subscriptionid
$RG = New-AzResourceGroup -Name $name -Location $location 

#create the app and make it a service principal
$app = New-AzureRmADApplication -DisplayName $name -IdentifierUris "https://$name.com" 
$sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId 

Start-Sleep 20 #waiting for the app to provision so can apply perms to it. 

New-AzRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ApplicationId

#https://www.sabin.io/blog/adding-an-azure-active-directory-application-and-key-using-powershell/
# you need to do this in the correct format
function New-AesManagedObject($key, $IV) {

    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256

    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }

    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }

    $aesManaged
}

function New-AesKey() {
    $aesManaged = New-AesManagedObject 
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

#Create the 44-character key value

$keyValue = New-AesKey
$appsecret = New-AzureRmADAppCredential -ApplicationId $sp.ApplicationId -Password (ConvertTo-SecureString ($keyValue) -AsPlainText -Force) -EndDate (Get-Date).AddMonths(12)

"********
copy this down , you need it later  it's the app secret key   >>    " + $keyValue

"This is the application / service principal ID . copy this too >>  " +  $app.ApplicationId 