function ct --description "Claude in tmux"
    set -l subcmd $argv[1]

    switch "$subcmd"
        case list ls
            _ct_list
        case kill
            _ct_kill $argv[2..]
        case help -h --help
            _ct_help
        case '*'
            _ct_new $argv
    end
end

function _ct_cleanup
    for line in (tmux list-sessions -F '#{session_name} #{session_attached}' 2>/dev/null)
        set -l parts (string split ' ' $line)
        set -l name $parts[1]
        set -l attached $parts[2]
        if string match -q 'claude*' $name; and test "$attached" = 0
            tmux kill-session -t $name 2>/dev/null
        end
    end
end

function _ct_list
    set -l sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^claude')
    if test (count $sessions) -eq 0
        echo "claude セッションなし"
        return
    end
    tmux list-sessions -F '#{session_name}: #{session_attached} attached (created #{t:session_created})' 2>/dev/null | grep '^claude'
end

function _ct_kill
    if test "$argv[1]" = --all
        set -l sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^claude')
        set -l count (count $sessions)
        for s in $sessions
            tmux kill-session -t $s
        end
        echo "$count セッション終了"
        return
    end
    if test -z "$argv[1]"
        echo "使い方: ct kill <session-name> | ct kill --all"
        return 1
    end
    tmux kill-session -t $argv[1]
end

function _ct_new
    if set -q TMUX
        claude --dangerously-skip-permissions $argv
        return
    end

    _ct_cleanup

    set -l existing (tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^claude')
    set -l name claude

    if contains claude $existing
        set -l n 2
        while contains "claude-$n" $existing
            set n (math $n + 1)
        end
        set name "claude-$n"
    end

    tmux new-session -s $name -- claude --dangerously-skip-permissions $argv
end

function _ct_help
    echo "ct                  新規セッション作成（デタッチ済みは自動kill）"
    echo "ct list|ls          セッション一覧"
    echo "ct kill <name>      セッション終了"
    echo "ct kill --all       全 claude セッション終了"
    echo "ct help|-h          この表示"
end
