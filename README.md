# PSOctomes

PowerShell Script to send messages to multiple messenger.

## Supported Messenger

How to configure the messenger:

- [Discord](https://it.martin-walther.ch/discord/)
- [Telegram](https://it.martin-walther.ch/telegram/)
- [Mastodon](https://gist.github.com/jdhitsolutions/7bb8fe659cd32a7bfb2debdb7f0bfcfc)

## How to use

Clone the GitHub-Repository

````powershell
git clone https://github.com/tinuwalther/PSOctomes
cd ./PSOctomes
````

for Telegram, add your ChatId in the region Telegram,
for Mastodon add your Mastodon Instance in the region Mastodon,
and execute the script Send-OctoMessage.ps1

````powershell
$Message = @"
Hi

I send this message to multiple messenger with #PowerShell.

https://github.com/tinuwalther/PSOctomes/blob/main/README.md
"@
.\Bin\Send-OctoMessage.ps1 -Message $Message -SendToDiscord -SendToTelegram -SendToMastodon
````