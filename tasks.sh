#!/bin/bash
# If you feel the need to criticize this script, please note that it
# is an ad-hoc solution for an ad-hoc problem with little to no
# scalability.

if [ -z "$BASH_VERSION" -a -z "$ZSH_VERSION" ]; then
  echo "Please use a BASH-like shell to run this script."
  exit 1
fi
if [ ! -e .rootholder ]; then
  echo "Please run this script inside the root folder of the project."
  exit 1
fi

# The following environment variables modify the script's behavior
readonly YES=yes
RUN_GULP=${RUN_GULP:-$YES}
RUN_GULP_STYLES=${RUN_GULP_STYLES:-$YES}
RUN_HINT=${RUN_HINT:-$YES}
RUN_STYLELINT=${RUN_STYLELINT:-$YES}
STYLELINT_MATCH_PATTERN=${STYLELINT_MATCH_PATTERN:-'**/*.{css,scss}'}
RUN_LHCI=${RUN_LHCI:-$YES}

function _which {
  if [[ -n "$ZSH_VERSION" ]]; then
    builtin whence -p "$1"
  else
    builtin type -P "$1"
  fi
}

function _print_run {
  local DESC=$1; shift
  printf '\e[7m!~ %s (\e[4m%s\e[24m)\e[27m\r\n' "Running command '$*'" "$DESC"
  time "$@"
  printf '\e[7m!+ %s (\e[4m%s\e[24m)\e[27m\r\n' "Done running command '$*'" "$DESC"
}

readonly NPX=$(_which npx)
if [ -z "$NPX" ]; then
  echo "Node.js is not installed or not available in the PATH."
  exit 2
fi

# Run the gulp tasks
if [ "x$RUN_GULP" = "x$YES" ]; then
  if [ "x$RUN_GULP_STYLES" = "x$YES" ]; then
    _print_run "gulp styles task" $NPX gulp styles
  fi
fi

# Run the `hint` linter
if [ "x$RUN_HINT" = "x$YES" ]; then
  _print_run "webhint HTML linter" npx hint "$PWD"
fi

# Run the `stylelint` linter
if [ "x$RUN_STYLELINT" = "x$YES" ]; then
  _print_run "Stylelint CSS linter" npx stylelint $STYLELINT_MATCH_PATTERN
fi

if [ "x$RUN_LHCI" = "x$YES" ]; then
  _print_run "Lighthouse web auditor" npx lhci autorun --collect.staticDistDir="$PWD"
fi
