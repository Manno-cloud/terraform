# Entra ID接続
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"

# CSV出力先
$CsvPath = "C:\Temp\E3_NoSharePoint.csv"

New-Item -ItemType Directory -Path "C:\Temp" -Force |
    Out-Null

# Microsoft 365 E3 のSKU
$E3Sku = Get-MgSubscribedSku |
    Where-Object { $_.SkuPartNumber -eq "SPE_E3" }

if (-not $E3Sku) {
    throw "Microsoft 365 E3が見つかりません"
}

# E3が付与されているユーザーを取得
$Users = Get-MgUser -All `
    -Property "Id,DisplayName,UserPrincipalName,AssignedLicenses" |
    Where-Object {
        $_.AssignedLicenses.SkuId -contains $E3Sku.SkuId
    }

# SharePoint Plan 2 が無効なユーザーを抽出
$Result = foreach ($User in $Users) {

    $Licenses = Get-MgUserLicenseDetail -UserId $User.Id

    $E3License = $Licenses |
        Where-Object { $_.SkuId -eq $E3Sku.SkuId }

    $SPPlan = $E3License.ServicePlans |
        Where-Object {
            $_.ServicePlanName -eq "SHAREPOINTENTERPRISE"
        }

    if (-not $SPPlan -or
        $SPPlan.ProvisioningStatus -eq "Disabled") {

        [PSCustomObject]@{
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            SharePointStatus  = if ($SPPlan) {
                $SPPlan.ProvisioningStatus
            } else {
                "NotAssigned"
            }
        }
    }
}

# CSV出力
$Result | Export-Csv `
    -Path $CsvPath `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host "抽出件数: $(@($Result).Count)"
Write-Host "出力先: $CsvPath"
