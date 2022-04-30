#!/bin/bash

path () {
  local -r version=0.1.0

  # Each path components.
  local -a paths=()
  IFS=: read -r -a paths <<<"$PATH"

  case "${1---help}" in
    --version )
      echo "$version"
      return 0
      ;;
    --help | -h )
      echo -n "\
Descriptions:
  A \$PATH operation utility.

Usages:
  path [subcommand] [subcommand_options] [arguments...]

Subcommands:
  path select [INDEX]...
  path insert [INDEX] [PATH]
  path update [INDEX] [PATH]
  path delete [INDEX]...
  path append [PATH]...
  path prepend [PATH]...

Options:
  -h, --help    Show this message and exit
  --version     Show the version info and exit
"
      return 0
      ;;
    insert | i )
      shift

      local -a args=()
      local unique=0
      local existance=0

      while (( $# )); do
        case "$1" in
          --version )
            echo "$version"
            return 0
            ;;
          -h | --help )
            echo -n "\
Descriptions:
  Insert path entries to \$PATH.

  An insert position is just past an INDEX. An INDEX must be an integer. An
  INDEX is interpreted as (n + INDEX), n is the number of elements of \$PATH,
  if it is a negative number. All of arguments behind -- option are interpreted
  as INDEX forcefully.

Usages:
  path insert [--unique] [--existance] [--] [INDEX]...

Options:
  --unique       Skip the operation if the PATH already exists in \$PATH.
  --existance    Skip the operation if the PATH doesn't exist on the filesystem
                 or isn't a directory path.
  -h, --help     Show this message and exit.
  --version      Show version info and exit.
"
            return 0
            ;;
          --unique )
            unique=1
            shift
            ;;
          --existance )
            existance=1
            shift
            ;;
          -- )
            shift

            args+=("$@")
            shift $#
            ;;
          * )
            args+=("$1")
            shift
            ;;
        esac
      done

      local -i n_args="${#args[@]}"
      if (( n_args < 2 )); then
        echo "[path:$LINENO] Too few arguments." >&2
        return 1
      elif (( n_args > 2 )); then
        echo "[path:$LINENO] Too many arguments." >&2
        return 1
      fi

      local index=${args[0]}
      if ! [[ $index =~ ^(0|-?[1-9][0-9]*)$ ]]; then
        echo "[path:$LINENO] The first argument must be an integer: $index." >&2
        return 1
      fi

      if (( index < 0 )); then
        index=$(( ${#paths[@]} + index ))
      fi

      if ! (( index >= 0 && index < ${#paths[@]} )); then
        echo "[path:$LINENO] Index out of range: ${args[0]}." >&2
        return 1
      fi

      local path=${args[1]}
      if ! [[ -d $path ]]; then
        echo "[path:$LINENO] Non existance directory path: $path." >&2
        return 1
      fi

      if [[ :$PATH: == *:$path:* ]]; then
        echo "[path:$LINENO] A duplicate path entry: $path." >&2
        return 1
      fi

      local -a new_paths=()
      for i in "${!paths[@]}"; do
        if (( i == index )); then
          new_paths+=("$path")
        fi

        new_paths+=("${paths[$i]}")
      done

      PATH=$(IFS=:; echo -n "${new_paths[*]}")
      ;;
    update | u )
      shift

      local -a args=()
      local -i unique=0
      local -i existance=0

      while (( $# )); do
        case "$1" in
          --version )
            echo "$version"
            return 0
            ;;
          -h | --help )
            echo -n "\
Descriptions:
  Update path entries of \$PATH.

  An INDEX must be an integer. A negative INDEX is interpreted as (n + INDEX),
  n is the number of elements of \$PATH. All of optioons behind -- option are
  just arguments.

Usages:
  path update [--unique] [--existance] [--] INDEX VALUE

Options:
  --unique       Skip the operation if the PATH already exists in \$PATH.
  --existance    Skip the operation if the PATH doesn't exist on the filesystem.
  -h, --help     Show this message and exit.
  --version      Show version info and exit.
"
            return 0
            ;;
          --unique )
            unique=1
            shift
            ;;
          --existance )
            existance=1
            shift
            ;;
          -- )
            shift
            args+=("$@")
            shift $#
            ;;
          * )
            args+=("$1")
            shift
            ;;
        esac
      done

      local -i n_args=${#args[@]}
      if (( n_args < 2 )); then
        echo "[path:$LINENO] Too few arguments." >&2
        return 1
      elif (( n_args > 2 )); then
        echo "[path:$LINENO] Too many arguments." >&2
        return 1
      fi

      local index=${args[0]}
      if ! [[ $index =~ 0|-?[1-9][0-9]* ]]; then
        echo "[path:$LINENO] The first argument must be an integer: $index." >&2
        return 1
      fi

      if (( index < 0 )); then
        index=$(( ${#paths[@]} + index ))
      fi
      if ! (( index >= 0 && index < ${#paths[@]} )); then
        echo "[path:$LINENO] Index out of range: ${args[0]}." >&2
        return 1
      fi

      local -r path=${args[1]}
      if (( existance )) && [[ ! -d $path ]]; then
        echo "[path:$LINENO] A non existance directory path: $path." >&2
        return 1
      fi

      if (( unique )) && [[ :$PATH: == *:$path:* ]]; then
        echo "[path:$LINENO] A duplicate path entry: $path." >&2
        return 1
      fi

      local -a new_paths=()
      for i in "${!paths[@]}"; do
        if (( i == index )); then
          new_paths+=("${args[1]}")
        else
          new_paths+=("${paths[$i]}")
        fi
      done

      PATH=$(IFS=:; echo -n "${new_paths[*]}")
      ;;
    append | a | prepend | p )
      subcommand=$1
      shift

      local -a args

      local mode=normal
      local existance=0

      while (( $# )); do
        case "$1" in
          --version )
            echo "$version"
            return
            ;;
          --help | -h )
            case "$subcommand" in
              append | a )
                subcommand=append
                description=Append
                ;;
              prepend | p )
                subcommand=prepend
                description=Prepend
                ;;
              * )
                echo "[path:$LINENO] An unknown subcommand: $subcommand (Unreachable)." >&2
                return 1
                ;;
            esac

            printf "\
Descriptions:
  %s paths to \$PATH.

  All of options behind -- option are interpreted as just arguments.

Usages:
  path %s [--unique] [--unique-reorder] [--existance] [--] [PATH]...

Options:
  --unique          Skip the operation if the PATH already exists in \$PATH.
  --unique-reorder  First, remove the same values in \$PATH, and then run the
                    operations. This behavior is similar to 'typeset -U'.
  --existance       Skip the operation if the PATH doesn't exist on the
                    filesystem.
  -h, --help        Show this message and exit.
  --version         Show version info and exit.
" "$description" "$subcommand"
            return
            ;;
          --unique )
            mode=unique
            shift
            ;;
          --unique-reorder )
            mode=unique_reorder
            shift
            ;;
          --existance )
            existance=1
            shift
            ;;
          -- )
            shift
            args+=("$@")
            shift $#
            ;;
          -* )
            echo "[path:$LINENO] An invalid option: $1."
            return 1
            ;;
          * )
            args+=("$1")
            shift
            ;;
        esac
      done

      local NEW_PATH=$PATH

      for arg in "${args[@]}"; do
        if (( existance )) && ! [[ -d $arg ]]; then
          continue
        fi

        if [[ $mode == unique && :$NEW_PATH: == *:$arg:* ]]; then
          continue
        fi

        if [[ $mode == unique_reorder ]]; then
          NEW_PATH=:$NEW_PATH:
          NEW_PATH=${NEW_PATH//:$arg:/:}
          NEW_PATH=${NEW_PATH:1:${#NEW_PATH} - 2}
        fi

        case "$subcommand" in
          append | a )
            NEW_PATH+=${NEW_PATH:+:}$arg
            ;;
          prepend | p )
            NEW_PATH=$arg${NEW_PATH:+:}$NEW_PATH
            ;;
          * )
            echo "[path:$LINENO] An unknown subcommand: $subcommand (Unreachable)." >&2
            return 1
            ;;
        esac
      done

      PATH=$NEW_PATH
      ;;
    select | s | delete | d )
      subcommand=$1
      shift

      local -a args=()

      while (( $# )); do
        case "$1" in
          --version )
            echo "$version"
            return 0
            ;;
          --help | -h )
            case "$subcommand" in
              select | s )
                subcommand=select
                description=Select
                ;;
              delete | d )
                subcommand=delete
                description=Delete
                ;;
              * )
                echo "[path:$LINENO] An unknown subcommand: $subcommand (Unreachable)." >&2
                return 1
                ;;
            esac

            printf "\
Descriptions:
  %s paths from \$PATH by indices.

  An INDEX must be an integer. A negative INDEX is interpreted as (n - INDEX),
  n is the number of elements of \$PATH. The INDEX can be also a range format
  such as '0..2'. Ranges are inclusive. For example, that range is interpreted
  as '0 1 2'.

