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

#region Variables
$SectionTitle = 'Another neverending story'

if([String]::IsNullOrEmpty($Message)){
$SectionDescription = @"
Another neverending story https://it.martin-walther.ch/

Deployed a lot of ESXi Hosts with #VMware vSphere AutoDeploy in different network zones and vSphere SSO domains.
All settings (DHCP IP reservation, DNS records, BIOS settings, apply and remediate HostProfile, move to the spec. Cluster, assigning licence, etc) is done with #PowerShell and #PowerCLI.

I did build a Framework with #Gitlab and #pipeline with #pester to test and deploy the node-files as Yaml to the selected environment (Test, Int, Prod). 
The node.yml contains all the config to deploy an ESXi Host and will be used as inputfile for the workflow-script that orchestrate the deployment.

And now I found a few new ideas, to optimize this workflow.
"@
}else{
    $SectionDescription = $Message
}

$FactTitle = 'The Framework'

$FactMessage = @"
I did build a Framework with #Gitlab and #pipeline with #pester to test and deploy the node-files as Yaml to the selected environment (Test, Int, Prod). 
The node.yml contains all the config to deploy an ESXi Host and will be used as inputfile for the workflow-script that orchestrate the deployment.

I found a few new ideas, to optimize this workflow.
"@
#endregion

#region Discord
if($SendToDiscord){
    $Token = Read-Host -Prompt 'Enter the Token for Discord' -MaskInput
    $Properties = @{
        WebhookUrl         = "https://discord.com/api/webhooks/$($Token)"
        #SectionTitle       = $SectionTitle
        SectionDescription = $SectionDescription
        #FactTitle          = $FactTitle
        #FactMessage        = $FactMessage
    }
    .\Bin\New-DiscordMessage.ps1 @Properties -Verbose
}
#endregion

#region Telegram
if($SendToTelegram){
    $Token = Read-Host -Prompt 'Enter the Token for Telegram' -MaskInput
    $Properties = @{
        WebhookUrl = "https://api.telegram.org/bot$($Token)/sendMessage"
        Message    = $SectionDescription
        ChatId     = 2043926767
        Html       = $true
    }
    .\Bin\New-TelegramMessage.ps1 @Properties -Verbose
}
#endregion

#region Mastodon
if($SendToMastodon){
    $MastodonInstance = 'techhub.social'
    $Token = Read-Host -Prompt 'Enter the Token for Mastodon' -MaskInput
    $Properties = @{
        WebhookUrl = "https://$($MastodonInstance)/api/v1/statuses?access_token=$($Token)"
        Message    = $SectionDescription
    }
    .\Bin\New-MastodonMessage.ps1 @Properties -Verbose
}
#endregion

#region Twitter
if($SendToTwitter){
    $Properties = @{
        WebhookUrl = "https://twitter.com/statuses/update.xml"
        Message    = $SectionDescription
    }
    .\Bin\New-TwitterMessage.ps1 @Properties -Verbose
}
#endregion
