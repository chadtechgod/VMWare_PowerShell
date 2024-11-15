# Parameters for the script
param(
    [Parameter(Mandatory=$true)]
    [string]$vCenterServer,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$true)]
    [string]$SnapshotName,
    
    [Parameter(Mandatory=$true)]
    [datetime]$CreateDate,
    
    [Parameter(Mandatory=$true)]
    [datetime]$RemoveDate,
    
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$true)]
    [string]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Scheduled Snapshot"
)

# Import required modules
Import-Module VMware.PowerCLI

# Function to connect to vCenter
function Connect-ToVCenter {
    try {
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
        Connect-VIServer -Server $vCenterServer -User $Username -Password $Password
    } catch {
        Write-Error "Failed to connect to vCenter: $_"
        exit 1
    }
}

# Function to create scheduled task in vCenter
function New-VCenterScheduledTask {
    param(
        [string]$TaskName,
        [string]$TaskType,
        [datetime]$ScheduleDate,
        [string]$ActionScript
    )

    try {
        # Get the vCenter Scheduler Service
        $SchedulerService = Get-View -Id 'ScheduledTaskManager-ScheduledTaskManager'

        # Get the VM object
        $VM = Get-VM -Name $VMName
        if (-not $VM) {
            throw "VM '$VMName' not found"
        }

        # Create the task specification
        $Spec = New-Object VMware.Vim.ScheduledTaskSpec
        $Spec.Name = $TaskName
        $Spec.Description = $Description
        $Spec.Enabled = $true
        $Spec.Notification = $Username

        # Create the schedule
        $Spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
        $Spec.Scheduler.RunAt = $ScheduleDate.ToUniversalTime()

        # Create the task action
        $Spec.Action = New-Object VMware.Vim.MethodAction
        $Spec.Action.Name = $ActionScript

        # Set the target
        $Spec.Target = $VM.ExtensionData.MoRef

        # Create the scheduled task
        $SchedulerService.CreateObjectScheduledTask($VM.ExtensionData.MoRef, $Spec)
        
        Write-Host "Successfully created scheduled task: $TaskName for $ScheduleDate"
    }
    catch {
        Write-Error "Failed to create scheduled task: $_"
    }
}

# Connect to vCenter
Connect-ToVCenter

try {
    # Create snapshot creation task
    $CreateTaskName = "Create_Snapshot_$SnapshotName"
    $CreateActionScript = @"
    $VM = Get-VM '$VMName'
    New-Snapshot -VM $VM -Name '$SnapshotName' -Description '$Description' -Memory:$false
"@
    New-VCenterScheduledTask -TaskName $CreateTaskName -TaskType "CreateSnapshot" -ScheduleDate $CreateDate -ActionScript $CreateActionScript

    # Create snapshot removal task
    $RemoveTaskName = "Remove_Snapshot_$SnapshotName"
    $RemoveActionScript = @"
    $VM = Get-VM '$VMName'
    $Snapshot = Get-Snapshot -VM $VM -Name '$SnapshotName'
    if ($Snapshot) {
        Remove-Snapshot -Snapshot $Snapshot -Confirm:$false
    }
"@
    New-VCenterScheduledTask -TaskName $RemoveTaskName -TaskType "RemoveSnapshot" -ScheduleDate $RemoveDate -ActionScript $RemoveActionScript

} catch {
    Write-Error "Error creating scheduled tasks: $_"
} finally {
    # Disconnect from vCenter
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false
}

Write-Host "Script execution completed. Please verify the tasks in vCenter."
