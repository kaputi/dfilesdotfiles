#!/bin/bash
##https://github.com/lagerspetz/linux-stuff/
## saferm.sh
## Safely remove files, moving them to GNOME/KDE trash instead of deleting.
## Made by Eemil Lagerspetz
## Login   <vermind@drache>
##
## Started on  Mon Aug 11 22:00:58 2008 Eemil Lagerspetz
## Last update Sat Aug 16 23:49:18 2008 Eemil Lagerspetz
##

version="1.17";

## flags (change these to change default behaviour)
recursive="" # do not recurse into directories by default
verbose="true" # set verbose by default for inexperienced users.
force="" #disallow deleting special files by default
unsafe="" # do not behave like regular rm by default

## possible flags (recursive, verbose, force, unsafe)
# don't touch this unless you want to create/destroy flags
flaglist="r v f u q"

# Colours
blue='\e[1;34m'
red='\e[1;31m'
norm='\e[0m'

## trash: `gio trash` (glib2) picks the trash dir, writes the .trashinfo
## and renames on name clashes, per the freedesktop trash spec.

usagemessage() {
	echo -e "This is ${blue}saferm.sh$norm $version. Moves files to the freedesktop trash with gio trash.
    Files on other drives go to that drive's trash; files that cannot be trashed (e.g. on tmpfs) get an unsafe-delete prompt.
    Allows unsafe (regular rm) delete. Handles symbolic link deletion.
    Does not complain about different user any more.\n";
	echo -e "Usage: ${blue}/path/to/saferm.sh$norm [${blue}OPTIONS$norm] [$blue--$norm] ${blue}files and dirs to safely remove$norm"
	echo -e "${blue}OPTIONS$norm:"
	echo -e "$blue-r$norm, $blue--recursive$norm  allows recursively removing directories."
	echo -e "$blue-f$norm, $blue--force$norm      Allow deleting special files (devices, ...)."
	echo -e "$blue-u$norm, $blue--unsafe$norm     Unsafe mode, bypass trash and delete files permanently."
	echo -e "$blue-v$norm, $blue--verbose$norm    Verbose, prints more messages. Default in this version."
	echo -e "$blue-q$norm, $blue--quiet$norm      Quiet mode. Opposite of verbose."
	echo "";
}

setflags() {
    for k in $flaglist; do
	reduced=$( echo "$1" | sed "s/$k//" )
	if [ "$reduced" != "$1" ]; then
	    flags_set="$flags_set $k"
	fi
    done
  for k in $flags_set; do
	if [ "$k" == "v" ]; then
	    verbose="true"
	elif [ "$k" == "r" ]; then
	    recursive="true"
	elif [ "$k" == "f" ]; then
	    force="true"
	elif [ "$k" == "u" ]; then
	    unsafe="true"
	elif [ "$k" == "q" ]; then
    unset verbose
	fi
  done
}

performdelete() {
  # "delete" = move to trash
  if [ -n "$unsafe" ]; then
    if [ -n "$verbose" ]; then echo -e "Deleting $red$1$norm"; fi
    #UNSAFE: permanently remove files.
    rm -rf -- "$1"
  else
    if [ -n "$verbose" ]; then echo -e "Moving $blue$1$norm to ${red}trash$norm"; fi
    # gio has no "--" and reads "a:b" as a URI, so relative paths need "./"
    case "$1" in
      /*) gio trash "$1" ;;
      *)  gio trash "./$1" ;;
    esac
  fi
}

complain() {
  msg=""
  if [ ! -e "$1" -a ! -L "$1" ]; then # does not exist
    msg="File does not exist:"
	elif [ ! -w "$(dirname -- "$1")" ]; then # can't remove entries from its directory
    msg="Parent directory is not writable:"
	elif [ ! -f "$1" -a ! -d "$1" -a -z "$force" ]; then # Special or sth else.
    	msg="Is not a regular file or directory (and -f not specified):"
	elif [ -f "$1" ]; then # is a file
    act="true" # operate on files by default
	elif [ -d "$1" -a -n "$recursive" ]; then # is a directory and recursive is enabled
    act="true"
	elif [ -d "$1" -a -z "${recursive}" ]; then
		msg="Is a directory (and -r not specified):"
	else
		# not file or dir. This branch should not be reached.
		msg="No such file or directory:"
	fi
}

asknobackup() {
  unset answer
  until [ "$answer" == "y" -o "$answer" == "n" ]; do
    echo -e "$blue$1$norm could not be moved to trash. Unsafe delete (y/n)?" >&2
    # no terminal to answer (xargs, scripts): take it as "n" instead of looping
    read -n 1 answer || answer="n"
  done
  echo >&2
  ret=1
  if [ "$answer" == "y" ]; then
    unsafe="yes"
    performdelete "$1"
    ret=$?
    # Reset temporary unsafe flag
    unset unsafe
  fi
  unset answer
  return $ret
}

deletefiles() {
  for k in "$@"; do
    fdesc="$blue$k$norm";
    complain "${k}"
    if [ -n "$msg" ]; then
      echo -e "$msg $fdesc." >&2
      status=1
      continue
    fi
    performdelete "${k}"
    ret=$?
    # trash failed: offer a permanent delete (not when -u already ran rm)
    if [ "$ret" -ne 0 ] && [ -z "$unsafe" ]; then
      asknobackup "${k}"
      ret=$?
    fi
    if [ "$ret" -ne 0 ]; then
      echo -e "Not removed: $fdesc." >&2
      status=1
    fi
  done
}

# find out which flags were given
afteropts=""; # boolean for end-of-options reached
for k in "$@"; do
  # if starts with dash and before end of options marker (--)
  if [[ $k == -* && -z $afteropts ]]; then
    if [ "$k" == "--" ]; then # if end of options marker
      afteropts="true"
    elif [[ $k == --* ]]; then # long option: match the whole word, not its letters
      case "$k" in
        --recursive) setflags "r" ;;
        --force)     setflags "f" ;;
        --unsafe)    setflags "u" ;;
        --verbose)   setflags "v" ;;
        --quiet)     setflags "q" ;;
        --help)      usagemessage; exit 0 ;;
        *) echo "Unknown option: $k (see --help)" >&2; exit 1 ;;
      esac
    else # option(s)
      setflags "$k" # set flags
    fi
  else # not starting with dash, or after end-of-opts
    files[++i]="$k"
  fi
done

if [ -z "${files[1]}" ]; then # no parameters?
	usagemessage # tell them how to use this
	exit 0;
fi

# do the work
status=0
deletefiles "${files[@]}"
exit $status
