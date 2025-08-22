function reset_env
    # 現在の環境変数をファイルに保存
    set -l temp_file (mktemp)
    env > $temp_file

    # 重要な環境変数のリスト
    set -l keep_vars PATH HOME SHELL USER TERM LANG LC_ALL PWD SSH_AUTH_SOCK DISPLAY

    # すべての環境変数をクリア
    for var in (set -nx)
        if not contains $var $keep_vars
            set -e $var
        end
    end

    echo "環境変数をリセットしました"
    echo "元の環境変数は $temp_file に保存されています"
end