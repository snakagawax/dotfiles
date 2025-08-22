# Defined in /Users/nakagawa.shota/.config/fish/functions/fish_prompt.fish @ line 1272
function fish_prompt --description 'bobthefish, a fish theme optimized for awesome'
    # Save the last status for later (do this before anything else)
    set -l last_status $status

    # Use a simple prompt on dumb terminals.
    if [ "$TERM" = 'dumb' ]
        echo '> '
        return
    end

    __bobthefish_glyphs
    __bobthefish_colors $theme_color_scheme

    type -q bobthefish_colors
    and bobthefish_colors

    # Start each line with a blank slate
    set -l __bobthefish_current_bg

    set -l real_pwd (__bobthefish_pwd)

    # Status flags and input mode
    __bobthefish_prompt_status $last_status

    # User / hostname info
    __bobthefish_prompt_user

    # Screen
    __bobthefish_prompt_screen

    # Containers and VMs
    __bobthefish_prompt_vagrant
    __bobthefish_prompt_docker
    __bobthefish_prompt_k8s_context

    # Cloud Tools
    __bobthefish_prompt_aws_vault_profile

    # Virtual environments
    __bobthefish_prompt_nix
    __bobthefish_prompt_desk
    __bobthefish_prompt_rubies
    __bobthefish_prompt_golang $real_pwd
    __bobthefish_prompt_virtualfish
    __bobthefish_prompt_virtualgo
    __bobthefish_prompt_node


    # VCS
    set -l git_root_dir (__bobthefish_git_project_dir $real_pwd)
    set -l hg_root_dir (__bobthefish_hg_project_dir $real_pwd)
    set -l fossil_root_dir (__bobthefish_fossil_project_dir $real_pwd)

    # only show the closest parent
    switch (__bobthefish_closest_parent "$git_root_dir" "$hg_root_dir" "$fossil_root_dir")
        case ''
            __bobthefish_prompt_dir $real_pwd
        case "$git_root_dir"
            __bobthefish_prompt_git $git_root_dir $real_pwd
        case "$hg_root_dir"
            __bobthefish_prompt_hg $hg_root_dir $real_pwd
        case "$fossil_root_dir"
            __bobthefish_prompt_fossil $fossil_root_dir $real_pwd
    end

    __bobthefish_finish_segments
end
