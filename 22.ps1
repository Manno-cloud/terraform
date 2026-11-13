# ==========================================
# Microsoft 365 E3 ユーザー抽出
#
# 条件:
# 1. Microsoft 365 E3 が付与されている
# 2. SharePoint Online Plan 2 が無効
# 3. 勤務地所在地に「宇都宮」を含む
# ==========================================

$ErrorActionPreference = "Stop"

# CSV出力先
$CsvPath = "C:\Temp\E3_NoSharePoint_Utsunomiya.csv"

# 出力フォルダ作成
New-Item -ItemType Directory `
    -Path "C:\Temp" -Force | Out-Null

# Microsoft Graph 接続
Connect-MgGraph -Scopes `
    "User.Read.All", "Organization.Read.All"

# E3 SKU取得
$E3Sku = Get-MgSubscribedSku |
    Where-Object {
        $_.SkuPartNumber -eq "SPE_E3"
    }

if (-not $E3Sku) {
    throw "Microsoft 365 E3が見つかりません"
}

Write-Host "ユーザー情報を取得中..."

# E3付与済み + 宇都宮のユーザー
$Users = @(
    Get-MgUser -All `
        -Property "Id,DisplayName,UserPrincipalName,AssignedLicenses,OfficeLocation" |
        Where-Object {
            $_.AssignedLicenses.SkuId -contains $E3Sku.SkuId -and
            $_.OfficeLocation -like "*宇都宮*"
        }
)

Write-Host "対象ユーザー数: $($Users.Count)"

# SharePoint Plan 2 の状態確認
$Result = @(
    foreach ($User in $Users) {

        $Licenses = Get-MgUserLicenseDetail `
            -UserId $User.Id

        $E3License = $Licenses |
            Where-Object {
                $_.SkuId -eq $E3Sku.SkuId
            }

        $SPPlan = $E3License.ServicePlans |
            Where-Object {
                $_.ServicePlanName -eq "SHAREPOINTENTERPRISE"
            }

        # SharePointが有効でない場合
        if (-not $SPPlan -or
            $SPPlan.ProvisioningStatus -ne "Success") {

            [PSCustomObject]@{
                DisplayName       = $User.DisplayName
                UserPrincipalName = $User.UserPrincipalName
                OfficeLocation    = $User.OfficeLocation
                SharePointStatus  = if ($SPPlan) {
                    $SPPlan.ProvisioningStatus
                } else {
                    "NotAssigned"
                }
            }
        }
    }
)

# 結果出力
if ($Result.Count -gt 0) {

    $Result |
        Export-Csv `
            -Path $CsvPath `
            -NoTypeInformation `
            -Encoding UTF8

    Write-Host "CSV出力完了: $CsvPath" -ForegroundColor Green
    Write-Host "抽出件数: $($Result.Count)"

} else {

    Write-Host "該当ユーザーは0件でした。" `
        -ForegroundColor Yellow

}
