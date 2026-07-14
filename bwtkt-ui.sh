#!/usr/bin/env bash
# BWTKT shared terminal UI helpers.
# Source this file and set UI_PREFIX to the tool name (default: bwtkt).
# All messages go to stderr so captured stdout stays clean.
# Colors only when stderr is a tty and NO_COLOR is unset.

if [[ -t 2 && -z "${NO_COLOR:-}" ]] && command -v tput &>/dev/null; then
	_ui_bold=$(tput bold 2>/dev/null)
	_ui_reset=$(tput sgr0 2>/dev/null)
	_ui_red=$(tput setaf 1 2>/dev/null)
	_ui_green=$(tput setaf 2 2>/dev/null)
	_ui_yellow=$(tput setaf 3 2>/dev/null)
	_ui_cyan=$(tput setaf 6 2>/dev/null)
else
	_ui_bold="" _ui_reset="" _ui_red="" _ui_green="" _ui_yellow="" _ui_cyan=""
fi

_ui_tag() { printf '%s' "${_ui_cyan}${UI_PREFIX:-bwtkt} ▸${_ui_reset}"; }
ui_info() { echo >&2 "$(_ui_tag) $*"; }
ui_ok()   { echo >&2 "${_ui_green}✓${_ui_reset} $*"; }
ui_warn() { echo >&2 "${_ui_yellow}!${_ui_reset} $*"; }
ui_err()  { echo >&2 "${_ui_red}✗${_ui_reset} $*"; }

# ui_confirm "question" -> 0 on yes (default), 1 on no
ui_confirm() {
	local reply
	while true; do
		read -r -p "$(_ui_tag) $* ${_ui_bold}[Y/n]${_ui_reset} " reply < /dev/tty || return 1
		case "$reply" in
			""|[Yy]) return 0 ;;
			[Nn]) return 1 ;;
		esac
	done
}
