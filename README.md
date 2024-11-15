Task Scheduler. Here's how to use it:

Save it as New-VCenterScheduledSnapshot.ps1
Make sure you have VMware PowerCLI installed
Run it with the required parameters:

powershellCopy.\New-VCenterScheduledSnapshot.ps1 `
    -vCenterServer "vcenter.yourdomain.com" `
    -VMName "YourVMName" `
    -SnapshotName "Snapshot1" `
    -CreateDate "2024-11-16T02:00:00" `
    -RemoveDate "2024-11-17T02:00:00" `
    -Username "administrator@vsphere.local" `
    -Password "YourPassword" `
    -Description "Your snapshot description"
Key features of this version:

Creates tasks directly in vCenter's task scheduler
Uses vSphere API to create proper scheduled tasks
Handles time zone conversion to UTC
Includes error handling and logging
Creates both create and remove snapshot tasks
Verifies VM existence before creating tasks
