#Requires -Modules BluebirdPS
<#

https://docs.bluebirdps.dev/en/latest/about_BluebirdPS/

$BluebirdPSLastResponse
Get-BluebirdPSHistory -Last 5

Set-TwitterAuthentication
Show-TwitterAuthentication
Test-TwitterAuthentication
#>

<#
    https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/
    got to the developer portal
    create a new app
    save your keys
    https://github.com/thedavecarroll/BluebirdPS
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [Parameter(Mandatory=$false)]
    [String] $ApiUri,
    
    [Parameter(Mandatory=$true)]
    [String] $Message,

    [Parameter(Mandatory=$true)]
    [Object] $PSOctomes
)

begin {
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
    $ret = $null
}

process {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
    if ($PSCmdlet.ShouldProcess($PSBoundParameters.Values)){
        if ($message.Length -gt 140) {
            Write-Warning ("Length of tweet is {0} characters, maximum amount is 140. Aborting..." -f $Message.Length)
            break
        }

        try{

            if(Test-TwitterAuthentication){
                Write-Verbose "TwitterAuthentication: $true"
            }else{
                Write-Warning "Could not authenticate to Twitter, check the authentication values:"
                Write-Host $(Show-TwitterAuthentication -Confirm:$false | Out-String)
            }

            $Properties = @{
                TweetText = $Message
            }
            $ret = Publish-Tweet @Properties

            #Write-Host "$($function)"
            #$ret | Out-String

        }catch{
            Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
            $Error.Clear()
        }
    }
}

end {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    return $ret
}