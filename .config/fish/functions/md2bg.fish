function md2bg
    # 現在のディレクトリを保存
    set -l current_dir (pwd)
    set -l md2bg_dir ~/ghq/github.com/snakagawax/md2bg
    
    if test -n "$argv[1]" -a -f "$argv[1]"
        # 入力ファイルのフルパスを取得
        set -l input_file (realpath "$argv[1]")
        echo "入力ファイル: $input_file"
        # 絶対パスを直接渡す
        cd $md2bg_dir
        node $md2bg_dir/build/src/bin/index.js "$input_file"
    else if test -n "$argv[1]" -a "$argv[1]" = "--stdin"
        # 標準入力から読み込む場合
        cd $md2bg_dir
        cat | node $md2bg_dir/build/src/bin/index.js --stdin
    else
        # その他の引数をそのまま渡す
        cd $md2bg_dir
        node $md2bg_dir/build/src/bin/index.js $argv
    end
    
    # 元のディレクトリに戻る
    cd $current_dir
end 