Usages:
  path %s [INDEX]...

Options:
  -h, --help    Show this message and exit.
  --version     Show version info and exit.
" "$description" "$subcommand"
            return 0
            ;;
          -- )
            shift

            args+=("$@")
            shift $#
            ;;
          * )
            args+=("$1")
            shift
            ;;
        esac
      done

      local -a indices=()

      for arg in "${args[@]}"; do
        if [[ $arg =~ ^(0|-?[1-9][0-9]*)$ ]]; then
          local i=$arg

          if (( i < 0 )); then
            i=$(( ${#paths[@]} + i ))
          fi

          if (( i >= 0 && i < ${#paths[@]} )); then
            indices+=("$i")
          else
            echo "[path:$LINENO] Index out of range: $arg." >&2
            return 1
          fi
        elif [[ $arg =~ ^(0|[1-9][0-9]*)..(0|-?[1-9][0-9]*)$ ]]; then
          local -i start=${BASH_REMATCH[1]}
          local -i end=${BASH_REMATCH[2]}

          if (( end < 0 )); then
            end=$(( ${#paths[@]} + end ))
          fi

          while (( start <= end )); do
            if (( start >= 0 && start <= ${#paths[@]} )); then
              indices+=($(( start++ )))
            else
              echo "[path:$LINENO] Index out of range: $arg." >&2
              return 1
            fi
          done
        fi
      done

      case "$subcommand" in
        select | s )
          for i in "${indices[@]}"; do
            echo "${paths[$i]}"
          done
          ;;
        delete | d )
          local -a selections=()
          for i in "${indices[@]}"; do
            selections[$i]=0
          done

          local -a new_paths=()
          for i in "${!paths[@]}"; do
            if (( ${selections[$i]:-1} )); then
              new_paths+=("${paths[$i]}")
            fi
          done

          PATH="$(IFS=:; echo -n "${new_paths[*]}")"
          ;;
        * )
          echo "[path:$LINENO] An unknown subcommand: $1." >&2
          return 1
          ;;
      esac
      ;;
    * )
      echo "[path:$LINENO] An unknown subcommand: $1." >&2
      return 1
      ;;
  esac
}
