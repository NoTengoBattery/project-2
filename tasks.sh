#!/bin/bash
# If you feel the need to criticize this script, please note that it
# is an ad-hoc solution for an ad-hoc problem with little to no
# scalability.

if [ -z "$BASH_VERSION" -a -z "$ZSH_VERSION" ]; then
  echo "Please use a BASH-like shell to run this script."
  exit 1
fi
if [ ! -e .git/ ]; then
  echo "Please run this script inside the root folder of a git project."
  exit 1
fi

# The following environment variables modify the script's behavior
readonly YES=yes
readonly NO=no
RUN_GULP=${RUN_GULP:-$YES}
RUN_GULP_STYLES=${RUN_GULP_STYLES:-$YES}
RUN_HINT=${RUN_HINT:-$YES}
RUN_STYLELINT=${RUN_STYLELINT:-$YES}
STYLELINT_MATCH_PATTERN=${STYLELINT_MATCH_PATTERN:-'src/**/*.{css,scss,less} !**/{built,build}/**'}
RUN_LHCI=${RUN_LHCI:-$NO}
RUN_SASS=${RUN_SASS:-$YES}
SASS_BUILT=${SASS_BUILT:-'src/built'}
SASS_SOURCE=${SASS_SOURCE:-'src/**/*.{sass,scss}'}
RUN_LESS=${RUN_LESS:-$YES}
LESS_BUILT=${LESS_BUILT:-'src/built'}
LESS_MATCH=${LESS_MATCH:-'src/**/*.less'}

function _which {
  if [[ -n "$ZSH_VERSION" ]]; then
    builtin whence -p "$1"
    setopt extendedglob
  else
    builtin type -P "$1"
    shopt -s extglob
  fi
}

function _print_run {
  local DESC=$1; shift
  printf '\e[7m!~ %s (\e[4m%s\e[24m)\e[27m\r\n' "Running command '$*'" "$DESC"
  "$@"
  printf '\e[7m!! %s: \e[4m%s\e[24m\e[27m\r\n' "Exit code" "$?"
  printf '\e[7m!+ %s (\e[4m%s\e[24m)\e[27m\r\n' "Done running command '$*'" "$DESC"
}

readonly NPX=$(_which npx)
if [ -z "$NPX" ]; then
  echo "Node.js is not installed or not available in the PATH."
  exit 2
fi

clear; clear;

# Run the `sass` preprocessor
if [ "x$RUN_SASS" = "x$YES" ]; then
  eval SASS_SRC=( $SASS_SOURCE )
  for src in "${SASS_SRC[@]}"; do
    dst="${SASS_BUILT}/$(basename "$src").css"
    _print_run "SASS CSS preprocessor" $NPX sass "$src:$dst"
  done
fi

# Run the `less` preprocessor
if [ "x$RUN_LESS" = "x$YES" ]; then
  eval LESS_SRC=( $LESS_MATCH )
  for src in "${LESS_SRC[@]}"; do
    dst="${LESS_BUILT}/$(basename "$src").css"
    _print_run "LESS CSS preprocessor" $NPX lessc "$src" "$dst"
  done
fi

# Run the `stylelint` linter
if [ "x$RUN_STYLELINT" = "x$YES" ]; then
  _print_run "Stylelint CSS linter" $NPX stylelint $STYLELINT_MATCH_PATTERN
fi

# Run the gulp tasks
if [ "x$RUN_GULP" = "x$YES" ]; then
  if [ "x$RUN_GULP_STYLES" = "x$YES" ]; then
    _print_run "gulp styles task" $NPX gulp styles
  fi
fi

# Run the `hint` linter
if [ "x$RUN_HINT" = "x$YES" ]; then
  _print_run "webhint HTML linter" $NPX hint "$PWD"
fi

if [ "x$RUN_LHCI" = "x$YES" ]; then
  _print_run "Lighthouse web auditor" $NPX lhci autorun --collect.staticDistDir="$PWD"
fi
