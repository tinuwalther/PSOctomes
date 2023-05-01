<#
    Generated at 05/01/2023 12:54:09 by Martin Walther
#>
#region namespace PSOctomes
function Get-PSSecretsFromVault {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Vault
    )

    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
    if ($PSCmdlet.ShouldProcess($params.Trim())) {
        if (-not(Test-SecretVault -Name $Vault)) {
            Unlock-SecretVault -Name $Vault
        }

        $SecretInfo = Get-SecretInfo -Vault $Vault -WarningAction SilentlyContinue
        $ret = $SecretInfo | ForEach-Object {
            $ApiUri = foreach ($item in $_.Metadata.keys) {
                if ($item -match 'URL') {
                    $($_.Metadata[$item])
                }
            }
            [PSCustomObject]@{
                Name     = $_.Name
                ApiUri   = $ApiUri
            }
        }
        return $ret
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
                $ret = [PSCustomObject]@{ 'ok' = $true; 'result' = "Successfully send to discord $ret" }

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
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())) {
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
    }

    process{

        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())) {
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

function New-PSSecretStore{
    <#
    .SYNOPSIS
        Add secrets for PSOctomes
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Reset-SecretStore
        WARNING: !!This operation completely removes all SecretStore module secrets and resets configuration settings to new values!!

        Set-SecretStorePassword
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $false)]
        [Switch] $Register,

        [Parameter(Mandatory = $false)]
        [Switch] $Discord,

        [Parameter(Mandatory = $false)]
        [Switch]$Telegram,

        [Parameter(Mandatory = $false)]
        [Switch] $Mastodon,

        [Parameter(Mandatory = $false)]
        [Switch] $Twitter,

        [Parameter(Mandatory = $false)]
        [switch]$Remove
    )

    $VaultName = "PSOctomes"
    if($Register){
        if((Get-SecretVault).Name -match $VaultName){
            Write-Host "$VaultName already exists" -ForegroundColor Cyan
        }else{
            Register-SecretVault -Name $VaultName -ModuleName 'Microsoft.PowerShell.SecretStore' -AllowClobber -VaultParameters @{
                UseMasterPassword = $true
                DefaultVault      = $true
            }
            Write-Host "Configure Secret Store $VaultName" -ForegroundColor Cyan
            #Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction Prompt
            Set-SecretStorePassword
        }
        Write-Host "Get Secret Store $VaultName" -ForegroundColor Cyan
        Get-SecretStoreConfiguration
    }

    # if (-not(Test-SecretVault -Name $VaultName)) {
    #     Write-Host "Unlock Secret Store $VaultName" -ForegroundColor Green
    #     Unlock-SecretVault -Name $VaultName
    # }

    Write-Host "Get Secret Vault $VaultName" -ForegroundColor Cyan
    Write-Host (Get-SecretVault | Out-String)

    #region Discord
    if($Discord){
        $name = 'Discord_Token'
        Write-Host "Add Secret for $name" -ForegroundColor Cyan
        $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
        Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://discord.com/api/webhooks' } 
    }
    #endregion

    #region Mastodon
    if($Mastodon){
        $name = 'Mastodon_Token'
        Write-Host "Add Secret for $name" -ForegroundColor Cyan
        $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
        Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://techhub.social/api/v1/statuses' } 
    }
    #endregion

    #region Telegram
    if($Telegram){
        $name = 'Telegram_Token'
        Write-Host "Add Secret for $name" -ForegroundColor Cyan
        $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
        Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://api.telegram.org/bot' } 
    
        $name = 'Telegram_ChatId'
        Write-Host "Add Secret for $name" -ForegroundColor Cyan
        $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
        Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://api.telegram.org/bot' } 
    }
    #endregion

    Get-SecretInfo

    #region Twitter
    if($Twitter){
        if (Test-TwitterAuthentication) {
            Write-Host "TwitterAuthentication: $true" -ForegroundColor Cyan
        }
        else {
            Write-Host "Could not authenticate to Twitter, pleases set the authentication values"
            Set-TwitterAuthentication
        }
    }
    #endregion

    if($Remove){
        Unregister-SecretVault -Name 'PSOctomes'
    }
}
function Send-PSOctoMessage {
    <#
    .SYNOPSIS
        Send messages to multiple messengers
    .DESCRIPTION
        Send messages to multiple messengers. Supported Messenger are Discord, Telegram, Mastodon, Twitter.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        https://github.com/tinuwalther/PSOctomes#readme
    .PARAMETER SendToDiscord
        Switch to send message to Discord
    .PARAMETER SendToTelegram
         Switch to send message to Telegram
    .PARAMETER SendToMastodon
         Switch to send message to Mastodon
    .PARAMETER SendToTwitter
         Switch to send message to Twitter
    .PARAMETER Message
        Send a message between 5 and 140 characters
    .EXAMPLE
        Send-PSOctoMessage -Message 'This is a Test-Message' -SendToDiscord
    .EXAMPLE
        Send-PSOctoMessage -Message 'This is a Test-Message' -SendToTelegram
    .EXAMPLE
        Send-PSOctoMessage -Message 'This is a Test-Message' -SendToMastodon
    .EXAMPLE
        Send-PSOctoMessage -Message 'This is a Test-Message' -SendToTwitter
    .EXAMPLE
        Send-PSOctoMessage -Message 'This is a Test-Message' -SendToDiscord -SendToTelegram -SendToMastodon -SendToTwitter
    #>
    
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $false)]
        [Switch] $SendToDiscord,

        [Parameter(Mandatory = $false)]
        [Switch]$SendToTelegram,

        [Parameter(Mandatory = $false)]
        [Switch] $SendToMastodon,

        [Parameter(Mandatory = $false)]
        [Switch] $SendToTwitter,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(5,140)]
        [String] $Message
    )

    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
    if ($PSCmdlet.ShouldProcess($params.Trim())) {

        #region Secret
        $SecretVault = 'PSOctomes'
        $AllSecrets = Get-PSSecretsFromVault -Vault $SecretVault
        $SecretObject = foreach ($item in $AllSecrets) {
            try {
                [PSCustomObject]@{
                    Name   = $item.Name
                    User   = $item.Name
                    ApiUri = $item.ApiUri
                    Token  = Get-Secret  -Vault $SecretVault -Name $item.Name -ErrorAction Stop -AsPlainText
                }
            }
            catch {
                $Error.Clear()
            }
        }
        #endregion

        #region Variables
        if ([String]::IsNullOrEmpty($Message)) {
            $Message = Get-Content -Path (Join-Path -Path $($PSScriptRoot).Replace('bin', 'data') -ChildPath 'input.txt')
        }

        if ($Message.Length -gt 140) {
            $FColor = 'Yellow'
        }
        else {
            $FColor = 'Green'
        }
        Write-Host ("Length of tweet is {0} characters." -f $Message.Length) -ForegroundColor $FColor
        #endregion
    
        #region Discord
        if ($SendToDiscord) {
            $Properties = @{
                #ApiUri             = "https://discord.com/api/webhooks"
                SectionDescription = $Message
                AuthorName         = 'tinu'
                AuthorAvatar       = 'https://it.martin-walther.ch/wp-content/uploads/Bearded.jpg'
                PSOctomes          = $SecretObject
            }
            New-PSDiscordMessage @Properties #-Verbose
        }
        #endregion

        #region Telegram
        if ($SendToTelegram) {
            $Properties = @{
                #ApiUri    = "https://api.telegram.org/bot"
                Message   = $Message
                Html      = $true
                PSOctomes = $SecretObject
            }
            New-PSTelegramMessage @Properties #-Verbose
        }
        #endregion

        #region Mastodon
        if ($SendToMastodon) {
            #$MastodonInstance = 'techhub.social'
            $Properties = @{
                #ApiUri    = "https://$($MastodonInstance)/api/v1/statuses"
                Message   = $Message
                PSOctomes = $SecretObject
            }
            New-PSMastodonMessage @Properties #-Verbose
        }
        #endregion

        #region Twitter
        if ($SendToTwitter) {
            if ($Message.Length -gt 140) {
                Write-Warning ("Length of tweet is {0} characters, maximum amount on twitter is 140. Aborting..." -f $Message.Length)
            }
            else {
                $Properties = @{
                    #ApiUri    = "https://api.twitter.com/2/tweets"
                    Message   = $Message
                    PSOctomes = $SecretObject
                }
                New-PSTwitterMessage @Properties #-Verbose
            }
        }
        #endregion

    }

}
#endregion
