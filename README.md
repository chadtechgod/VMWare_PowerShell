# vCenter Scheduled Snapshot Management Script

## Overview
This PowerShell script creates scheduled tasks in vCenter to manage VM snapshots, including both creation and removal tasks. The tasks are created directly in vCenter's task scheduler using the vSphere API.

## Prerequisites
* VMware PowerCLI installed
* vCenter access with appropriate permissions
* PowerShell 5.1 or higher

## Script Parameters
| Parameter | Required | Description |
|-----------|----------|-------------|
| vCenterServer | Yes | vCenter server hostname or IP address |
| VMName | Yes | Name of the virtual machine |
| SnapshotName | Yes | Name for the snapshot |
| CreateDate | Yes | Date/time to create snapshot (format: yyyy-MM-ddTHH:mm:ss) |
| RemoveDate | Yes | Date/time to remove snapshot (format: yyyy-MM-ddTHH:mm:ss) |
| Username | Yes | vCenter username |
| Password | Yes | vCenter password |
| Description | No | Description for the snapshot (default: "Scheduled Snapshot") |

## Usage

1. Save the script as `New-VCenterScheduledSnapshot.ps1`
2. Open PowerShell
3. Run the script with required parameters:

```powershell
.\New-VCenterScheduledSnapshot.ps1 `
    -vCenterServer "vcenter.yourdomain.com" `
    -VMName "YourVMName" `
    -SnapshotName "Snapshot1" `
    -CreateDate "2024-11-16T02:00:00" `
    -RemoveDate "2024-11-17T02:00:00" `
    -Username "administrator@vsphere.local" `
    -Password "YourPassword" `
    -Description "Your snapshot description"
```

## Key Features
* Direct integration with vCenter's task scheduler
* Uses vSphere API for task creation
* Automatic UTC time conversion
* Comprehensive error handling and logging
* Creates paired create/remove snapshot tasks
* VM existence verification
* SSL certificate handling
* Clean disconnection from vCenter

## Script Functions

### Connect-ToVCenter
Establishes connection to vCenter server with SSL certificate handling.

### New-VCenterScheduledTask
Creates a scheduled task in vCenter with the following capabilities:
* Custom task naming
* Flexible scheduling
* Action script definition
* Target VM specification

## Error Handling
The script includes error handling for:
* vCenter connection failures
* VM not found scenarios
* Task creation failures
* Invalid parameter values

## Examples

### Basic Usage
```powershell
# Create a snapshot tomorrow at 2 AM and remove it the next day
.\New-VCenterScheduledSnapshot.ps1 `
    -vCenterServer "vcenter.company.com" `
    -VMName "WebServer01" `
    -SnapshotName "Daily-Backup" `
    -CreateDate "2024-11-16T02:00:00" `
    -RemoveDate "2024-11-17T02:00:00" `
    -Username "admin@vsphere.local" `
    -Password "SecurePassword123" `
    -Description "Daily backup snapshot"
```

## Task Verification
After running the script, verify the tasks in vCenter:
1. Log into vCenter web client
2. Navigate to Menu → Administration → Scheduled Tasks
3. Look for tasks named:
   * Create_Snapshot_[SnapshotName]
   * Remove_Snapshot_[SnapshotName]

## Notes
* All times should be specified in local time; the script handles UTC conversion
* Tasks are created as enabled by default
* The script automatically handles vCenter disconnection
* Invalid certificate errors are suppressed for convenience
