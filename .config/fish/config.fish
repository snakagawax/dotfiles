# === Optimized Fish Configuration ===
# Performance improvements:
# - Lazy loading for heavy tools (pyenv, direnv)
# - Abbreviations instead of aliases where possible
# - Optimized PATH construction
# - Deferred Amazon Q initialization

# === Fast PATH Configuration (no command substitution) ===
set -gx PATH \
    $HOME/bin \
    $HOME/.local/bin \
    $HOME/ghq/github.com/aws-samples/amazon-connect-copy/bin \
    $HOME/.pyenv/bin \
    /opt/homebrew/bin \
    /usr/local/bin \
    $PATH

set -gx fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths

# === Environment Variables ===
set -gx HOMEBREW_CASK_OPTS --appdir=/Applications
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx KUBECONFIG $KUBECONFIG:~/.kube/config
set -gx PYENV_ROOT $HOME/.pyenv
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
# Google Cloud settings (lazy loaded for performance)
set -x GOOGLE_CLOUD_LOCATION "us-central1"
set -x GOOGLE_GENAI_USE_VERTEXAI true
# GOOGLE_CLOUD_PROJECT will be set on first gcloud use

# === Homebrew (lazy load for interactive) ===
if status is-interactive
    # Defer brew shellenv to first prompt
    function __brew_lazy_init --on-event fish_prompt
        eval (/opt/homebrew/bin/brew shellenv)
        functions -e __brew_lazy_init
    end
end

# === Python (pyenv) - Lazy Loading ===
# Create a wrapper that loads pyenv on first use
function pyenv
    # Remove this wrapper function
    functions -e pyenv
    # Load the real pyenv
    status is-login; and pyenv init --path | source
    status is-interactive; and pyenv init - | source
    # Call pyenv with original arguments
    command pyenv $argv
end

# === Clean fish behavior - no abbreviations, minimal aliases ===
if status is-interactive
    # Force removal of all abbreviations to ensure clean fish completion behavior
    abbr -e (abbr -l) 2>/dev/null || true
    
    # Using native fish completion behavior only
    # No custom abbreviations or aliases that interfere with standard fish behavior
end

# === Functions that need to be aliases (keep command name) ===
alias rm='trash'
alias cursor='/Applications/Cursor.app/Contents//MacOS/Cursor'
alias chrome="open -a 'Google Chrome'"
alias sm='bass source ssm-peco.sh'

# === Claude Code Alias (fixed output issues) ===
function ccd -d "Claude Code with clean output"
    claude --dangerously-skip-permissions $argv 2>/dev/null
end

# === Custom Functions ===

function upgrade_aws_cli_v2
    set AWSCLIV2VERSION (aws --version)
    echo "Current version: $AWSCLIV2VERSION"
    echo ""
    curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
    echo ""
    echo "New version: $AWSCLIV2VERSION"
end

# === Fisher Package Manager (check only) ===
if not functions -q fisher
    echo "Fisher not installed. Run: curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/install.fish | source && fisher install jorgebucaran/fisher"
end

# === Key Bindings ===
function fish_user_key_bindings
    fish_default_key_bindings
    
    # fzf.fish manual setup (avoid automatic conf.d conflicts)
    if functions -q fzf_configure_bindings
        # Setup fzf global variable for search command
        if not set -q _fzf_search_vars_command
            set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'
        end
        
        # Configure safe fzf bindings - use defaults to avoid errors
        # Alt+F(directory), Alt+L(git_log), Alt+S(git_status), Ctrl+R(history), Alt+P(processes), Ctrl+V(variables)
        fzf_configure_bindings 2>/dev/null || echo "fzf bindings failed, continuing..." >&2
    end
    
    # Custom bindings (ghq/peco) - now Ctrl+G is free for ghq
    # Note: __ghq_repository_search is already bound to Ctrl+G by fzf-ghq plugin
    bind \cs peco_select_ssm_instance       # Ctrl+S for SSM
    
    # Force tab completion (override any other bindings)
    bind \t complete
    bind \e\t complete-and-search
end

# === Theme Configuration ===
# Choose your prompt: 'starship' or 'bobthefish'
set -g FISH_PROMPT_THEME 'starship'  # Change this to switch themes

if test "$FISH_PROMPT_THEME" = "starship"
    # Starship configuration (超高速Rust製プロンプト)
    if command -q starship
        starship init fish | source
    end
else
    # Bobthefish configuration (従来のテーマ)
    set -g theme_display_git_master_branch yes
    set -g theme_title_display_process yes
    set -g theme_title_display_user yes
    set -g theme_display_date no
    set -g theme_display_cmd_duration no
    set -g theme_color_scheme dracula
end

set -g fish_greeting ""  # Disable greeting for faster startup

# Disable fish autosuggestions (auto-completion based on history)
set -g fish_autosuggestion_enabled 0

# === Lazy Loading for Heavy Tools ===

# direnv - load on first cd or prompt
if command -q direnv
    function __direnv_lazy_init --on-event fish_prompt
        direnv hook fish | source
        set -x DIRENV_WARN_TIMEOUT 60s
        functions -e __direnv_lazy_init
    end
end

# AWS CLI completion - lazy load
function aws
    # Remove wrapper
    functions -e aws
    # Setup completion
    complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
    # Call aws
    command aws $argv
end

# Google Cloud CLI - lazy load
function gcloud
    # Remove wrapper
    functions -e gcloud
    # Set project on first use
    if not set -q GOOGLE_CLOUD_PROJECT
        set -gx GOOGLE_CLOUD_PROJECT (command gcloud config get-value project 2>/dev/null)
    end
    # Call gcloud
    command gcloud $argv
end

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/nakagawa.shota/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Google Cloud SDK path (lazy load for performance)
if status is-interactive
    function __gcloud_path_init --on-event fish_prompt
        set -l gcloud_path '/Users/nakagawa.shota/Downloads/google-cloud-sdk/path.fish.inc'
        if test -f "$gcloud_path"
            source "$gcloud_path"
        end
        functions -e __gcloud_path_init
    end
end
