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
                $Secret = Get-Secret -Vault $SecretVault -Name $item.Name -ErrorAction Stop
                [PSCustomObject]@{
                    Name   = $item.Name
                    User   = $Secret.UserName
                    ApiUri = $item.ApiUri
                    Token  = [System.Net.NetworkCredential]::new($Secret.UserName, $Secret.Password).Password
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
