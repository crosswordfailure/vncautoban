function firstfirewallrule
{
    New-NetFirewallRule -DisplayName 'vnc autoban' -Profile Any -Direction Inbound -Action Block -Enabled False
    Get-NetFirewallRule -DisplayName 'vnc autoban' | Get-NetFirewallPortFilter | Set-NetFirewallPortFilter -Protocol TCP -LocalPort 5900
}

function rollfirewallrule
{
    Get-NetFirewallRule -DisplayName 'vnc autoban' | Set-NetFirewallRule -NewDisplayName ('vnc autoban ' + (get-date -Format 'MM-dd-yyyy--HH-mm'))
    New-NetFirewallRule -DisplayName 'vnc autoban' -Profile Any -Direction Inbound -Action Block -Enabled False
    Get-NetFirewallRule -DisplayName 'vnc autoban' | Get-NetFirewallPortFilter | Set-NetFirewallPortFilter -Protocol TCP -LocalPort 5900
}

function addtoautoban
{
param ($addthisone)
$rulesize = ((Get-NetFirewallRule -DisplayName 'vnc autoban' | Get-NetFirewallAddressFilter).RemoteAddress).count
if ($rulesize -ge 512)
 {
     rollfirewallrule
 }
$remoteaddresses = @()
$remoteaddresses += (Get-NetFirewallRule -DisplayName 'vnc autoban' | Get-NetFirewallAddressFilter).RemoteAddress
if ($remoteaddresses -notcontains $addthisone)
    {
        $remoteaddresses += $addthisone
        Set-NetFirewallRule -DisplayName 'vnc autoban' -RemoteAddress $remoteaddresses
    }
if ((Get-NetFirewallRule -DisplayName 'vnc autoban').enabled -eq 'False')
    {
        Set-NetFirewallRule -DisplayName 'vnc autoban' -Enabled True
    }
}

$rule = Get-NetFirewallRule -DisplayName 'vnc autoban'
if ($rule -eq $null)
    {
    firstfirewallrule
    }

$time = (Get-Date).AddMinutes(-10)
$filterhashtable = @{
    LogName = 'Application'
    ProviderName = 'tvnserver'
    StartTime = $time
}

$events = Get-WinEvent -FilterHashtable $filterhashtable
$ips = @()
$regex = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
foreach ($event in $events)
    {
        if ($event.message -like 'Authentication failed*')
            {
            $event.message -match $regex
            $ips += $matches.0
            }
    }

$frequency = $ips | group

foreach ($freak in $frequency)
    {
    if ($freak.count -ge 2)
        {
        addtoautoban $freak.name
        }
    }
