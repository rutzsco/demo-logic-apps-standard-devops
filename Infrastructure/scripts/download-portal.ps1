$profiles = az webapp deployment list-publishing-profiles -g rg_logic_demo_dev -n rutzsco-demo-logic-app-dev | Convertfrom-json

# Create Base64 authorization header
$username = $profiles[0].userName
$password = $profiles[0].userPWD
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$baseTargetUri = "https://rutzsco-demo-logic-app-dev.scm.azurewebsites.net/api/vfs/site/wwwroot/"
$baseOutputPath = "C:\Projects\demo-logic-apps-standard-devops\Workflows\"
$jsonObj = Invoke-RestMethod -Uri $baseTargetUri  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET -ContentType "application/json"
$jsonObj | Select-Object -Property Name,Mime | ForEach-Object {
    if ($_.mime -eq 'application/json') {
        $t = $baseTargetUri+$_.name
        $o = $baseOutputPath+$_.name
        Invoke-WebRequest -Uri $t -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET -OutFile $o -ContentType "multipart/form-data"
    }

    if ($_.mime -eq 'inode/directory') {
        $t = $baseTargetUri+$_.name+'/workflow.json'
        $o = $baseOutputPath+$_.name+'/workflow.json'
        $d = $baseOutputPath+$_.name
        New-Item -ItemType Directory -Force -Path $d
        Invoke-WebRequest -Uri $t -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET -OutFile $o -ContentType "multipart/form-data"
    }
}