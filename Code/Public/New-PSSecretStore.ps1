function New-PSSecretStore{
    <#
    .SYNOPSIS
        Add secrets for PSOctomes
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
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Remove = $false
    )

    $VaultName = "PSOctomes"
    Register-SecretVault -Name $VaultName -ModuleName 'Microsoft.PowerShell.SecretStore' -VaultParameters @{
        UseMasterPassword = $true
        DefaultVault = $true
    }

    Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction Prompt
    Get-SecretStoreConfiguration
    if (-not(Test-SecretVault -Name $VaultName)) {
        Unlock-SecretVault -Name $VaultName
    }
    Get-SecretVault

    #region Discord
    $name = 'Discord_Token'
    Write-Host "Add Secret for $name" -ForegroundColor Green
    $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
    Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://discord.com/api/webhooks' } 
    Get-SecretInfo -Name $name
    #endregion

    #region Mastodon
    $name = 'Mastodon_Token'
    Write-Host "Add Secret for $name" -ForegroundColor Green
    $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
    Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://techhub.social/api/v1/statuses' } 
    Get-SecretInfo -Name $name
    #endregion

    #region Telegram
    $name = 'Telegram_Token'
    Write-Host "Add Secret for $name" -ForegroundColor Green
    $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
    Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://api.telegram.org/bot' } 

    $name = 'Telegram_ChatId'
    Write-Host "Add Secret for $name" -ForegroundColor Green
    $cred = Get-Credential -Message "Enter the Token for $name" -UserName $name
    Set-Secret -Name $cred.UserName -SecureStringSecret $cred.Password -Metadata @{ URL = 'https://api.telegram.org/bot' } 
    Get-SecretInfo -Name Telegram*
    #endregion

    if($Remove){
        Unregister-SecretVault -Name 'PSOctomes'
    }
}
