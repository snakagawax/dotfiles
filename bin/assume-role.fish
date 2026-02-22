#!/usr/bin/env fish

# ==================== 設定 ====================
set MFA_1PASSWORD_ITEM "AWS"
set DEFAULT_REGION "ap-northeast-1"
set AWS_CONFIG_FILE ~/.aws/config
# ==============================================

# 履歴ファイルのパス
set PROFILE_HISTORY_FILE ~/.aws/profile_history

# 引数チェック
if test (count $argv) -lt 1
    # fzf が利用可能か確認
    if not command -q fzf
        echo "Usage: source ~/bin/assume-role.fish <profile-name> [-c|--console] [-e|--export] [-l|--long]"
        echo "  -c, --console    Open AWS Management Console in browser"
        echo "  -e, --export     Output credentials as fish environment variables (for eval)"
        echo "  -l, --long       Use maximum session duration (12 hours, requires role configuration)"
        echo ""
        echo "Note: -l option does not work with role chaining (1h limit). 1Password plugin uses temp creds internally."
        echo ""
        echo "Tip: Install fzf to enable interactive profile selection"
        return 1
    end

    # プロファイル一覧を取得（説明付き）
    # 形式: "profile_name\tdescription" または "profile_name\t"
    set profiles_with_desc (awk '
        /^#/ { desc = substr($0, 2); gsub(/^[ \t]+/, "", desc) }
        /^\[profile / {
            name = $0
            gsub(/^\[profile /, "", name)
            gsub(/\].*/, "", name)
            print name "\t" desc
            desc = ""
        }
    ' $AWS_CONFIG_FILE)

    if test (count $profiles_with_desc) -eq 0
        echo "Error: No profiles found in $AWS_CONFIG_FILE"
        return 1
    end

    # プロファイル名だけのリストも作成（contains チェック用）
    set all_profiles
    for line in $profiles_with_desc
        set -a all_profiles (echo $line | cut -f1)
    end

    # 使用履歴があれば頻度順でソート
    set sorted_profiles_with_desc
    if test -f $PROFILE_HISTORY_FILE
        # 履歴の出現頻度順でプロファイルを取得
        set history_sorted (cat $PROFILE_HISTORY_FILE | sort | uniq -c | sort -rn | awk '{print $2}')
        # 履歴にあるプロファイル（有効なもののみ）を追加
        for p in $history_sorted
            if contains $p $all_profiles
                # 対応する説明付き行を取得
                for line in $profiles_with_desc
                    set profile_name_check (echo $line | cut -f1)
                    if test "$profile_name_check" = "$p"
                        set -a sorted_profiles_with_desc $line
                        break
                    end
                end
            end
        end
        # 履歴にないプロファイルをアルファベット順で追加
        set added_profiles
        for line in $sorted_profiles_with_desc
            set -a added_profiles (echo $line | cut -f1)
        end
        for line in $profiles_with_desc
            set profile_name_check (echo $line | cut -f1)
            if not contains $profile_name_check $added_profiles
                set -a sorted_profiles_with_desc $line
            end
        end | sort
        # 未追加分をソートして追加
        set remaining
        for line in $profiles_with_desc
            set profile_name_check (echo $line | cut -f1)
            if not contains $profile_name_check $added_profiles
                set -a remaining $line
            end
        end
        set sorted_remaining (printf '%s\n' $remaining | sort)
        for line in $sorted_remaining
            set -a sorted_profiles_with_desc $line
        end
    else
        # 履歴がなければアルファベット順
        set sorted_profiles_with_desc (printf '%s\n' $profiles_with_desc | sort)
    end

    # fzf で選択（説明付き表示）
    set selected (printf '%s\n' $sorted_profiles_with_desc | \
        fzf --prompt="Select AWS Profile: " \
            --height=40% --reverse \
            --delimiter='\t' \
            --with-nth=1,2 \
            --tabstop=20 \
            --nth=1)

    # プロファイル名だけ抽出
    set selected_profile (echo $selected | cut -f1)
    if test -z "$selected_profile"
        echo "Cancelled."
        return 1
    end
    set argv[1] $selected_profile
end

set profile_name $argv[1]
set open_console_flag false
set export_flag false
set long_duration_flag false
for arg in $argv[2..-1]
    switch $arg
        case '-c' '--console'
            set open_console_flag true
        case '-e' '--export'
            set export_flag true
        case '-l' '--long'
            set long_duration_flag true
    end
end

# 既存の認証情報をクリア
set -e AWS_ACCESS_KEY_ID
set -e AWS_SECRET_ACCESS_KEY
set -e AWS_SESSION_TOKEN

# configファイルの存在確認
if not test -f $AWS_CONFIG_FILE
    echo "Error: Config file not found: $AWS_CONFIG_FILE"
    return 1
end

# 情報メッセージを出力（-e時はstderrへ）
function __assume_role_echo
    if test "$export_flag" = "true"
        echo $argv >&2
    else
        echo $argv
    end
end

__assume_role_echo "=== Loading profile: $profile_name ==="

# プロファイル設定を取得
set sso_start_url (awk "/^\[profile $profile_name\]/"'{found=1; next} found && /^\[/{found=0} found && /^sso_start_url/{sub(/^sso_start_url[[:space:]]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; exit}' $AWS_CONFIG_FILE)
set region (awk "/^\[profile $profile_name\]/"'{found=1; next} found && /^\[/{found=0} found && /^region/{sub(/^region[[:space:]]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; exit}' $AWS_CONFIG_FILE)
set role_arn (awk "/^\[profile $profile_name\]/"'{found=1; next} found && /^\[/{found=0} found && /^role_arn/{sub(/^role_arn[[:space:]]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; exit}' $AWS_CONFIG_FILE)
set source_profile (awk "/^\[profile $profile_name\]/"'{found=1; next} found && /^\[/{found=0} found && /^source_profile/{sub(/^source_profile[[:space:]]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; exit}' $AWS_CONFIG_FILE)
set mfa_serial (awk "/^\[profile $profile_name\]/"'{found=1; next} found && /^\[/{found=0} found && /^mfa_serial/{sub(/^mfa_serial[[:space:]]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; exit}' $AWS_CONFIG_FILE)

test -z "$region"; and set region $DEFAULT_REGION

# ========== SSOプロファイル ==========
if test -n "$sso_start_url"
    __assume_role_echo "Type: SSO | Region: $region"

    __assume_role_echo ""
    __assume_role_echo "=== Logging in to AWS SSO ==="
    command aws sso login --profile $profile_name
    or begin; echo "Error: Failed to login to AWS SSO" >&2; return 1; end

    __assume_role_echo ""
    __assume_role_echo "=== Retrieving credentials ==="
    set credentials (command aws configure export-credentials --profile $profile_name)
    or begin; echo "Error: Failed to export credentials" >&2; return 1; end

    set access_key_id (echo $credentials | jq -r '.AccessKeyId')
    set secret_access_key (echo $credentials | jq -r '.SecretAccessKey')
    set session_token (echo $credentials | jq -r '.SessionToken')

    # -e オプション: 環境変数形式で出力して終了
    if test "$export_flag" = "true"
        echo "set -gx AWS_ACCESS_KEY_ID $access_key_id"
        echo "set -gx AWS_SECRET_ACCESS_KEY $secret_access_key"
        echo "set -gx AWS_SESSION_TOKEN $session_token"
        echo "set -gx AWS_REGION $region"
        echo "set -gx AWS_DEFAULT_REGION $region"
        return 0
    end

    set -gx AWS_ACCESS_KEY_ID $access_key_id
    set -gx AWS_SECRET_ACCESS_KEY $secret_access_key
    set -gx AWS_SESSION_TOKEN $session_token

    echo ""
    echo "=== Credentials set ==="
    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    set expiration (echo $credentials | jq -r '.Expiration')
    test "$expiration" != "null"; and echo "Expiration: $expiration"

    echo ""
    echo "=== Current Identity ==="
    aws sts get-caller-identity --region $region

    # 使用履歴に追記
    echo $profile_name >> $PROFILE_HISTORY_FILE

    if test "$open_console_flag" = "true"
        echo ""
        echo "=== Opening AWS Management Console ==="

        set session_json (printf '{"sessionId":"%s","sessionKey":"%s","sessionToken":"%s"}' \
            $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_SESSION_TOKEN)
        set session_encoded (echo $session_json | jq -sRr @uri)
        set signin_response (curl -s "https://signin.aws.amazon.com/federation?Action=getSigninToken&Session=$session_encoded")
        set signin_token (echo $signin_response | jq -r '.SigninToken')

        if test -z "$signin_token" -o "$signin_token" = "null"
            echo "Error: Failed to get signin token"
            return 1
        end

        set destination "https://$region.console.aws.amazon.com/console/home?region=$region#"
        set destination_encoded (printf %s "$destination" | jq -sRr @uri)
        set console_url "https://signin.aws.amazon.com/federation?Action=login&Destination=$destination_encoded&SigninToken=$signin_token"

        open "$console_url"
        echo "Console opened in browser (Region: $region)"
    end
    return 0
end

# ========== Assume Role ==========
if test -z "$role_arn"
    echo "Error: role_arn not found for profile: $profile_name" >&2
    return 1
end

__assume_role_echo "Type: Assume Role | Region: $region"
__assume_role_echo "Role ARN: $role_arn"
test -n "$source_profile"; and __assume_role_echo "Source Profile: $source_profile"
test -n "$mfa_serial"; and __assume_role_echo "MFA Serial: $mfa_serial"

__assume_role_echo ""
__assume_role_echo "=== Source Identity ==="
if test "$export_flag" = "true"
    op plugin run -- aws sts get-caller-identity >&2
else
    op plugin run -- aws sts get-caller-identity
end

__assume_role_echo ""
__assume_role_echo "=== Assuming role ==="

set credentials
# -l オプション: 最大セッション時間（12時間）を使用
set duration_args
if test "$long_duration_flag" = "true"
    set duration_args --duration-seconds 43200
    __assume_role_echo "Session Duration: 12 hours (max)"
end

# プロファイル自体にmfa_serialがある場合のみMFA使用
if test -n "$mfa_serial"
    set credentials (op plugin run -- aws sts assume-role \
        --role-arn $role_arn \
        --role-session-name $profile_name \
        --serial-number $mfa_serial \
        --token-code (op item get $MFA_1PASSWORD_ITEM --otp) \
        --region $region \
        $duration_args \
        --output json)
    or begin; echo "Error: Failed to assume role" >&2; return 1; end
else
    # MFAなし: source_profileがあればそれを使用
    if test -n "$source_profile"
        set credentials (op plugin run -- aws sts assume-role \
            --role-arn $role_arn \
            --role-session-name $profile_name \
            --profile $source_profile \
            --region $region \
            $duration_args \
            --output json)
        or begin; echo "Error: Failed to assume role" >&2; return 1; end
    else
        set credentials (op plugin run -- aws sts assume-role \
            --role-arn $role_arn \
            --role-session-name $profile_name \
            --region $region \
            $duration_args \
            --output json)
        or begin; echo "Error: Failed to assume role" >&2; return 1; end
    end
end

set access_key_id (echo $credentials | jq -r '.Credentials.AccessKeyId')
set secret_access_key (echo $credentials | jq -r '.Credentials.SecretAccessKey')
set session_token (echo $credentials | jq -r '.Credentials.SessionToken')

# -e オプション: 環境変数形式で出力して終了
if test "$export_flag" = "true"
    echo "set -gx AWS_ACCESS_KEY_ID $access_key_id"
    echo "set -gx AWS_SECRET_ACCESS_KEY $secret_access_key"
    echo "set -gx AWS_SESSION_TOKEN $session_token"
    echo "set -gx AWS_REGION $region"
    echo "set -gx AWS_DEFAULT_REGION $region"
    return 0
end

set -gx AWS_ACCESS_KEY_ID $access_key_id
set -gx AWS_SECRET_ACCESS_KEY $secret_access_key
set -gx AWS_SESSION_TOKEN $session_token

echo ""
echo "=== Credentials set ==="
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
set expiration_utc (echo $credentials | jq -r '.Credentials.Expiration')
set expiration_jst (TZ=Asia/Tokyo date -j -f "%Y-%m-%dT%H:%M:%SZ" "$expiration_utc" "+%Y-%m-%d %H:%M:%S JST" 2>/dev/null)
if test -n "$expiration_jst"
    echo "Expiration: $expiration_jst"
else
    echo "Expiration: $expiration_utc"
end

echo ""
echo "=== Assumed Identity ==="
aws sts get-caller-identity --region $region

# 使用履歴に追記
echo $profile_name >> $PROFILE_HISTORY_FILE

if test "$open_console_flag" = "true"
    echo ""
    echo "=== Opening AWS Management Console ==="

    set session_json (printf '{"sessionId":"%s","sessionKey":"%s","sessionToken":"%s"}' \
        $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_SESSION_TOKEN)
    set session_encoded (echo $session_json | jq -sRr @uri)
    set signin_response (curl -s "https://signin.aws.amazon.com/federation?Action=getSigninToken&Session=$session_encoded")
    set signin_token (echo $signin_response | jq -r '.SigninToken')

    if test -z "$signin_token" -o "$signin_token" = "null"
        echo "Error: Failed to get signin token"
        return 1
    end

    set destination "https://$region.console.aws.amazon.com/console/home?region=$region#"
    set destination_encoded (printf %s "$destination" | jq -sRr @uri)
    set console_url "https://signin.aws.amazon.com/federation?Action=login&Destination=$destination_encoded&SigninToken=$signin_token"

    open "$console_url"
    echo "Console opened in browser (Region: $region)"
end
