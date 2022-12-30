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
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Message,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $WebhookUrl,

    [Parameter(HelpMessage = "Enter a date and time to schedule the post. It must be at least 5 minutes in the future.")]
    [ValidateScript({
        ($_ - (Get-Date)).totalMinutes -ge 5
    })]
    [DateTime]$Scheduled
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

        $body = @{
            status = $Message
        }

        Write-Verbose "Posting $($body.status)"
        if ($Scheduled) {
            $isoDate = ("{0:u}" -f $scheduled.ToUniversalTime()).replace(" ", "T")
            $body.add("scheduled_at", $isoDate)
            Write-Verbose "Sending at $($body.scheduled_at)"
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
        if ($pscmdlet.ShouldProcess($Message, "Posting to $WebhookUrl")) {
            $Response = Invoke-RestMethod @Properties
            $ret = $Response.result
        }

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
