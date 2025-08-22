function claude-init -d "Claude マルチエージェントプロジェクトを現在のディレクトリに初期化（引数不要）"
    # ~/.local/bin/claude-init を呼び出し
    if test -x ~/.local/bin/claude-init
        ~/.local/bin/claude-init
    else
        echo "❌ claude-init スクリプトが見つかりません"
        echo "   ~/.local/bin/claude-init を確認してください"
        return 1
    end
end