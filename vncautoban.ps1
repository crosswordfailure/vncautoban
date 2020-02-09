function addtoautoban
{
param ($addthisone)
$remoteaddresses = @()
$remoteaddresses += (Get-NetFirewallRule -DisplayName 'vnc autoban' | Get-NetFirewallAddressFilter).RemoteAddress
if ($remoteaddresses -notcontains $addthisone)
    {
        $remoteaddresses += $addthisone
        Set-NetFirewallRule -DisplayName 'vnc autoban' -RemoteAddress $remoteaddresses
    }
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
    if ($freak.count -ge 3)
        {
        addtoautoban $freak.name
        }
    }
