<#
    https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/
    got to the developer portal
    create a new app
    save your keys
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
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
    if ($message.Length -gt 140) {
        Write-Warning ("Length of tweet is {0} characters, maximum amount is 140. Aborting..." -f $Message.Length)
        break
    }

    try{

        #region Authentication
        $oauth_consumer_key     = [System.Net.NetworkCredential]::new("", ($PSOctomes | Where-Object UserName -eq TwitterApiKey).Password).Password      #API Key
        $oauth_token            = [System.Net.NetworkCredential]::new("", ($PSOctomes | Where-Object UserName -eq TwitterAccessToken).Password).Password #Access Token
        $oauth_signature_method = 'HMAC-SHA1'
        $oauth_timestamp        = '1672668693'
        $oauth_nonce            = 'hzECGas6TWf'
        $oauth_version          = '1.0'
        $oauth_signature        = 'byeaFhAem8kcL8ZESb68oIyHNVI%3D'
        #endregion

        #region Authorization
        $oauth_authorization    = 'OAuth '
        $oauth_authorization    += "oauth_consumer_key = $oauth_consumer_key, "
        $oauth_authorization    += "oauth_token = $oauth_token, "
        $oauth_authorization    += "oauth_signature_method = $oauth_signature_method, "
        $oauth_authorization    += "oauth_timestamp = $oauth_timestamp, "
        $oauth_authorization    += "oauth_nonce = $oauth_nonce, "
        $oauth_authorization    += "oauth_version = $oauth_version, "
        $oauth_authorization    += "oauth_signature = $oauth_signature"
        #endregion

        $headers = @{
            Authorization = $oauth_authorization
        }

        $payload = @{
            text = $Message
        }

        $Properties = @{
            Uri         = $ApiUri
            Headers     = $headers
            Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
            Method      = 'POST'
            ContentType = 'application/json; charset=UTF-8'
            ErrorAction = 'Stop'
        }
        $ret = Invoke-RestMethod @Properties
        $ret | ConvertTo-Json

    }catch{
        Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
        $Error.Clear()
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

<#
$culture = New-Object  -TypeName System.Globalization.CultureInfo -ArgumentList ('en-US')
$oauth_nonce = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))  
$ts = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact('01/01/1970', 'dd/MM/yyyy', $culture).ToUniversalTime()  
$oauth_timestamp = [System.Convert]::ToInt64($ts.TotalSeconds).ToString()  

$signature = 'POST&'  
$signature += [System.Uri]::EscapeDataString('https://api.twitter.com/1.1/statuses/update.json') + '&'  
$signature += [System.Uri]::EscapeDataString('oauth_consumer_key=' + $oauth_consumer_key + '&')  
$signature += [System.Uri]::EscapeDataString('oauth_nonce=' + $oauth_nonce + '&')   
$signature += [System.Uri]::EscapeDataString('oauth_signature_method=HMAC-SHA1&')  
$signature += [System.Uri]::EscapeDataString('oauth_timestamp=' + $oauth_timestamp + '&')  
$signature += [System.Uri]::EscapeDataString('oauth_token=' + $oauth_token + '&')  
$signature += [System.Uri]::EscapeDataString('oauth_version=1.0a&')  
$signature += [System.Uri]::EscapeDataString('status=' + $status)  

$signature_key = [System.Uri]::EscapeDataString($oauth_consumer_secret) + '&' + [System.Uri]::EscapeDataString($oauth_token_secret)  

$hmacsha1 = New-Object  -TypeName System.Security.Cryptography.HMACSHA1  
$hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($signature_key)  
$oauth_signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($signature)))  

$oauth_authorization = 'OAuth '  
$oauth_authorization += 'oauth_consumer_key="' + [System.Uri]::EscapeDataString($oauth_consumer_key) + '",'  
$oauth_authorization += 'oauth_nonce="' + [System.Uri]::EscapeDataString($oauth_nonce) + '",'  
$oauth_authorization += 'oauth_signature="' + [System.Uri]::EscapeDataString($oauth_signature) + '",'  
$oauth_authorization += 'oauth_signature_method="HMAC-SHA1",'  
$oauth_authorization += 'oauth_timestamp="' + [System.Uri]::EscapeDataString($oauth_timestamp) + '",'  
$oauth_authorization += 'oauth_token="' + [System.Uri]::EscapeDataString($oauth_token) + '",'  
$oauth_authorization += 'oauth_version="1.0a"'  
#>