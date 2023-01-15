[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [Switch] $SendToDiscord,

    [Parameter(Mandatory=$false)]
    [Switch]$SendToTelegram,

    [Parameter(Mandatory=$false)]
    [Switch] $SendToMastodon,

    [Parameter(Mandatory=$false)]
    [Switch] $SendToTwitter,

    [Parameter(Mandatory=$false)]
    [String] $Message
)

#region functions
function Get-MWASecretsFromVault{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$Vault
    )

    if(-not(Test-SecretVault -Name $Vault)){
        Unlock-SecretVault -Name $Vault
    }
    
    $SecretInfo = Get-SecretInfo -Vault $Vault -WarningAction SilentlyContinue
    $ret = $SecretInfo | ForEach-Object {
        $Tags = foreach($item in $_.Metadata.keys){
            if($item -match 'Tags'){
                $($_.Metadata[$item])
            }
        }
        $Accessed = foreach($item in $_.Metadata.keys){
            if($item -match 'Accessed'){
                $($_.Metadata[$item])
            }
        }
        $ApiUri = foreach($item in $_.Metadata.keys){
            if($item -match 'URL'){
                $($_.Metadata[$item])
            }
        }
        [PSCustomObject]@{
            Name     = $_.Name
            ApiUri   = $ApiUri
            Tag      = $Tags
            Accessed = $Accessed
        }
    }
    return $ret
}
#endregion

#region Secret
$SecretVault  = 'PSOctomes'
$AllSecrets   = Get-MWASecretsFromVault -Vault $SecretVault
$SecretObject = foreach($item in $AllSecrets){
    try{
        $Secret = Get-Secret -Vault $SecretVault -Name $item.Name -ErrorAction Stop
        [PSCustomObject]@{
            Name   = $item.Name
            User   = $Secret.UserName
            ApiUri = $item.ApiUri
            Token = [System.Net.NetworkCredential]::new($Secret.UserName, $Secret.Password).Password
        }
    }catch{
        $Error.Clear()
    }
}

<# 
$cred = 'Discord','Telegram','Mastodon', 'TwitterApiKey', 'TwitterAccessToken' | ForEach-Object {
    Get-Credential -Message "Enter the Token for $_" -UserName $_
}
$cred | Export-Clixml
try{
    $Clixml = Import-Clixml
    if([string]::IsNullOrEmpty($Clixml)){
        Write-Warning "Credential-file not found!"
        break
    }
}catch{
    Write-Warning $($_.Exception.Message)
    break
}
#>
#endregion

#region Variables
if([String]::IsNullOrEmpty($Message)){
$Message = @"
Hi

Finally, I send this message to multiple messenger with #PowerShell and #PSOctomes.

https://github.com/tinuwalther/PSOctomes
"@
}
#endregion
    
#region Discord
if($SendToDiscord){
    $Properties = @{
        #ApiUri             = "https://discord.com/api/webhooks"
        SectionDescription = $Message
        AuthorName         = 'tinu'
        AuthorAvatar       = 'https://it.martin-walther.ch/wp-content/uploads/Bearded.jpg'
        PSOctomes          = $SecretObject
    }
    .\Bin\New-DiscordMessage.ps1 @Properties #-Verbose
}
#endregion

#region Telegram
if($SendToTelegram){
    $Properties = @{
        #ApiUri    = "https://api.telegram.org/bot"
        Message   = $Message
        #ChatId    = 2043926767
        Html      = $true
        PSOctomes = $SecretObject
    }
    .\Bin\New-TelegramMessage.ps1 @Properties #-Verbose
}
#endregion

#region Mastodon
if($SendToMastodon){
    #$MastodonInstance = 'techhub.social'
    $Properties = @{
        #ApiUri    = "https://$($MastodonInstance)/api/v1/statuses"
        Message   = $Message
        PSOctomes = $SecretObject
    }
    .\Bin\New-MastodonMessage.ps1 @Properties #-Verbose
}
#endregion

#region Twitter
if($SendToTwitter){
    $Properties = @{
        #ApiUri    = "https://api.twitter.com/2/tweets"
        Message   = $Message
        PSOctomes = $SecretObject
    }
    .\Bin\New-TwitterMessage.ps1 @Properties #-Verbose
}
#endregion

