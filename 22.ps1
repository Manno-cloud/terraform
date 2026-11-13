# powershell.exe -ExecutionPolicy Bypass -File .\Add365Users.ps1 <CSVファイル>

# ====================================================================================================
# ■必須プロパティ
# AccountEnabled: ユーザーアカウントを有効にするかどうか（$true / $false）
# DisplayName: ユーザーの表示名
# MailNickname: メールメールニックネーム（メールのローカルパート）
# PasswordProfile: パスワード設定（Password および ForceChangePasswordNextSignIn を含むオブジェクト）
# UserPrincipalName: ユーザーのログイン名（例: user@domain.com）
#
# ■任意プロパティ
# GivenName: 名
# Surname: 姓
# JobTitle: 役職
# Department: 部門
# UsageLocation: 使用場所（ライセンス割り当てに必須、例: JP）
# MobilePhone: 携帯電話番号
# BusinessPhones: 会社の電話番号（配列）
# OfficeLocation: オフィス場所
# Mail: ユーザーのメールアドレス
# EmployeeId: 社員番号
# ====================================================================================================

# --- 引数を取得 ---
param(
    [string]$CsvPath
)

Start-Transcript -Path "$PSScriptRoot\result.txt" -Force

# ===== 文字コード判断処理 =====
function Get-EncodingFromBom {
    param([string]$Path)

    # FileStream を使ってキャッシュを回避
    $fs = [System.IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite')
    $bytes = New-Object byte[] 4
    $fs.Read($bytes, 0, 4) | Out-Null
    $fs.Close()

    switch -regex ([BitConverter]::ToString($bytes)) {
        '^EF-BB-BF' { return 'UTF8-BOM' }
        '^FF-FE'    { return 'UTF16-LE' }
        '^FE-FF'    { return 'UTF16-BE' }
        default     { return 'Unknown' }
    }
}

# ===== メイン処理 =====

# --- 引数チェック ---
if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    Write-Host "エラー: CSV ファイルのパスが指定されていません。" -ForegroundColor Yellow
    Write-Host "Usage : Add365Users.ps1 <CSVファイル>" -ForegroundColor Yellow
    Write-Host ''
    exit 1
}

# --- CSV ファイル存在チェック ---
if (-not (Test-Path -Path $CsvPath)) {
    Write-Host "エラー: 指定された CSV ファイルが存在しません。パス: $CsvPath" -ForegroundColor Yellow
    Write-Host ''
    exit 1
}

# --- CSV ファイル文字コードチェック ---
$enc = Get-EncodingFromBom $CsvPath
if ($enc -ne "UTF8-BOM") {
    Write-Warning "このファイルは UTF-8 (BOM付き) ではありません。処理を中断します。"
    exit 1
}

# --- Microsoft Graph に接続 ---
Write-Host "Microsoft Graph に接続中..." -ForegroundColor Green
Connect-MgGraph -Scopes "Directory.ReadWrite.All","User.ReadWrite.All","Directory.AccessAsUser.All" -NoWelcome

# --- Microsoft Exchange Online に接続 ---
Write-Host "Microsoft Exchange Online に接続中..." -ForegroundColor Green
Connect-ExchangeOnline

# --- 必要なモジュールを読み込む ---
Import-Module Microsoft.Graph.Users
Import-Module ExchangeOnlineManagement


