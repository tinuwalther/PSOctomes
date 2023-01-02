<#
Based on a function from https://gist.github.com/dhmacher/2203582502c7ab13015db8f52e94da45

You need an access token that has at least write access to your status

* go to settings -> Development
* Click "New Application"
* Enter a name
* Allow "write:statuses
* Click Submit
* Click on the new application to review the keys
* Copy and securely store the "Access token" for your script.

This code is freely available to use and or modify.
#>

#TODO: Post an image with a status including ALT text for the description

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUri,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Message,


    [Parameter(Mandatory=$true)]
    [Object] $PSOctomes
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

        Write-Verbose "Posting to $WebhookUrl"

        $payload = @{
            status = $Message
        }

        Write-Verbose "Payload:"
        Write-Verbose "$($payload | Out-String)"

        $Token = [System.Net.NetworkCredential]::new("", ($PSOctomes | Where-Object UserName -eq Mastodon).Password).Password #Read-Host -Prompt 'Enter the Token for Mastodon' -MaskInput
        $Properties = @{
            Uri         = "$($ApiUri)?access_token=$($Token)"
            Method      = 'POST'
            #Body        = $payload
            #ContentType = 'application/x-www-form-urlencoded'
            ContentType = 'application/json; charset=UTF-8'
            Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
            ErrorAction = 'Stop'
        }
        $ret = Invoke-RestMethod @Properties
        $ret | ConvertTo-Json

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
