#Requires -Version 7

[Uri[]] $service_uris = @(
# REST
   'https://URI:PORT/ServiceName/some_path/about?dbcheck', # ServiceName
# WCF
   'https://URI:PORT/ServiceName/Filename.svc', # ServiceName
)

Function shakeDownTest() {
    param (
        # -NonInteractive mode for immediate error
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "URI to send GET request to run shakeDownTest")]
        [Uri] $uri
    )
    # Easy behavior reproduction
    Write-Host "`$resp = Invoke-WebRequest -UseBasicParsing -Method GET -Uri '$uri'"

    # Powershell is very type-safe and nice to debug:
    # using 'catch {}' does not catch the type exceptions and silently fails instead
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Method GET -Uri $uri
    } catch [System.Net.WebException] {
        If ($_.Exception.Response.StatusCode.value__) {
            $exc_statuscode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
            Write-Output "exc_statuscode: $exc_statuscode";
        }
        If  ($_.Exception.Message) {
            $excMsg = ($_.Exception.Message).ToString().Trim();
            Write-Output "excMsg: $excMsg";
        }
        If  ($_.Exception.Response) {
            $excResp = ($_.Exception.Response).ToString().Trim();
            Write-Output "excResp: $excResp";
        }
        if ($_.Exception)
            return 1 # exception, but this may be never reached
    }

    if ($resp -eq $Null) { return 2; } # empty response witout headers etc
    if ($resp.Headers -eq $Null) { return 3; } # no header
    if (200 -ne $resp.StatusCode) { return 4; } # http status not ok

    switch($resp.Headers.'Content-Type') {
        "application/json; charset=UTF-8" {
            $json = $resp.Content | ConvertFrom-Json
            if ($json.description -eq $Null) { return 5; } # no description
            # liveness check like db connection? latency?
            # product version? git version?
            if ($json.header -eq $Null) { return 6; } # no header
            # <header_checks>..
        }
        "text/html; charset=UTF-8" {
            # Parsing HTML is often overkill and would require 'AngleSharp' as dependency
            if ($True -ne $resp.Content.Contains("Service available.")) {
                return 6 # service error
            }
        }
        Default {
            return 5; # unexpected field value in html header field 'Content-Type'
        }
    }

    return 0; # OK
}

ForEach ($uri in $service_uris) {
    $res = shakeDownTest $uri
    if ($res -ne 0) {
        Write-Output "$uri $res Fail"
        return $res
    } else {
        Write-Output "OK"
    }
}
return 0