# --- ライセンスの割り当て ---
# E3ライセンス付与
# 以下のアプリは除外
# "6c57d4b6-3b23-47a5-9bc9-69f17b4947b3"	Azure Information Protection Premium P1
# "bea4c11e-220a-4e6d-8eb8-8ea15d019f90"	Azure Rights Management 
# "4ff01e01-1ba7-4d71-8cf8-ce96c3bbcf14"	Common Data Service
# "95b76021-6a53-4741-ab8b-1d1f3d66a95a"	Common Data Service for Teams
# "33c4f319-9bdd-48d6-9c4d-410b750a4a5a"	Insights by MyAnalytics
# "199a5c09-e0ca-4e37-8f7c-b05d533e1ea2"	Microsoft Bookings
# "a1ace008-72f3-4ea0-8dac-33b3a23a2472"	Microsoft Clipchamp
# "292cc034-7b7c-4950-aaf5-943befd3f1d4"	Microsoft Defender for Endpoint プラン 1
# "c1ec4a95-1f05-45b3-a911-aa3fa01094f5"	Microsoft Intune プラン 1
# "aebd3021-9f8f-4bf8-bbe3-0ed2f4f047a1"	Microsoft Kaizala Pro
# "b737dad2-2f6c-4c65-90e3-ca563267e8b9"	Microsoft Planner
# "8c7d2df8-86f0-4902-b2ed-a0458298f3b3"	Microsoft StaffHub
# "9e700747-8b1d-45e5-ab8d-ef187ceec156"	Microsoft Stream for Office 365 E3
# "c4b8c31a-fb44-4c65-9837-a21f55fcabda"	Microsoft ループ
# "5136a095-5cf0-4aff-bec3-e84448b38ea5"	Office 365 の Information Protection - Standard
# "882e1d05-acd1-4ccb-8708-6ee03664b117"	Office 365 のモバイル デバイス管理
# "e95bec33-7c88-4a70-8e19-b10bd9d0c014"	Office for the Web
# "13b6da2c-0d84-450e-9f69-a33e221387ca"	People Skills - Foundation
# "1fe6227d-3e01-46d0-9510-0acad4ff6e94"	Places Core
# "c68f8d98-5534-41c8-bf36-22fa496fa792"	Power Apps for Office 365
# "76846ad7-7776-4c40-a281-a386362dd1b9"	Power Automate for Office 365
# "041fe683-03e4-45b6-b1af-c0cdc516daee"	Power Virtual Agents for Office 365
# "31b4e2fc-4cd6-4e7d-9c1b-41407303bd66"	Project for Office (プラン E3)
# "5dbe027f-2339-4123-9542-606e4d348a72"	SharePoint (プラン 2)
# "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"	Skype for Business Online (プラン 2)
# "a23b959c-7ce8-4e57-9140-b90eb88a9e97"	Sway
# "dcf9d2f4-772e-4434-b757-77a453cfbc02"	Teams のアバター
# "3efbd4ed-8958-4824-8389-1321f8730af8"	Teams のアバター (追加) 
# "f0ff6ac6-297d-49cd-be34-6dfef97f0c28"	Teams のイマーシブ スペース
# "c87f142c-d1e9-4363-8630-aaea9c4d9ae5"	To-Do (プラン 2)
# "a82fbf69-b4d7-49f4-83a6-915b2cf354f4"	Viva Engage Core
# "b76fb638-6ba6-402a-b9f9-83d28acb3d86"	Viva Learning Seeded
# "94a54592-cd8b-425e-87c6-97868b000b91"	Whiteboard (プラン 2)
# "21b439ba-a0ca-424f-a6cc-52f954a5b111"	Windows 10/11 Enterprise (オリジナル)
# "9a6eeb79-0b4b-4bf0-9808-39d99a2cd5a3"	Windows Autopatch
# "7bf960f6-2cd9-443a-8046-5dbff9558365"	Windows Update for Business 展開サービス
# "7547a3fe-08ee-4ccb-b430-5077c5041653"	Yammer Enterprise
# "a6520331-d7d4-4276-95f5-15c0933bc757"	インデックスを使用したグラフ コネクタの検索
# "795f6fe0-cc4d-4773-b050-5dde4dc704c9"	ユニバーサル印刷
$AddLicense = @{
    SkuId         = "05e9a617-0261-4cee-bb44-138d3ef5d965"
    DisabledPlans =@("6c57d4b6-3b23-47a5-9bc9-69f17b4947b3", `
                     "bea4c11e-220a-4e6d-8eb8-8ea15d019f90", `
                     "4ff01e01-1ba7-4d71-8cf8-ce96c3bbcf14", `
                     "95b76021-6a53-4741-ab8b-1d1f3d66a95a", `
                     "33c4f319-9bdd-48d6-9c4d-410b750a4a5a", `
                     "199a5c09-e0ca-4e37-8f7c-b05d533e1ea2", `
                     "a1ace008-72f3-4ea0-8dac-33b3a23a2472", `
                     "292cc034-7b7c-4950-aaf5-943befd3f1d4", `
                     "c1ec4a95-1f05-45b3-a911-aa3fa01094f5", `
                     "aebd3021-9f8f-4bf8-bbe3-0ed2f4f047a1", `
                     "b737dad2-2f6c-4c65-90e3-ca563267e8b9", `
                     "8c7d2df8-86f0-4902-b2ed-a0458298f3b3", `
                     "9e700747-8b1d-45e5-ab8d-ef187ceec156", `
                     "c4b8c31a-fb44-4c65-9837-a21f55fcabda", `
                     "5136a095-5cf0-4aff-bec3-e84448b38ea5", `
                     "882e1d05-acd1-4ccb-8708-6ee03664b117", `
                     "e95bec33-7c88-4a70-8e19-b10bd9d0c014", `
                     "13b6da2c-0d84-450e-9f69-a33e221387ca", `
                     "1fe6227d-3e01-46d0-9510-0acad4ff6e94", `
                     "c68f8d98-5534-41c8-bf36-22fa496fa792", `
                     "76846ad7-7776-4c40-a281-a386362dd1b9", `
                     "041fe683-03e4-45b6-b1af-c0cdc516daee", `
                     "31b4e2fc-4cd6-4e7d-9c1b-41407303bd66", `
                     "5dbe027f-2339-4123-9542-606e4d348a72", `
                     "0feaeb32-d00e-4d66-bd5a-43b5b83db82c", `
                     "a23b959c-7ce8-4e57-9140-b90eb88a9e97", `
                     "dcf9d2f4-772e-4434-b757-77a453cfbc02", `
                     "3efbd4ed-8958-4824-8389-1321f8730af8", `
                     "f0ff6ac6-297d-49cd-be34-6dfef97f0c28", `
                     "c87f142c-d1e9-4363-8630-aaea9c4d9ae5", `
                     "a82fbf69-b4d7-49f4-83a6-915b2cf354f4", `
                     "b76fb638-6ba6-402a-b9f9-83d28acb3d86", `
                     "94a54592-cd8b-425e-87c6-97868b000b91", `
                     "21b439ba-a0ca-424f-a6cc-52f954a5b111", `
                     "9a6eeb79-0b4b-4bf0-9808-39d99a2cd5a3", `
                     "7bf960f6-2cd9-443a-8046-5dbff9558365", `
                     "7547a3fe-08ee-4ccb-b430-5077c5041653", `
                     "a6520331-d7d4-4276-95f5-15c0933bc757", `
                     "795f6fe0-cc4d-4773-b050-5dde4dc704c9")
}

