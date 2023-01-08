# PSOctomes

PowerShell Script to send messages to multiple messenger.

## Supported Messenger

How to configure the messenger:

- [Discord](https://it.martin-walther.ch/discord/)
- [Telegram](https://it.martin-walther.ch/telegram/)
- [Twitter](https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/)
- [Mastodon](https://gist.github.com/jdhitsolutions/7bb8fe659cd32a7bfb2debdb7f0bfcfc)

## How to use

Clone the GitHub-Repository

````powershell
git clone https://github.com/tinuwalther/PSOctomes
cd ./PSOctomes
````

Create your credential-file as KeePass-Database with the following entries:

- DiscordPSBot, URL, Token as Password
- MastodonBot, URL, Token as Password
- TelegramToken, URL, Token as Password
- TelegramChatId, Id as Password
- TwitterAccessToken, URL, Token as Password
- TwitterApiKey, AccessKey as Password

Install-Modules:

````powershell
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore, SecretManagement.KeePass -Verbose
````

Register SecretVault:

````powershell
Register-SecretVault -Name "PSOctomes" -ModuleName "SecretManagement.Keepass" -VaultParameters @{
    Path = "$($env:USERPROFILE)\Do*ument*\PSOctomes.kdbx"
    UseMasterPassword = $true
}
````

Test the access to the KeePass Vault:

````powershell
Get-SecretInfo -Vault PSOctomes -Name DiscordPSBot | Select-Object -ExpandProperty Metadata
````

and execute the script Send-OctoMessage.ps1

````powershell
$Message = @"
Hi

I send this message to multiple messenger with #PowerShell.

https://github.com/tinuwalther/PSOctomes
"@

.\Bin\Send-OctoMessage.ps1 -Message $Message -SendToTelegram -SendToDiscord -SendToMastodon -SendToTwitter
````
