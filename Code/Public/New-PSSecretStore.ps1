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
