<#
    Generated at 04/30/2023 19:26:53 by Martin Walther
#>
#region namespace PSOctomes
function Write-PSLog{
    
    <#

        .SYNOPSIS
        Logging

        .DESCRIPTION
        Log in to file

        .PARAMETER LogFile
        Full path- and filname to log.

        .PARAMETER Status
        ERROR, WARNING, or INFO

        .PARAMETER Message
        A string message to log.

        .PARAMETER MaxLogFileSizeMB
        Max file-size of the logfile, if the file is greather than max-size it will be renamed.

        .EXAMPLE
        Write-Log -Status WARNING -Source "Module-Test" -Message "Test Write-Log"

        .NOTES
        2021-08-10, Martin Walther, 1.0.0, Initial version

    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$false)]
        [string] $LogFile,

        [ValidateSet("ERROR","WARNING","INFO")]
        [Parameter(Mandatory=$true)]
        [string] $Status,

        [Parameter(Mandatory=$false)]
        [String] $Source='n/a',

        [Parameter(Mandatory=$false)]
        [String] $System,

        [Parameter(Mandatory=$true)]
        $Message,

        [Parameter(Mandatory=$false)]
        [int] $MaxLogFileSizeMB = 10
    )

    begin{
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose "Running $function"
        $ret = $null
    }

    process{

        if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)){
            try{
                if([String]::IsNullOrEmpty($LogFile)){
                    $LogFile = $PSCommandPath -replace '.psm1', '.log'
                }
                Write-Verbose "Logfile: $LogFile"
        
                #region Test is logfile greater than MaxLogFileSizeMB
                if (Test-Path $LogFile){
                    $LogFileProperty = Get-Item $LogFile
                    $LogFileSizeMB   = $LogFileProperty.Length / 1mb
                    if($LogFileSizeMB -gt $MaxLogFileSizeMB){
                        Rename-Item -Path $LogFile -NewName "$($LogFileProperty.Name)_$(Get-Date -f 'yyyyMMddHHmmss').log"
                    }
                }  
                #endregion

                #region write loginformation
                if (-not(Test-Path $LogFile)){$null = New-Item $Logfile -type file}
                switch($Status){
                    'ERROR'   {$LogStatus = '[ERROR  ]'}
                    'WARNING' {$LogStatus = '[WARNING]'}
                    'INFO'    {$LogStatus = '[INFO   ]'}
                }
                $DateNow   = Get-Date -Format "dd.MM.yyyy HH:mm:ss.fff"
                #endregion

                #region Check User
                if($PSVersionTable.PSVersion.Major -lt 6){
                    $CurrentUser = $env:USERNAME
                }
                else{
                    if($IsMacOS)  {
                        $CurrentUser = id -un
                    }
                    if($IsLinux)  {
                        $CurrentUser = id -un
                    }
                    if($IsWindows){
                        $CurrentUser = $env:USERNAME
                    }
                }
                #endregion

                if (
                    ($Message -is [System.Object[]]) -or
                    ($Message -is [System.Management.Automation.PSCustomObject]) -or
                    ($Message -is [System.Collections.Specialized.OrderedDictionary])
                )
                {
                    for ($o = 0; $o -lt $Message.count; $o++){
                        Add-Content $LogFile -value "$($DateNow)`t$($LogStatus)`t[$($CurrentUser)]`t[$($Source)]`t$($Message[$o])"
                    }
                }else{
                    Add-Content $LogFile -value "$($DateNow)`t$($LogStatus)`t[$($CurrentUser)]`t[$($Source)]`t$($Message)"
                }

                $ret = $true
            }
            catch [Exception]{
                Write-Verbose "-> Catch block reached"
                $ret = $false
                $OutString = [PSCustomObject]@{
                    Succeeded  = $false
                    Function   = $function
                    Scriptname = $($_.InvocationInfo.ScriptName)
                    LineNumber = $($_.InvocationInfo.ScriptLineNumber)
                    Activity   = $($_.CategoryInfo).Activity
                    Message    = $($_.Exception.Message)
                    Category   = $($_.CategoryInfo).Category
                    Exception  = $($_.Exception.GetType().FullName)
                    TargetName = $($_.CategoryInfo).TargetName
                }
                $error.clear()
                $OutString | Format-List | Out-String | ForEach-Object {Write-Host $_ -ForegroundColor Red}
            }
        }
    }

    end{
        #return $ret
    }

}

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
        if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)) {
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
        if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)) {
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
        if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)) {
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
function New-PSTwitterMessage {
    <#
    .SYNOPSIS
        New-PSTwitterMessage send a message to Twitter
    .DESCRIPTION
        New-PSTwitterMessage send a message to Twitter with the Module BluwbirdPS
    .NOTES
        https://docs.bluebirdps.dev/en/latest/about_BluebirdPS/

        $BluebirdPSLastResponse
        Get-BluebirdPSHistory -Last 5

        Set-TwitterAuthentication
        Show-TwitterAuthentication
        Test-TwitterAuthentication

        https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/
        got to the developer portal
        create a new app
        save your keys
        https://github.com/thedavecarroll/BluebirdPS

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
        [String] $ApiUri,
    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Message,

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
        if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)) {
            if ($message.Length -gt 140) {
                Write-Warning ("Length of tweet is {0} characters, maximum amount is 140. Aborting..." -f $Message.Length)
                break
            }

            try {

                if (Test-TwitterAuthentication) {
                    Write-Verbose "TwitterAuthentication: $true"
                }
                else {
                    Write-Warning "Could not authenticate to Twitter, check the authentication values:"
                    Write-Host $(Show-TwitterAuthentication -Confirm:$false | Out-String)
                }

                $Properties = @{
                    TweetText = $Message
                }
                $ret = Publish-Tweet @Properties

            }
            catch {
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
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
#endregion
