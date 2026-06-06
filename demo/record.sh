#!/usr/bin/env bash
set -e

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$DEMO_DIR/project"
CAST="$DEMO_DIR/vimdemo.cast"
GIF="$DEMO_DIR/../docs/demo.gif"

COLS=110
ROWS=42
IPY_ROWS=12

# Kill any existing session
tmux kill-session -t vimdemo 2>/dev/null || true

# Write vimrc
cat > /tmp/vimdemo.vimrc <<'EOF'
source ~/.vimrc
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": "default", "target_pane": "vimdemo:0.1"}
let g:slime_dont_ask_default = 1
set shortmess+=aI
set noswapfile
EOF

# Write attach script — session created with explicit size so the split has real height
cat > /tmp/demo_attach.sh <<ATTACH
#!/usr/bin/env bash
tmux new-session -d -s vimdemo -x $COLS -y $((ROWS - 1))
tmux split-window -v -l $IPY_ROWS -t vimdemo
tmux select-pane -t vimdemo:0.0
tmux send-keys -t vimdemo:0.0 "cd $PROJECT_DIR && vim -u /tmp/vimdemo.vimrc mlp.py" Enter
tmux attach-session -t vimdemo
ATTACH
chmod +x /tmp/demo_attach.sh

# Keystroke driver (background)
(
  TARGET="vimdemo:0.0"

  sleep 6

  # ,cp — open IDE (tagbar + editor + file explorer + ctags)
  tmux send-keys -t "$TARGET" ',cp'
  sleep 6

  # C-f — ALEFix (black + isort), then save
  tmux send-keys -t "$TARGET" 'C-f'
  sleep 4
  tmux send-keys -t "$TARGET" ':w' Enter
  sleep 1

  # C-w h — focus tagbar
  tmux send-keys -t "$TARGET" 'C-w' 'h'
  sleep 3

  # C-w l — back to editor
  tmux send-keys -t "$TARGET" 'C-w' 'l'
  sleep 1.5

  # C-w l — focus file explorer
  tmux send-keys -t "$TARGET" 'C-w' 'l'
  sleep 3

  # C-w h — back to editor
  tmux send-keys -t "$TARGET" 'C-w' 'h'
  sleep 1.5

  # \as — start IPython in bottom pane
  tmux send-keys -t "$TARGET" '\as'
  sleep 12

  # \rr — run script in IPython
  tmux send-keys -t "$TARGET" '\rr'
  sleep 20

  # :qa! — quit vim
  tmux send-keys -t "$TARGET" ':qa!' Enter
  sleep 2

  tmux kill-session -t vimdemo 2>/dev/null || true
) &
DRIVER_PID=$!

asciinema rec \
  --cols "$COLS" \
  --rows "$ROWS" \
  --idle-time-limit 3 \
  --overwrite \
  --command "bash /tmp/demo_attach.sh" \
  "$CAST"

wait "$DRIVER_PID" 2>/dev/null || true

agg "$CAST" "$GIF" \
  --font-size 18 \
  --theme monokai

python3 "$DEMO_DIR/annotate.py"

echo "written: $GIF"
