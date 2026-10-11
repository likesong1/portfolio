<#
New public portfolio example. Does not change network configuration.
Checks one target; TCP check runs only when TcpPort is specified.
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$TargetHost = '127.0.0.1',
    [ValidateRange(1, 65535)]
    [int]$TcpPort,
    [ValidateRange(100, 10000)]
    [int]$TimeoutMs = 2000
)

$result = [ordered]@{
    TimestampUtc = [DateTime]::UtcNow.ToString('o')
    Target = $TargetHost
    ResolvedAddresses = @()
    ResolutionError = $null
    Icmp = [ordered]@{ Status = 'NotChecked'; RoundtripMs = $null; Error = $null }
    Tcp = [ordered]@{ Port = $null; Status = 'NotRequested'; Error = $null }
    Interpretation = 'Address resolution is not a DNS health check. ICMP and TCP results do not prove application health.'
}
try {
    $result.ResolvedAddresses = @([System.Net.Dns]::GetHostAddresses($TargetHost) | ForEach-Object { $_.ToString() })
} catch {
    $result.ResolutionError = $_.Exception.Message
}

$pingCheck = [System.Net.NetworkInformation.Ping]::new()
try {
    $reply = $pingCheck.Send($TargetHost, $TimeoutMs)
    $result.Icmp.Status = $reply.Status.ToString()
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        $result.Icmp.RoundtripMs = $reply.RoundtripTime
    }
} catch {
    $result.Icmp.Status = 'Error'
    $result.Icmp.Error = $_.Exception.Message
} finally {
    $pingCheck.Dispose()
}

if ($PSBoundParameters.ContainsKey('TcpPort')) {
    $result.Tcp.Port = $TcpPort
    $tcpCheck = [System.Net.Sockets.TcpClient]::new()
    $pendingConnect = $null
    try {
        $pendingConnect = $tcpCheck.BeginConnect($TargetHost, $TcpPort, $null, $null)
        if ($pendingConnect.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            $tcpCheck.EndConnect($pendingConnect)
            $result.Tcp.Status = 'Connected'
        } else {
            $result.Tcp.Status = 'TimedOut'
        }
    } catch {
        $result.Tcp.Status = 'Error'
        $result.Tcp.Error = $_.Exception.Message
    } finally {
        if ($null -ne $pendingConnect) { $pendingConnect.AsyncWaitHandle.Close() }
        $tcpCheck.Dispose()
    }
}
$result | ConvertTo-Json -Depth 4
