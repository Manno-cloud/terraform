# 対象グループ
$GroupName = "宇都宮ニュースDL"

# 出力先
$CsvPath = "C:\Temp\UtsunomiyaNewsDL.csv"

# グループ取得
$Groups = @(
    Get-MgGroup -Filter "displayName eq '$GroupName'" -All
)

if ($Groups.Count -ne 1) {
    throw "対象グループが一意に見つかりません。件数: $($Groups.Count)"
}

$Group = $Groups[0]

# グループの直接メンバーを取得
$Members = Get-MgGroupMemberAsUser `
    -GroupId $Group.Id `
    -All `
    -Property "id,displayName,userPrincipalName,mail"

# CSV出力
$Members |
    Select-Object DisplayName, UserPrincipalName, Mail |
    Sort-Object DisplayName |
    Export-Csv `
        -Path $CsvPath `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "出力完了: $CsvPath"
Write-Host "ユーザー数: $(@($Members).Count)"
