<#
Install Modules:
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore, SecretManagement.KeePass -Verbose

Register SecretVault:
Register-SecretVault -Name "PSOctomes" -ModuleName "SecretManagement.Keepass" -VaultParameters @{
	Path = "$($env:OneDrive)\Do*ument*\PSOctomes.kdbx"
	UseMasterPassword = $true
}

or

Register-KeePassSecretVault -Path $HOME/git/PSOctomes/config/PSOctomes.kdbx -Name PSOctomes -UseMasterPassword -Create -ShowFullTitle -ShowRecycleBin

Get-SecretVault -Name PSOctomes
Unlock-SecretVault -Name PSOctomes
Get-SecretInfo -Vault PSOctomes -Name Telegram_Token | Select-Object -ExpandProperty Metadata

Set-Secret -Name 'Telegram_Token' -Vault PSOctomes (Get-Credential -UserName 'Telegram_Token' -Message "Please enter the password for Telegram_Token")
Set-Secret -Name 'Telegram_ChatId' -Vault PSOctomes (Get-Credential -UserName 'Telegram_ChatId' -Message "Please enter the password for Telegram_ChatId")

#>

#region functions
function Get-MWASecretsFromVault{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true)]
        [String]$Vault
    )

    if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)){
        if(-not(Test-SecretVault -Name $Vault)){
            Unlock-SecretVault -Name $Vault
        }
        
        $SecretInfo = Get-SecretInfo -Vault $Vault -WarningAction SilentlyContinue
        $ret = $SecretInfo | ForEach-Object {
            $ApiUri = foreach($item in $_.Metadata.keys){
                if($item -match 'URL'){
                    $($_.Metadata[$item])
                }
            }
            $Accessed = foreach($item in $_.Metadata.keys){
                if($item -match 'Accessed'){
                    $($_.Metadata[$item])
                }
            }
            [PSCustomObject]@{
                Name     = $_.Name
                ApiUri   = $ApiUri
                Accessed = $Accessed
            }
        }
        return $ret
    }
}
#endregion
