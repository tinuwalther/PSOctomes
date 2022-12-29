#region Variables
$SectionTitle = 'Another neverending story'

$SectionDescription = @"
Deployed a lot of ESXi Hosts with #VMware vSphere AutoDeploy in 2 different network zones and vSphere domains.
All settings (DHCP IP reservation, DNS records, BIOS settings, apply and remediate HostProfile, move to the spec. Cluster, assigning licence, etc) is done with #PowerShell and #PowerCLI.
"@

$FactTitle = 'The Framework'

$FactMessage = @"
I did build a Framework with #Gitlab and #pipeline with #pester to test and deploy the node-files as Yaml to the selected environment (Test, Int, Prod). 
The node.yml contains all the config to deploy an ESXi Host and will be used as inputfile for the workflow-script that orchestrate the deployment.

I found a few new ideas, to optimize this workflow.
"@
#endregion

#region Discord
$Properties = @{
    WebhookUrl         = Read-Host -Prompt 'Enter the WebhookcUrl' -MaskInput
    SectionTitle       = $SectionTitle
    SectionDescription = $SectionDescription
    FactTitle          = $FactTitle
    FactMessage        = $FactMessage
}
.\Bin\New-DiscordMessage.ps1 @Properties -Verbose
#endregion