[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Message,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $WebhookUrl
)

begin {
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
    $ret = $null
}

process {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')

    try{

        $Tweetcred = Get-Credential

        $body = @{
            status = $Message
        }

        $Properties = @{
            Uri         = $WebhookUrl
            Method      = "POST"
            ContentType = "application/x-www-form-urlencoded"
            Body        = $body
            ErrorAction = "Stop"
        }

        Write-Verbose "Using these parameters:"
        $Properties | Out-String | Write-Verbose

        $Response = Invoke-RestMethod @Properties -Credential $Tweetcred
        $ret = $Response.result

    }catch{
        Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
        $Error.Clear()
    }
}

end {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    return $ret
}
