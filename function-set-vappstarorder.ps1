# Original: http://virtualization.co.in/Scripts/Books/VMware_vSphere_PowerCLI_Reference___Automating_vSphere_Administration.pdf
# Sharing because it's useful. It's taken from the book. 

function Set-vAppStartOrder {
  [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'ByVM')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ValueFromPipeline = $True,ParameterSetName = 'ByVM')]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]
    $VM,
    [Parameter(ValueFromPipeline = $True,ParameterSetName = 'ByvApp')]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VAppImpl]
    $vApp,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [int]
    $StartOrder,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [int]
    $StartDelay,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [switch]
    $WaitingForGuest,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [ValidateSet("none","powerOn")]
    [string]
    $StartAction,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [int]
    $StopDelay,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByVM')]
    [ValidateSet('none','powerOff','guestShutdown','suspend')]
    [string]
    $StopAction,
    [Parameter(ValueFromPipelineByPropertyName = $true,ParameterSetName = 'ByvApp')]
    [bool]
    $DestroyWithParent)

  process {
    try {
      $vApp = Get-VIObjectByVIView $vm.ExtensionData.ParentVApp
    } catch {
      Write-Warning "$($VM.name) doesn't belong to a vApp."
      continue;
    }
    $EntityConfig = $vApp.ExtensionData.VAppConfig.EntityConfig
    $spec = New-Object VMware.Vim.VAppConfigSpec
    $spec.EntityConfig =
    foreach ($Conf in ($EntityConfig.GetEnumerator())) {
      if ($Conf.Key.ToString() -eq $VM.ID.ToString()) {
        $msg = "Setting $($VM.Name) start order to:"
        switch ($PSCmdlet.MyInvocation.BoundParameters.Keys) {
          'StartOrder'
          {
            $msg = "{0} StartOrder:{1}" -f $msg,$StartOrder
            $Conf.StartOrder = $StartOrder
          }
          'StartDelay'
          {
            $msg = "{0} StartDelay:{1}" -f $msg,
            $StartDelay
            $Conf.StartDelay = $StartDelay
          }
          'WaitingForGuest'
          {
            $msg = "{0} WaitingForGuest:{1}" -f $msg,
            $WaitingForGuest
            $Conf.WaitingForGuest = $WaitingForGuest
          }
          'StartAction'
          {
            $msg = "{0} StartAction:{1}" -f $msg,
            $StartAction
            $Conf.StartAction = $StartAction
          }
          'StopDelay'
          {
            $msg = "{0} StopDelay:{1}" -f $msg,
            $StopDelay
            $Conf.StopDelay = $StopDelay
          }
          'StopAction'
          {
            $msg = "{0} StopAction:{1}" -f $msg,
            $StopAction
            $Conf.StopAction = $StopAction
          }
          'DestroyWithParent'
          {
            $msg = "{0} DestroyWithParent:{1}" -f $msg,
            $DestroyWithParent
            $Conf.DestroyWithParent = $DestroyWithParent
          }
        }
      }
      $conf
    }
    if ($pscmdlet.shouldprocess($vApp.Name,$msg))
    {
      $vApp.ExtensionData.UpdateVAppConfig($spec)
    }
  }
}
$vcenterserver = "Fill In" 
$vappname = (Get-VApp -Name * | get-vm)

Add-PSSnapin -Name VMware* -ErrorAction SilentlyContinue
Connect-VIServer -Server $vcenterserver -WarningAction SilentlyContinue
foreach ($vms in $vappname) {
    Set-vAppStartOrder -VM $vms -StopAction guestShutdown -WaitingForGuest
}


