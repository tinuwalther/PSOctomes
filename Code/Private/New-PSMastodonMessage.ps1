function New-PSMastodonMessage {
    <#
    .SYNOPSIS
        New-PSMastodonMessage send a message to Mastodon
    .DESCRIPTION
        New-PSMastodonMessage send a message to Mastodon
    .NOTES
        Based on a function from https://gist.github.com/dhmacher/2203582502c7ab13015db8f52e94da45
        and https://gist.github.com/jdhitsolutions/7bb8fe659cd32a7bfb2debdb7f0bfcfc

        You need an access token that has at least write access to your status

        * Go to Preferences -> settings -> Development
        * Click "New Application"
        * Enter a name
        * Allow "write:statuses
        * Click Submit
        * Click on the new application to review the keys
        * Copy and securely store the "Access token" for your script.

    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .PARAMETER ApiUri
        ApiUri
    .PARAMETER Message
        Message
    .PARAMETER PSOctomes
        KeePass SecretObject
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiUri,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

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

                Write-Verbose "Posting to $WebhookUrl"

                $payload = @{
                    status = $Message
                }

                Write-Verbose "Payload:"
                Write-Verbose "$($payload | Out-String)"

                $Token = $PSOctomes | Where-Object User -eq Mastodon_Token | Select-Object -ExpandProperty Token
                $ApiUri = $PSOctomes | Where-Object User -eq Mastodon_Token | Select-Object -ExpandProperty ApiUri
                $Properties = @{
                    Uri         = "$($ApiUri)?access_token=$($Token)"
                    Method      = 'POST'
                    ContentType = 'application/json; charset=UTF-8'
                    Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
                    ErrorAction = 'Stop'
                }
                $ret = Invoke-RestMethod @Properties

            }
            catch {
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $ret = [PSCustomObject]@{ 'ok' = $false; 'result' = $($_.Exception.Message) }
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