# --- CSVファイル読み込み ---
Write-Host "CSV 読み込み中: $CsvPath"
$users = Import-Csv -Path $CsvPath

# --- 初期パスワード ---
$InitialPW = "Password@365"

# --- 新規ユーザー作成&ライセンス付与 ---
foreach ($user in $users) {
    # --- 既にユーザーが登録済みか確認 ---
    if ((Get-MgUser -UserId $user.ユーザー名 -ErrorAction SilentlyContinue)) {
        Write-Host "ユーザー'"$user.ユーザー名"'は既に存在します。" -Separator "" -ForegroundColor Yellow
        continue
    }

    # --- 既にユーザーが他のユーザーのメールエイリアスで使用されていないか確認 ---
    $TargetAlias = $user.ユーザー名.ToLower()
    # 一致チェック
    $MatchedUsers = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,ProxyAddresses | Where-Object {
        $_.ProxyAddresses -ne $null -and
        ($_.ProxyAddresses | ForEach-Object { $_.Substring(5).ToLower() }) -contains $TargetAlias
    }
    if ($MatchedUsers) {
        Write-Host "ユーザー'"$user.ユーザー名"'は既にメールエイリアスで使用されています。" -Separator "" -ForegroundColor Red
        $MatchedUsers | Select-Object DisplayName, UserPrincipalName
        continue
    }

    # --- 新規ユーザー作成 ---
    try {
        # 必須項目のチェック（どれか一つでも空ならエラーにする）
        $requiredFields = @("表示名", "ユーザー名")
        foreach ($field in $requiredFields) {
            if ([string]::IsNullOrWhiteSpace($user.$field)) {
                # 必須項目が空なら例外を投げる
                throw "必須パラメータ '$field' が設定されていません。 (行: $($user.UserPrincipalName))"
            }
        }

        # --- 基本パラメータの作成 ---
        $params = @{
            AccountEnabled    = $true
            UserPrincipalName = $user.ユーザー名
            DisplayName       = $user.表示名
            Surname           = $user.姓
            GivenName         = $user.名
            MailNickname      = ($user.ユーザー名 -split "@")[0]
            OfficeLocation    = $user.事業所番号
            UsageLocation     = "JP"
            Country           = "日本"
            PreferredLanguage = "ja-JP"
            PasswordProfile   = @{
                Password                      = $InitialPW
                ForceChangePasswordNextSignIn = $true
            }
        }
        # 「役職」 が空でない場合のみ、ハッシュテーブルに追加する
        if (-not [string]::IsNullOrWhiteSpace($user.役職)) {
            $params.Add("JobTitle", $user.役職)
        }
        # 「部署」 が空でない場合のみ、ハッシュテーブルに追加する
        if (-not [string]::IsNullOrWhiteSpace($user.部署)) {
            $params.Add("Department", $user.部署)
        }
        try {
            New-MgUser -BodyParameter $params > $nul
            Write-Host "ユーザー'"$user.ユーザー名"'を登録しました。" -Separator "" -ForegroundColor Cyan
        }
        catch {
            Write-Host "ユーザー'"$user.ユーザー名"'の登録に失敗しました！" -Separator "" -ForegroundColor Red
        }
    }
    catch {
        Write-Error "エラー発生: $($_.Exception.Message)"
    }

    # --- ライセンス付与 ---
    try {
        Set-MgUserLicense -UserId $user.ユーザー名 -AddLicenses $AddLicense -RemoveLicenses @() > $nul
        Write-Host "ユーザー'"$user.ユーザー名"'にE3ライセンスを付与しました。" -Separator "" -ForegroundColor Cyan
    }
    catch {
        Write-Host "ユーザー'"$user.ユーザー名"'へのライセンス付与に失敗しました！" -Separator "" -ForegroundColor Red
    }

    # --- メールボックス作成確認 ---
    $timeoutSeconds  = 300  # 最大待ち時間（5分 = 300秒）
    $intervalSeconds = 10   # 確認の間隔（10秒）
    $startTime       = Get-Date
    $mailboxReady    = $false

    Write-Host "メールボックスの作成を待機しています: "$user.ユーザー名 -ForegroundColor Cyan

    do {
        try {
            # Exchange Online上でメールボックスが存在するか確認
            if (Get-Mailbox -Identity $user.ユーザー名 -ErrorAction Stop) {
                $mailboxReady = $true
                $totalElapsed = [Math]::Round(((Get-Date) - $startTime).TotalSeconds)
                Write-Host "成功: メールボックスが作成されました（経過: $totalElapsed 秒）" -ForegroundColor Green
            }
        }
        catch {
            # まだ作成されていない場合は、経過秒数を表示して待機
            $elapsedSeconds = [Math]::Round(((Get-Date) - $startTime).TotalSeconds)
            Write-Host -NoNewline "`r...作成待ち ($($elapsedSeconds) 秒経過) " 
            Start-Sleep -Seconds $intervalSeconds
        }

        # タイムアウト判定
        if (((Get-Date) - $startTime).TotalSeconds -gt $timeoutSeconds) {
            Write-Host "`n"
            Write-Error "タイムアウト: $timeoutSeconds 秒以内に作成されませんでした。"
            break
        }
    } until ($mailboxReady)

    # --- メールエイリアス付与 ---
    if ($mailboxReady) {
        try {
            $NewAlias = $user.ユーザー名 -replace "@.*$", "@jbusk.onmicrosoft.com"
            Set-Mailbox -Identity $user.ユーザー名 -EmailAddresses @{add=$NewAlias} > $nul
            Write-Host "メールエイリアス'"$NewAlias"'を登録しました。" -Separator "" -ForegroundColor Cyan
        }
        catch {
            Write-Host "メールエイリアス'"$NewAlias"'の登録に失敗しました！" -Separator "" -ForegroundColor Red
        }
    }
}

Stop-Transcript
