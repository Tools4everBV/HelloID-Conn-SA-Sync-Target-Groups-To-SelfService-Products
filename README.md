HelloID-Conn-SA-Sync-Target-Groups-To-SelfService-Products

<!-- TABLE OF CONTENTS -->
## Table of Contents
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Getting started](#Getting-started)
  - [Prerequisites](#Prerequisites)
  - [Connection settings](#Connection-settings)
  - [Remarks](#Remarks)
- [Getting help](#getting-help)
- [HelloID Docs](#helloid-docs)


## Introduction

By using this connector, you will have the ability to create HelloId SelfService Products based on groups of (any) Target System. The sync is intended to be a template that syncs groups to HelloID Products for any Target system.  The Target system code was added as an example.

It will manage only the products of the target system. The existing or manually created products are unmanaged and are excluded from the sync.

| :information_source: Information |
|:---------------------------|
| To make use of this sync. **You must create your own code** to retrieve the actual groups of target system and adjust the HelloId actions so they fit your target system.  The default implementation in this template will generate a static list of groups, and will log a placeholder message for the Add and Remove member actions
|


## Getting started

### Prerequisites
- [ ] Make sure you have Windows PowerShell 5.1 installed on the server where the HelloID agent and Service Automation agent are running.
  > The connector is compatible with older versions of Windows PowerShell. Although we cannot guarantuee the compatibility.

- [ ] Define the Global Variables for your Target System

- [ ] Making sure the product is configured to your requirements.



### Connection settings

The connection settings are defined in the automation variables [user defined variables](https://docs.helloid.com/hc/en-us/articles/360014169933-How-to-Create-and-Manage-User-Defined-Variables). And the Product configuration can be configured in the script


| Variable name                 | Description                                                  | Notes                                               |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| $BaseUrl                      | HelloID Base Url                        | (Default Global Variable)    |
| $portalApiKey                 | HelloID Api Key                         | (Default Global Variable)    |
| $portalApiSecret              | HelloID Api Secret                      | (Default Global Variable)    |
| $ProductAccessGroup           | HelloID Product Access Group            | *If not found, the product is created without an Access Group* |
| $ProductCategory              | HelloID Product Category                | *If the category is not found, it will be created* |
| $SAProductResourceOwner       | HelloID Product Resource Owner Group    | *If left empty the groupname will be: "Resource owners [target-systeem] - [Product_Naam]")* |
| $SAProductWorkflow            | HelloID Product Approval workflow       | *If empty. The Default HelloID Workflow is used. If specified Workflow does not exist the Product creation will raise an error.* |
| $productVisibility            | HelloID Product Visibility              | "ALL" |
| $FaIcon                       | HelloID Product fa-icon name            | |
| $removeProduct                | HelloID Remove Product instead of Disable| |
| $uniqueProperty               | Target Groups Unique Key                | The vaule will be used as CombinedUniqueId|
| $SKUPrefix                    | HelloID SKU prefix                      | The prefix will be used as CombinedUniqueId |
| $TargetSystemName             | HelloID Prefix of product description              | |
| $Action1                      | HelloID Product action1  *(Add-GroupMember)*        | |
| $Action2                      | HelloID Product action2  *(Remove-GroupMember)*   | |
| $TargetGroups                 | Target System List of Groups *(Get-DemoTargetLGroupList)*          | |




## Remarks
- The Products are only created and disabled/deleted. No Update takes place.
> When a Product already exists, the product will be skipped (no update will take place).

- When the RemoveProduct switch is adjusted to remove the products, the products will be deleted from HelloID instead of Disabled. This will remove also the previous disabled products (by the sync).

- This template uses a dummy target system. When retreiving the target system groups, it will always return a fixed list of groups, and when adding/removing memberships it will log a success message without modifying anything. You must modify the powershell code of these functions to perfom the operations on your actual target system.

## Getting help
> _For more information on how to configure a HelloID PowerShell scheduled task, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/115003253294-Create-Custom-Scheduled-Tasks) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
