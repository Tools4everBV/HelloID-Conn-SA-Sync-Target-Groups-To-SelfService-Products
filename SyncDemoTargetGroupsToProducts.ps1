#####################################################
# HelloID-SA-Sync-DemoTargetGroups-To-Products
#
# Version: 1.0.1.0
#####################################################
$VerbosePreference = 'SilentlyContinue'
$informationPreference = 'Continue'

# Make sure to create the Global variables defined below in HelloID
#HelloID Connection Configuration
$portalApiKey = $portalApiKey
$portalApiSecret = $portalApiSecret
$BaseUrl = $portalBaseUrl

#HelloID Product Configuration
$ProductAccessGroup = 'Users'           # If not found, the product is created without extra Access Group
$ProductCategory = 'NewProductCateGory' # If the category is not found, it will be created
$SAProductResourceOwner = ''            # If left empty the name will be: "Resource owners [target-systeem] - [Product_Naam]")
$SAProductWorkflow = $null              # If empty. The Default HelloID Workflow is used. If specified Workflow does not exist the Product creation will raise an error.
$FaIcon = '500px'
$removeProduct = $true                  # If False product will be disabled
$productVisibility = 'All'
$productReturnOnUserDisable    = $false # Indicates whether the product will be returned when the user owning the product gets disabled
$productRequestCommentOption     = "Optional" #one of "Optional", "Required", "Hidden". Indicates whether a comment is optional, required or not possible when requesting

#Target System Configuration
$uniqueProperty = 'id'              # The value will be used as the group identification part of the CombinedUniqueId
$SKUPrefix = 'DT'                   # The prefix will be used as system indentification part of the CombinedUniqueId
$TargetSystemName = 'DummyTarget'
$debugRemoveAllProducts = $false    # set to $true for an one-time easy way to remove all products (with the same prefix). default value $false

