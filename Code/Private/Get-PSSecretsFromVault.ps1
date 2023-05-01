function Get-PSSecretsFromVault {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
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
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Vault
    )

    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
    if ($PSCmdlet.ShouldProcess($params.Trim())) {
        if (-not(Test-SecretVault -Name $Vault)) {
            Unlock-SecretVault -Name $Vault
        }

        $SecretInfo = Get-SecretInfo -Vault $Vault -WarningAction SilentlyContinue
        $ret = $SecretInfo | ForEach-Object {
            $ApiUri = foreach ($item in $_.Metadata.keys) {
                if ($item -match 'URL') {
                    $($_.Metadata[$item])
                }
            }
            [PSCustomObject]@{
                Name     = $_.Name
                ApiUri   = $ApiUri
            }
        }
        return $ret
    }
}
