function New-PSTelegramMessage {
    <#
    .SYNOPSIS
        New-PSTelegramMessage send a message to Telegram
    .DESCRIPTION
        New-PSTelegramMessage send a message to your Telegram bot
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .PARAMETER ApiUri
        ApiUri
    .PARAMETER Html
        Html
    .PARAMETER Message
        Message
    .PARAMETER ChatID
        ChatID
    .PARAMETER PSOctomes
        KeePass SecretObject
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $false)]
        [String] $ApiUri,

        [Parameter(Mandatory = $false)]
        [Switch]$Html,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String] $Message,

        [Parameter(Mandatory = $false)]
        [Int] $ChatID,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())) {
                try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                if ($Html) {
                    $ParseMode = 'html'
                }
                else {
                    $ParseMode = 'MarkdownV2'
                }

                $ChatID = $PSOctomes | Where-Object User -eq Telegram_ChatId | Select-Object -ExpandProperty Token
                $payload = @{
                    "chat_id"                  = $ChatID
                    "text"                     = $Message
                    "parse_mode"               = $ParseMode
                    "disable_web_page_preview" = $false
                    "disable_notification"     = $false
                }
                Write-Verbose "Payload:"
                Write-Verbose "$($payload | Out-String)"
        
                $Token = $PSOctomes | Where-Object User -eq Telegram_Token | Select-Object -ExpandProperty Token
                $ApiUri = $PSOctomes | Where-Object User -eq Telegram_Token | Select-Object -ExpandProperty ApiUri
                $Properties = @{
                    Uri         = "$($ApiUri)$($Token)/sendMessage" #"https://api.telegram.org/bot$($Token)/sendMessage"
                    Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
                    Method      = 'POST'
                    ContentType = 'application/json; charset=UTF-8'
                    ErrorAction = 'Stop'
                }

                $ret = Invoke-RestMethod @Properties

            }
            catch {
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $ret = $($_.Exception.Message)
                $Error.Clear()
            }
        }
    }

    end {
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        return $ret
    }
}
