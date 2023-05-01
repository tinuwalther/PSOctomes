function New-PSDiscordMessage {
    <#
    .SYNOPSIS
        New-PSDiscordMessage send a message to Discord
    .DESCRIPTION
        New-PSDiscordMessage send a message to Discord
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .PARAMETER ApiUri
        https://discord.com/api/webhooks/<Token>
    .PARAMETER SectionTitle
        Title
    .PARAMETER SectionDescription
        Description
    .PARAMETER SectionColor
        Color
    .PARAMETER FactTitle
        Title
    .PARAMETER FactMessage
        Message
    .PARAMETER AuthorName
        Author name
    .PARAMETER AuthorAvatar
        Author avatar link
    .PARAMETER PSOctomes
        KeePass SecretObject
    .EXAMPLE
        $Properties = @{
            SectionDescription = 'This is a test message'
            AuthorName         = 'tinu'
            AuthorAvatar       = 'https://it.martin-walther.ch/wp-content/uploads/Bearded.jpg'
            PSOctomes          = $SecretObject
        }
        New-PSDiscordMessage @Properties
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(Mandatory = $false)]
        [String] $ApiUri,

        [Parameter(Mandatory = $false)]
        [String] $SectionTitle,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $SectionDescription,

        [Parameter(Mandatory = $false)]
        [Int] $SectionColor = 5789910, #5858D6

        [Parameter(Mandatory = $false)]
        [String] $FactTitle,

        [Parameter(Mandatory = $false)]
        [String] $FactMessage,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String] $AuthorName = 'The PowerSHell Hook',

        [Parameter(Mandatory = $false)]
        [String] $AuthorAvatar = 'http://img1.wikia.nocookie.net/__cb20111027212138/pichipichipitchadventures/es/images/thumb/f/fd/Captain-Hook-Wallpaper-disney-villains-976702_1024_768.png/456px-Captain-Hook-Wallpaper-disney-villains-976702_1024_768.png',

        [ValidateNotNullOrEmpty()]
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

                #region Facts
                if ([String]::IsNullOrEmpty($FactTitle)) {
                    # New section with no embed object
                    $EmbededSection = @{
                        'title'       = $SectionTitle
                        'description' = "@here: " + $SectionDescription
                        'color'       = $SectionColor
                    }
                }
                else {
                    $EmbededFacts = @{
                        'name'   = $FactTitle
                        'value'  = $FactMessage
                        'inline' = $false
                    }
                    Write-Verbose "EmbededFacts:"
                    Write-Verbose "$($EmbededFacts | Out-String)"

                    # New section as embed object
                    $EmbededSection = @{
                        'title'       = $SectionTitle
                        'description' = "@here: " + $SectionDescription
                        'color'       = $SectionColor
                        "fields"      = @($EmbededFacts)
                    }
                }
                Write-Verbose "EmbededSection:"
                Write-Verbose "$($EmbededSection | Out-String)"
                #endregion

                # Full message
                $payload = @{
                    'username'   = $AuthorName
                    'avatar_url' = $AuthorAvatar
                    "embeds"     = @($EmbededSection)
                }
                Write-Verbose "FullMessage:"
                Write-Verbose "$($payload | Out-String)"

                if([String]::IsNullOrEmpty($ApiUri)){
                    $Token  = $PSOctomes | Where-Object User -eq Discord_Token | Select-Object -ExpandProperty Token
                    $ApiUri = $PSOctomes | Where-Object User -eq Discord_Token | Select-Object -ExpandProperty ApiUri
                }
                $Properties = @{
                    Uri         = "$($ApiUri)/$($Token)" #"https://discord.com/api/webhooks/$($Token)"
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
