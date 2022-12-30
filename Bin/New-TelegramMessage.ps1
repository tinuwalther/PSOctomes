[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String] $WebhookUrl,

    [Parameter(Mandatory=$false)]
    [Switch]$Html,

    [Parameter(Mandatory=$true)]
    [String] $Message,

    [Parameter(Mandatory=$true)]
    [Int] $ChatID
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

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if($Html){
            $ParseMode = 'html'
        }else{
            $ParseMode = 'MarkdownV2'
        }

        $payload = @{
            "chat_id"                   = $ChatID
            "text"                      = $Message
            "parse_mode"                = $ParseMode
            "disable_web_page_preview"  = $false
            "disable_notification"      = $false
        }
        Write-Verbose "Payload:"
        Write-Verbose "$($payload | Out-String)"
    
        $Properties = @{
            Uri         = $WebhookUrl
            Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
            Method      = 'Post'
            ContentType = 'application/json; charset=UTF-8'
            ErrorAction = 'Stop'
        }
        #$Response = Invoke-RestMethod -Uri "$($WebhookUrl)?chat_id=$($ChatID)&text=$($Message)&parse_mode=$($ParseMode)"
        $Response = Invoke-RestMethod @Properties
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
