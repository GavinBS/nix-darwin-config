function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

set_http_proxy() {
  local port="${1:-10808}"
  local host="${2:-127.0.0.1}"

  export http_proxy="http://$host:$port"
  export https_proxy="http://$host:$port"
  export all_proxy="http://$host:$port"
}

set_socks_proxy() {
  local port="${1:-1080}"
  local host="${2:-127.0.0.1}"

  export http_proxy="socks5h://$host:$port"
  export https_proxy="socks5h://$host:$port"
  export all_proxy="socks5h://$host:$port"
}

unset_proxy() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
}