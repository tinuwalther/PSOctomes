# PSOctomes

PowerShell Module to send messages to multiple messenger.

![Image](img/PSOctomes.jfif)

## Supported Messenger

- Discord
- Telegram
- Twitter
- Mastodon

## How to configure Discord

Found on [my Blog](https://it.martin-walther.ch/discord/) (in german).

## How to configure Telegram

Found on [my Blog](https://it.martin-walther.ch/telegram/) (in german).

## How to configure Twitter

Found on the Blog of [Harm Veenstra](https://github.com/HarmVeenstra): [Create a Tweet on Twitter using PowerShell](https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/)

## How to configure Mastodon

You need an access token that has at least write access to your status

- Go to Preferences -> settings -> Development
- Click "New Application"
- Enter a name
- Allow "write:statuses
- Click Submit
- Click on the new application to review the keys
- Copy and securely store the "Access token" for your script.

## How to use

Clone the GitHub-Repository

````powershell
git clone https://github.com/tinuwalther/PSOctomes
cd ./PSOctomes
````

Install-Modules:

````powershell
Install-Module Microsoft.PowerShell.SecretManagement, BluebirdPS -Verbose
Import-Module ./PSOctomes/ -Force
````

Register SecretVault:

Create your credential as Secrets with the following entries:

- Discord_Token, URL, Token as Password
- Mastodon_Token, URL, Token as Password
- Telegram_Token, URL, Token as Password
- Telegram_ChatId, Id as Password

````powershell
New-PSSecretStore -Register -Discord -Telegram -Mastodon -Twitter
````

Test the access to the KeePass Vault:

````powershell
Get-SecretInfo -Vault PSOctomes | Select-Object Name, @{N='URL';E={$_.Metadata.values}}
````

and execute the command Send-PSOctoMessage

````powershell
$Message = @"
Hi #PowerShell folks
I send this message to multiple messenger with #PowerShell and #PSOctomes.
https://github.com/tinuwalther/PSOctomes
"@

Send-PSOctoMessage -Message $Message -SendToTelegram -SendToDiscord -SendToMastodon -SendToTwitter
````