#region HelloID
function Get-HIDDefaultAgentPool {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003036494-GET-Get-agent-pools
    #>
    [CmdletBinding()]
    param ()

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'GET'
            Uri    = 'agentpools'
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Get-HIDSelfServiceProduct {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003027353-GET-Get-products
    #>
    [CmdletBinding()]
    param ()

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'GET'
            Uri    = 'selfservice/products'
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Get-HIDSelfServiceCategory {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003036194-GET-Get-self-service-categories
    #>
    [CmdletBinding()]
    param ()

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'GET'
            Uri    = 'selfservice/categories'
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Set-HIDSelfServiceProduct {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003038854-POST-Create-or-update-a-product
    #>
    [CmdletBinding()]
    param (
        $ProductJson
    )
    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Body   = $ProductJson
            Method = 'POST'
            uri    = 'selfservice/products'
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function New-HIDSelfServiceCategory {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003024773-POST-Create-self-service-category
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Name,

        [string]
        $SelfServiceCategoryGUID,

        [bool]
        $IsEnabled
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $category = [ordered]@{
            "name"                    = $Name
            "SelfServiceCategoryGUID" = $SelfServiceCategoryGUID
            "isEnabled"               = $IsEnabled
        } | ConvertTo-Json

        $splatParams = @{
            Method = 'POST'
            Uri    = 'selfservice/categories'
            Body   = $category
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Remove-HIDSelfServiceProduct {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003038654-DELETE-Delete-product
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ProductGUID
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'DELETE'
            Uri    = "selfservice/products/$ProductGUID"
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Add-HIDGroupMemberActions {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003025813-POST-Create-group-member-action
    #>
    [CmdletBinding()]
    param(
        $body
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"

        $splatParams = @{
            Method = 'POST'
            Uri    = 'automationtasks/powershell'
            Body   = $body
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}




function New-HIDGroup {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115003038654-DELETE-Delete-product
    #>
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $GroupName,

        [bool]
        $isEnabled
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $groupBody = @{
            name      = "$GroupName Resource Owners"
            isEnabled = $isEnabled
            userNames = ''
        } | ConvertTo-Json

        $splatParams = @{
            Method = 'POST'
            Uri    = 'groups'
            Body   = $groupBody
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $Pscmdlet.ThrowTerminatingError($_)
    }
}


function Get-HIDGroup {
    <#
    .DESCRIPTION
       https://docs.helloid.com/hc/en-us/articles/115002981813-GET-Get-specific-group
    #>
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $GroupName,

        [switch]
        $resourceGroup
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        if ($resourceGroup) {
            $groupname = "$GroupName Resource Owners"
        }
        $splatParams = @{
            Method = 'GET'
            Uri    = "groups/$groupname"
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        if ($_.ErrorDetails.Message -match 'Group not found') {
            return $null
        }
        $Pscmdlet.ThrowTerminatingError($_)
    }
}
function Add-HIDProductMember {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115002954633-POST-Link-member-to-group
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $selfServiceProductGUID,

        [Parameter(Mandatory)]
        [string]
        $MemberGUID
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'POST'
            Uri    = "selfserviceproducts/$selfServiceProductGUID/groups"
            Body   = @{
                groupGUID = $MemberGUID
            } | ConvertTo-Json
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $Pscmdlet.ThrowTerminatingError($_)
    }
}

function Add-HIDGroupMember {
    <#
    .DESCRIPTION
        https://docs.helloid.com/hc/en-us/articles/115002954633-POST-Link-member-to-group
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $GroupGUID,

        [Parameter(Mandatory)]
        [string]
        $MemberGUID
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatParams = @{
            Method = 'POST'
            Uri    = "groups/$GroupGUID"
            Body   = @{
                UserGUID = $MemberGUID
            } | ConvertTo-Json
        }
        Invoke-HIDRestMethod @splatParams
    } catch {
        $Pscmdlet.ThrowTerminatingError($_)
    }
}

function Add-HIDUserGroup {
    <#
    .DESCRIPTION
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $UserName,

        [Parameter()]
        [String]
        $GroupName
    )

    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        $splatRestParameters = @{
            Method = 'POST'
            Uri    = "users/$UserName/groups"
            Body   = @{
                name = $GroupName
            } | ConvertTo-Json
        }
        Invoke-HIDRestMethod @splatRestParameters
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}


function Invoke-HIDRestmethod {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Uri,

        [object]
        $Body,

        [string]
        $ContentType = 'application/json'
    )

    try {
        Write-Verbose 'Switching to TLS 1.2'
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

        Write-Verbose 'Setting authorization headers'
        $apiKeySecret = "$($portalApiKey):$($portalApiSecret)"
        $base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($apiKeySecret))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Basic $base64")
        $headers.Add("Content-Type", $ContentType)

        $splatParams = @{
            Uri     = "$BaseUrl/api/v1/$Uri"
            Headers = $headers
            Method  = $Method
        }

        if ($Body) {
            Write-Verbose 'Adding body to request'
            $splatParams['Body'] = $Body
        }

        Write-Verbose "Invoking '$Method' request to '$Uri'"
        Invoke-RestMethod @splatParams
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

function Write-HidStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [String]
        $Event
    )
    if ([String]::IsNullOrEmpty($portalBaseUrl)) {
        Write-Information $Message
    } else {
        Hid-Write-Status -Message $Message -Event $Event
    }
}

function Write-HidSummary {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [String]
        $Event
    )

    if ([String]::IsNullOrEmpty($portalBaseUrl) -eq $true) {
        Write-Output ($Message)
    } else {
        Hid-Write-Summary -Message $Message -Event $Event
    }
}

function Compare-Join {
    [OutputType([array], [array], [array])]
    param(
        [parameter()]
        [string[]]$ReferenceObject,

        [parameter()]
        [string[]]$DifferenceObject
    )
    if ($null -eq $DifferenceObject) {
        $Left = $ReferenceObject
    } elseif ($null -eq $ReferenceObject ) {
        $right = $DifferenceObject
    } else {
        $left = [string[]][Linq.Enumerable]::Except($ReferenceObject, $DifferenceObject )
        $right = [string[]][Linq.Enumerable]::Except($DifferenceObject, $ReferenceObject)
        $common = [string[]][Linq.Enumerable]::Intersect($ReferenceObject, $DifferenceObject)
    }
    Write-Output $Left , $Right, $common
}

#endregion HelloID

# HelloId_Actions_Variables
#region Action1
$sciptAddGroupMember = @'
#region functions
function Add-TargetGroupMember {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $GroupName
    )
    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        Hid-Write-Status -Message  "Todo: Write your own implementation to invoke the API of the actual Target system to add the groupmember" -Event Success
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

#endregion functions

try {
    Hid-Write-Status -Message  "Adding Group Member [$GroupMember] to Group [$groupname]" -Event Information
    Add-TargetGroupMember -GroupName $groupname

    Hid-Write-Status -Message  "Successfully added group Member [$GroupMember] to Group [$groupname]" -Event Success
    Hid-Write-Summary -Message "Successfully added Group Member [$GroupMember] to Group [$groupname]" -Event Success
} catch {
    Hid-Write-Status -Message  "Exception: $($_.Exception.Message)" -Event Error
    if ($_.ErrorDetails) {
        Hid-Write-Status -Message  $_.ErrorDetails -Event Error
    } elseif ($_.Exception.Response) {
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        Hid-Write-Status -Message $reader.ReadToEnd()  -Event Error
        $reader.Dispose()
    }
    Hid-Write-Status -Message  "Could not add Group Member [$GroupMember] to Group [$groupname]" -Event Error
    Hid-Write-Summary -Message "Could not add Group Member [$GroupMember] to Group [$groupname]" -Event Failed
}
'@

$Action1 = @{
    name                = 'Add-GroupMember'
    automationContainer = 2
    objectGUID          = $null
    metaData            = '{"executeOnState":3}'
    useTemplate         = $false
    powerShellScript    = $sciptAddGroupMember
    variables           = @(
        @{
            "name"           = "GroupName"
            "value"          = "{{product.name}}"
            "typeConstraint" = "string"
            "secure"         = $false
        }
    )
}

#endregion Action1

#region Action2
$scriptRemoveGroupMember = @'
#region functions
function Remove-TargetGroupMember {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $GroupName
    )
    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        Hid-Write-Status -Message  "Todo: Write your own implementation to invoke the API of the actual Target system to remove the groupmember" -Event Success
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

#endregion functions

try {
    Hid-Write-Status -Message  "Removing Group Member [$GroupMember] from Group [$groupname]" -Event Information
    Remove-TargetGroupMember -GroupName $groupname

    Hid-Write-Status -Message  "Successfully removed Group Member [$GroupMember] from Group [$groupname]" -Event Success
    Hid-Write-Summary -Message "Successfully removed Group Member [$GroupMember] from Group [$groupname]" -Event Success
} catch {
    Hid-Write-Status -Message  "Exception: $($_.Exception.Message)" -Event Error
    if ($_.ErrorDetails) {
        Hid-Write-Status -Message  $_.ErrorDetails -Event Error
    } elseif ($_.Exception.Response) {
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        Hid-Write-Status -Message $reader.ReadToEnd()  -Event Error
        $reader.Dispose()
    }
    Hid-Write-Status -Message  "Could not Remove Group Member [$GroupMember] from Group [$groupname]" -Event Error
    Hid-Write-Summary -Message "Could not Remove Group Member [$GroupMember] from Group [$groupname]" -Event Failed
}
'@
$Action2 = @{
    name                = 'Remove-GroupMember'
    automationContainer = 2
    objectGUID          = $null
    metaData            = '{"executeOnState":11}'
    useTemplate         = $false
    powerShellScript    = $scriptRemoveGroupMember
    variables           = @(
        @{
            "name"           = "GroupName"
            "value"          = "{{product.name}}"
            "typeConstraint" = "string"
            "secure"         = $false
        }
    )
}

#endregion Action2

#region TargetSystem

function Get-TargetGroupList {
    [CmdletBinding()]
    param()
    try {
        Write-Verbose "Invoking command '$($MyInvocation.MyCommand)'"
        # This function must provide a list of groups from the target system
        # In this template it wil return a fixed hardcoded list
        # Change this with a call to retrieve them from the actual system

        $Group1 = [PSCustomObject]@{
            id   = 1
            name = "Firstgroup"
        }
        $Group2 = [PSCustomObject]@{
            id   = 2
            name = "Secondgroup"
        }
        $Groups = [System.Collections.Generic.list[object]]::new()
        $Groups.Add($Group1)
        $Groups.Add($Group2)
        return ,$Groups
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

#endregion TargetSystem

#region script
try {
    #Target Groups!
    if ($debugRemoveAllProducts -eq $true) {
        $TargetGroups = $null
    }
    else {
        $TargetGroups = Get-TargetGroupList      # Gets the groups of the Target system
    }


    #Adds the created Actions above in a list of Action. So you can extend the product easily with extra actions.
    $Actions = [System.Collections.Generic.list[object]]@()
    $Actions.Add($Action1)
    $Actions.Add($Action2)


    # HelloID Process of Creating the Products based on the groups of a Target System  # Future Function !
    # params {
    #     [object[]]
    #     $TargetGroups,      # Provide a list of groups from the target system. That will be used to create the products in HelloID.

    #     [string]
    #     $uniqueProperty,    # Specify a Dynamic Property that represents the unique key of the target system. Cannot contains special characters

    #     [string]
    #     $SKUPrefix,         # Specify a prefix for the SKU, to determine the products related to the target system.

    #     [string]
    #     $TargetSystemName, # This will be used as prefix in the displayname

    #     [System.Collections.Generic.list[object]]
    #     $actions            # The HelloID actions which must be added to the HelloID product.
    # }

    Write-HidStatus -Message "Starting synchronization of $TargetSystemName groups to HelloID products" -Event Information
    if ($TargetGroups.count -gt 0) {
        if ($TargetGroups.$uniqueProperty -eq $null) {
            throw "The specified unique property [$uniqueProperty] for the target system does exist as property in the groups"
        }
    }

    if ($TargetGroups.Count -eq 0) {
        Write-HidStatus -Message 'No Target Groups have been found' -Event Information
    } else {
        Write-HidStatus -Message "Found '$($TargetGroups.Count)' Target group(s)" -Event Information
    }

    $TargetGroups = $TargetGroups | Select-Object *, @{name = 'CombinedUniqueId'; expression = { $SKUPrefix + $_.$uniqueProperty } }
    $TargetGroupsGrouped = $TargetGroups | Group-Object -Property CombinedUniqueId -AsHashTable -AsString

    Write-HidStatus -Message 'Getting default agent pool' -Event Information
    $defaultAgentPool = (Get-HIDDefaultAgentPool) | Where-Object { $_.options -eq '1' }

    Write-HidStatus -Message "Gathering the self service product category '$ProductCategory'" -Event Information
    $selfServiceCategory = (Get-HIDSelfServiceCategory) | Where-Object { $_.name -eq "$ProductCategory" }

    if ($selfServiceCategory.isEnabled -eq $false) {
        Write-HidStatus -Message "Found a disabled ProductCategory '$ProductCategory', will enable the current category" -Event Information
        $selfServiceCategory = New-HIDSelfServiceCategory -Name "$ProductCategory" -IsEnabled $true -SelfServiceCategoryGUID  $selfServiceCategory.selfServiceCategoryGUID
    } elseif ($null -eq $selfServiceCategory) {
        Write-HidStatus -Message "No ProductCategory Found will Create a new category '$ProductCategory'" -Event Information
        $selfServiceCategory = New-HIDSelfServiceCategory -Name "$ProductCategory" -IsEnabled $true
    }

    Write-HidStatus -Message 'Gathering Self service products from HelloID' -Event Information
    $selfServiceProduct = Get-HIDSelfServiceProduct
    $selfServiceProductGrouped = $selfServiceProduct | Group-Object -Property 'code' -AsHashTable -AsString
    if ($selfServiceProduct.Count -eq 0) {
        Write-HidStatus -Message 'No Self service products have been found' -Event Information
    } else {
        Write-HidStatus -Message "Found '$($selfServiceProduct.Count)' self service product(s)" -Event Information
    }

    # Making sure we only manage the products of Target System
    $currentProducts = $selfServiceProduct | Where-Object { $_.code.ToLower().startswith("$($SKUPrefix.tolower())") }

    Write-HidStatus -Message "Found '$($currentProducts.Count)' self service product(s) of Target System [$TargetSystemName]" -Event Information

    # Null Check Reference before compare
    $currentProductsChecked = if ($null -ne $currentProducts.code) { $currentProducts.code.tolower() } else { $null }
    $targetGroupsChecked = if ($null -ne $TargetGroups.CombinedUniqueId) { $TargetGroups.CombinedUniqueId.ToLower() } else { $null }

    $productToCreateInHelloID , $productToRemoveFromHelloID, $productExistsInHelloID = Compare-Join -ReferenceObject $targetGroupsChecked -DifferenceObject $currentProductsChecked
    Write-HidStatus "[$($productToCreateInHelloID.count)] Products will be Created " -Event Information
    Write-HidStatus "[$($productExistsInHelloID.count)] Products already exist in HelloId" -Event Information
    if ($removeProduct) {
        Write-HidStatus "[$($productToRemoveFromHelloID.count)] Products will be Removed " -Event Information
    } else {
        Write-HidStatus 'Verify if there are products found which are already disabled.' -Event Information
        $productToRemoveFromHelloID = [array]($currentProducts | Where-Object { ( $_.code.ToLower() -in $productToRemoveFromHelloID) -and $_.visibility -ne 'Disabled' }).code
        Write-HidStatus "[$($productToRemoveFromHelloID.count)] Products will be disabled " -Event Information
    }

    foreach ($productToCreate in $productToCreateInHelloID) {
        $product = $TargetGroupsGrouped[$productToCreate]
        Write-HidStatus "Creating Product [$($product.name)]" -Event Information
        $resourceOwnerGroupName = if ([string]::IsNullOrWhiteSpace($SAProductResourceOwner) ) { $product.name } else { $SAProductResourceOwner }

        $resourceOwnerGroup = Get-HIDGroup -GroupName $resourceOwnerGroupName  -ResourceGroup
        if ($null -eq $resourceOwnerGroup ) {
            Write-HidStatus "Creating a new resource owner group for Product [$($resourceOwnerGroupName ) Resource Owners]" -Event Information
            $resourceOwnerGroup = New-HIDGroup -GroupName $resourceOwnerGroupName -isEnabled $true
        }

        $productBody = @{
            Name                       = "$($product.name)"
            Description                = "$TargetSystemName-$($product.name)"
            ManagedByGroupGUID         = $($resourceOwnerGroup.groupGuid)
            Categories                 = @($selfServiceCategory.name)
            ApprovalWorkflowName       = $SAProductWorkflow
            AgentPoolGUID              = $defaultAgentPool.agentPoolGUID
            Icon                       = $null
            FaIcon                     = "fa-$FaIcon"
            UseFaIcon                  = $true
            IsAutoApprove              = $false
            IsAutoDeny                 = $false
            MultipleRequestOption      = 1
            IsCommentable              = $true
            HasTimeLimit               = $false
            LimitType                  = 'Fixed'
            ManagerCanOverrideDuration = $true
            ReminderTimeout            = 30
            OwnershipMaxDuration       = 90
            CreateDefaultEmailActions  = $true
            Visibility                 = $productVisibility
            Code                       = "$SKUPrefix$($product.id)"
            ReturnOnUserDisable        = $productReturnOnUserDisable
            RequestCommentOption       = $productRequestCommentOption
        } | ConvertTo-Json
        $selfServiceProduct = Set-HIDSelfServiceProduct -ProductJson $productBody

        $sAAccessGroup = Get-HIDGroup -GroupName $ProductAccessGroup
        if (-not $null -eq $sAAccessGroup) {
            Write-HidStatus -Message  "Adding ProductAccessGroup [$ProductAccessGroup] to Product " -Event Information
            $null = Add-HIDProductMember -selfServiceProductGUID $selfServiceProduct.selfServiceProductGUID -MemberGUID $sAAccessGroup.groupGuid
        } else {
            Write-HidStatus -Message  "The Specified ProductAccessGroup [$ProductAccessGroup] does not exist. We will continue without adding the access Group" -Event Warning
        }

        foreach ($action in $actions) {
            Write-HidStatus -Message  "Adding action [$($action.Name)] to Product " -Event Information
            $action.objectGUID = $selfServiceProduct.selfServiceProductGUID
            $null = Add-HIDGroupMemberActions -Body ($action | ConvertTo-Json)
        }
    }

    foreach ($productToRemove in $ProductToRemoveFromHelloID) {
        $product = $selfServiceProductGrouped[$productToRemove] | Select-Object -First 1
        if ($removeProduct) {
            Write-HidStatus "Removing Product [$($product.name)]" -Event Information
            $null = Remove-HIDSelfServiceProduct -ProductGUID  $product.selfServiceProductGUID
        } else {
            Write-HidStatus "Disabling Product [$($product.name)]" -Event Information
            $product.visibility = 'Disabled'
            $disableProductBody = ConvertTo-Json ($product | Select-Object -Property * -ExcludeProperty Code)
            $null = Set-HIDSelfServiceProduct -ProductJson $disableProductBody
        }
    }

    foreach ($productToUpdate in $productExistsInHelloID) {
        # Make sure existing products are enabled
        $product = $selfServiceProductGrouped[$productToUpdate] | Select-Object -First 1
        if ($product.visibility -eq 'Disabled') {
            Write-HidStatus "Enabling existing Product [$($product.name)]" -Event Information
            $product.visibility = $productVisibility
            $product.isEnabled = $true
            $eanbleProductBody = ConvertTo-Json ($product | Select-Object -Property * -ExcludeProperty Code)
            $null = Set-HIDSelfServiceProduct -ProductJson $eanbleProductBody
        }
    }

    Write-HidStatus -Message 'Successfully synchronized Target System groups to HelloID products' -Event Success
    Write-HidSummary -Message 'Successfully synchronized Target System groups to HelloID products' -Event Success
} catch {
    Write-HidStatus -Message "Error synchronization of $TargetSystemName groups to HelloID products" -Event Error
    Write-HidStatus -Message "Exception message: $($_.Exception.Message)" -Event Error
    Write-HidStatus -Message "Exception details: $($_.errordetails)" -Event Error
    Write-HidSummary -Message "Error synchronization of $TargetSystemName groups to HelloID products" -Event Failed
}
#endregion
