function ss_client --description 'Client specific screenshot manager'
    # コマンドが指定されていない場合
    if test (count $argv) -lt 1
        echo "使用方法: ss_client [start|stop] YYYYMMDD"
        echo "例: ss_client start 20230915"
        return 1
    end

    set -l command $argv[1]

    switch $command
        case start
            # startの場合は日付が必要
            if test (count $argv) -ne 2
                echo "使用方法: ss_client start YYYYMMDD"
                echo "例: ss_client start 20230915"
                return 1
            end

            set -l date $argv[2]
            
            # クライアント固定設定
            set -l client "suntory"
            set -l client_short "sst"
            set -l base_dir "$HOME/project/$client/meetings"
            set -l ss_dir "$base_dir/$date/ss"

            # ディレクトリ存在確認・作成
            if not test -d $ss_dir
                mkdir -p $ss_dir
            end

            # 現在の設定をバックアップ
            defaults read com.apple.screencapture location > /tmp/ss_location_backup
            defaults read com.apple.screencapture name > /tmp/ss_name_backup

            # 連番の開始番号を設定
            set -l next_num 1
            while test -e "$ss_dir/{$client_short}_{$date}_(printf '%03d' $next_num).png"
                set next_num (math $next_num + 1)
            end

            # スクリーンショットの設定を変更
            defaults write com.apple.screencapture location $ss_dir
            defaults write com.apple.screencapture name "{$client_short}_{$date}_(printf '%03d' $next_num)"

            killall SystemUIServer

            # 作業状態を保存
            set -U SS_CLIENT_MODE "$client:$date"

            echo "🟢 $client モードを開始しました"
            echo "保存先: $ss_dir"
            echo "次のスクリーンショット: {$client_short}_{$date}_(printf '%03d' $next_num).png"

        case stop
            # stopの場合は追加の引数は不要
            if test -f /tmp/ss_location_backup
                # 設定を元に戻す
                defaults write com.apple.screencapture location (cat /tmp/ss_location_backup)
                defaults write com.apple.screencapture name (cat /tmp/ss_name_backup)

                killall SystemUIServer

                rm /tmp/ss_location_backup
                rm /tmp/ss_name_backup

                # 作業状態をクリア
                set -e SS_CLIENT_MODE

                echo "🔴 通常モードに戻しました"
            else
                echo "⚠️ バックアップ設定が見つかりません"
            end

        case '*'
            echo "使用方法: ss_client [start|stop] YYYYMMDD"
            echo "例: ss_client start 20230915"
            return 1
    end
end