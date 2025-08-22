function peco_select_ssm_instance
    # インスタンスの一覧を取得
    set -l instances (aws ssm describe-instance-information --query 'InstanceInformationList[*].InstanceId' --output text)

    # pecoでインスタンスを選択
    echo $instances | tr ' ' '\n' | peco | read -l selected_instance

    # 選択されたインスタンスがあれば接続
    if test -n "$selected_instance"
        echo "Connecting to instance: $selected_instance"
        aws ssm start-session --target $selected_instance
    else
        echo "No instance selected."
    end
end