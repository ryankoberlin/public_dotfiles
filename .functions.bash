### Functions for bashrc ###

#: bsdrd @ backs up current kernel, and installs new @ bsdrd [-f file]
function bsdrd() {
    RD_URL="https://ftp.openbsd.org/pub/OpenBSD/snapshots/amd64/bsd.rd"
    if $(! test -t 0); then # Log output if we're not running interactively
        exec 3>&1 4>&2 >>~/.update.log 2>&1
    fi
    case $1 in 
        -f)
            if [[ ${#@} -eq 2 ]]; then
            RD=$2
        else
            return 1
        fi
        ;;
        -h)
        echo "bsdrd [-f file] -d"
        return 0;
        ;;
        -d)
        echo "Downloading from ${RD_URL}"
        pushd ~/Downloads
        wget 2>&1>/dev/null $RD_URL
        popd
        ;;
        *)
        echo "bsdrd [-f file] [-d]"
        return 0
        ;;
    esac
    echo "Backing up..."
    doas mv -v /bsd.rd{,-$(date "+%Y-%m-%d")}
    if [[ -f $RD ]]; then
        echo "Using $RD"
        doas mv -v $RD /bsd.rd
        touch ~/.update
    else
        echo "Using default bsd.rd in ~/Downloads"
        doas mv -v /home/roberlin/Downloads/bsd.rd /bsd.rd
        touch ~/.update
    fi
    _portsupdate
    exec 1>&3 2>&4

}

#: _portsupdate @ Updates ports tree after reboot @ NULL
function _portsupdate() {
    _pushd () { pushd 2>&1>/dev/null $1; }
    _popd () { popd 2>&1>/dev/null $1; }
    CWD=$PWD
    PORT_URL="https://cdn.openbsd.org/pub/OpenBSD/snapshots/ports.tar.gz"
    SIG_URL="https://cdn.openbsd.org/pub/OpenBSD/snapshots/amd64/SHA256.sig"
    if [[ ! -f ~/.updated ]]; then
        echo "No update to perform, exiting"
        return 1
    fi
    echo "Matching ports tree"
    _pushd /tmp
    ftp $PORT_URL
    ftp $SIG_URL
#    popd 2>&1>/dev/null
# We don't have a shasum on -current
#    echo "Running $(signify -Cp /etc/signify/openbsd-$(uname -r | cut -c 1,3)-base.pub -x SHA256.sig ports.tar.gz)"
#    if $(signify -Cp /etc/signify/openbsd-$(uname -r | cut -c 1,3)-base.pub -x SHA256.sig ports.tar.gz); then
#        pushd 2>&1>/dev/null /usr
        echo "Password required:"
        doas echo "Updating"
        _pushd /usr
        if $(doas tar -xzf /tmp/ports.tar.gz); then
            rm -f ~/.updated
            _popd
        else
            echo "tar failed"
            return 1
        fi
        _pushd $CWD
#    else
#        echo "Signature does not match"
#        return 1
#    fi
}

#: lsd @ Lists $DIRSTACK array content @ <lsd> or <lsd -c> to clear stack
function lsd() {
	if [[ $1 == "-c" ]]
		then
	dirs -c
	echo -e "${BLUE}Stack cleared${RESET}"
		else
	dirs -l -v | head -11
	fi
}

#: lsc @ Quickly switch between directories in the stack @ lsc $NUMBER
function lsc() {
	if [[ ${#@} < 1 ]]
			then
		return 1;
			else
		pushd +$1 1>/dev/null
		echo -e "${BLUE}> $PWD${RESET}"
	fi
}

#: cd @ Adds directories to the stack and changes to them @ cd $DIR
function cd() {
	if [[ ${#@} < 1 ]]
		then
		if [[ -d /home/$(whoami) ]]; then
			pushd /home/$(whoami) 1>/dev/null
				else
			pushd ~/ 1>/dev/null
		fi
		else
		if [[ $1 == '-' ]]; then
			pushd 1>/dev/null "$OLDPWD"
		else
			if [[ -d "$1" ]]; then
				pushd "$1" 1>/dev/null
			else
				echo -e "${LIGHTRED}No such file or directory: ${1}${RESET}";
				return 1;
			fi
		fi
	fi
	echo -e "${BLUE}> $PWD${RESET}"
}

#: fnls @ List functions @ fnls $FUNCTION
function fnls() {
	printf "
.TS H
allbox, center, tab(@);
c c c
l l l.
CMD @ Description @ Usage
.TH
.SP
$(grep ^#: ~/.functions.bash | cut -c4-|sort -nk1)
.TE
"|tbl |nroff 2>/dev/null -ms -Tascii|/usr/bin/less -Fdcs
##-Tascii
}

#: fnhelp @ Show help for functions @ fnhelp $FUNCTION
function fnhelp() {
	awk "/^#: ${1}/, /^$/" ~/.functions.bash|less
}

#: fnsearch @ Search functions for term @ fnsearch $TERM
function fnsearch() {
	grep -iE ^\#\:.*${1} ~/.functions.bash|awk -F': ' '{print $2}'|less
}

#: findso @ Locate SO file within /usr/ @ findso libxml.so
function findso() {
	find /usr/ -type f -iname $1 2>&1 |grep -v Permission\ denied
}

#: findext @ Finds files with the specified extension @ findext .ext
function findext() {
	find $PWD -type f -iname \*$1
}

#: epoch @ Convert UNIX epoch time to local time @ epoch 123456789
function epoch() { 
	date -d @"$1"; 
}  

#: lest @ Automatically view most recently edited file in cwd @ lest
function lest() { 
	less $(ls -Aptrc|grep -v \/|tail -1)
}

#: box @ Creates box around text @ box $TEXT
function box() {
perl -se '
	my $x = join(" ", @ARGV);
	$x =~ s/./-/g;
	printf qq(+-$x-+\n| @ARGV |\n+-$x-+\n)
' -- "$@"
}

#: mypath @ Prints $PATH in alpabetical order @ mypath
function mypath() {
	echo $PATH|tr ':' '\n'|sort -nbk 1,2|uniq
}


#: lse @ FTofil - lists entries that match the starname(s) @ lse *
function lse() { 
	sname="$@"
	if [[ -z "${sname}" ]] && sname='* .[!.] .??*'; then
 		${LS_cmd} -Abdl ${sname}
	fi
}

#: lsvnc @ Lists current vnc sessions @ lsvnc
function lsvnc() {
	used=$(ps -aux|awk '/\/usr\/bin\/Xvnc/{print $12, $1}'|sort -nk1.2)
	printf "Used VNC sessions:\n$used\n"
}

#: wi @ FTofil - lists the logged in users sorted by idle time @ wi
function wi() { 
	( who -Hu | head -n 1 | sed -e 's/IDLE /  IDLE/';
	who -u | sed -e '/^\(.\{38\} \)  .  /s//\1 0.00/' \
 	-e '/^\(.\{38\} \) old /s//\124.00/' -e 's/^\(.\{38\} \)/\1 /' -e 's/ (/  (/' |
  	sort -b -k 5.1,5.5 -k 1,1 -k 3,3 -k 4,4 -k 6n,6 ) | ${PAGER:-less};

}

#: uc @ Convert lower case to upper @ uc TEXT
function uc() {
	echo $@ | sed -e 's/\(.*\)/\U\1/'
}

#: lc @ Convert upper case to lower @ lc TEXT
function lc() {
	echo $@ | sed -e 's/\(.*\)/\L\1/'
}

#: beep @ FTofil - rings the bell @ beep
function beep() {
	printf "\007"
}

#: alsp @ FTofil - List aliases that match pattern @ alsp $ALIAS
function alsp() { 
	alias | grep "${1:-'='}" | ${PAGER:-less} 
}

#: als @ List aliases that match pattern (no pager) @ als alias
function als() { 
	alias | grep "${1:-'='}" 
}

#: halp @ Displays basic help info about functions @ halp
function halp() {
perl -se '

## DO NOT USE TABS IN THIS ARRAY 
my @text = (
"EDITOR.......$ENV{EDITOR}",
"VISUAL.......$ENV{VISUAL}",
"PAGER........$ENV{PAGER}",
"TERM.........$ENV{TERM}",
" ",
"fnls.........List all user defined functions",
"fnhelp.......Show help for functions",
"fnsearch.....Search for terms within function list",
"als..........List aliases",
"halp.........This help",
"screencmd....List GNU Screen bindings",
"edpath.......Edit path in ENV",
"reload.......Reloads bashrc and functions",
" ",
"PS process state codes",
"D............uninterruptible sleep \(usually IO\)",
"R............running or runnable \(on run queue\)",
"S............interruptible sleep \(waiting for an event to complete\)",
"T............stopped by job control signal",
"t............stopped by debugger during the tracing",
"W............paging \(not valid since the 2.6.xx kernel\)",
"X............dead \(should never be seen\)",
"Z............defunct \(zombie\) process, terminated but not reaped by its parent",
"<............high-priority \(not nice to other users\)",
"N............low-priority \(nice to other users\)",
"L............has pages locked into memory \(for real-time and custom IO\)",
"s............is a session leader",
"l............is multi-threaded \(using CLONE_THREAD, like NPTL pthreads do\)",
"+............is in the foreground process group",
" ",
"Vim notes:",
"s/\\s*\$//g....Remove trailing whitespace",
" ",
"Awk:",
"FS...........Input Field Separator",
"OFS..........Output Field Separator",
"NF...........Number of fields",
"RS...........Record Separator",
"ORS..........Output Record Separator",
"FILENAME.....Filename",
);
	
print "+------+\n| HALP |\n+------+", "-"x77, "+\n";


foreach (@text) {
	print "|", pack("A84", $_), "|\n";
}
print "+", "-"x84,"+\n"; '
}

#: meeseeks @ monitors PID and rings bell when done @ meeseeks $prog
function meeseeks() {
if pgrep $1 1>/dev/null; then
echo "Can Do!"
(while pgrep 1>/dev/null $1; do
		sleep 10
	done; 
	beep) &
else 
	echo "PID not found for $1"
fi
}

#: aw @ FTofil - Sorted list of logged in users @ aw
function aw() { 
	( who -Hu | head -n 1 | sed -e 's/IDLE / IDLE/';
who -u | sort -b -k 1,1 -k 3,3 -k 4,4 -k 6n,6 ) | ${PAGER:-less}
}

#: lsdir @ List directories in CWD @ lsdir
function lsdir() {
	ls -lahd */ | sed 's|/$||g'
}

#: reload @ Reload bashrc and functions @ reload
function reload() {
	if source ~/.init_bash && source ~/.functions.bash; then
		printf "Reloaded\n"
		else printf "Error"
	fi
}

#: edpath @ Ftofil - edits the PATHvar environment variable @ edpath [PATHvar]
function edpath() {
	pathvar=${1:-PATH};
 	[ -z "$(eval echo \${${pathvar}})" ] && : ${Error:?'Undefined environment variable.'};
 	tmppath=/tmp/$(logname).${pathvar};
 	for dir in $(echo $(eval echo \${${pathvar}}) |
  		sed -e 's,^:,.:,' -e 's,::,:.:,' -e 's,:$,:.,' -e 's,:, ,g'); do
   		echo ${dir};
 		done > ${tmppath}
 	${VISUAL:-emacs} ${tmppath}
 	eval ${pathvar}=$(cat ${tmppath} | tr '\n' ':' | sed -e 's/:$//'); rm -f ${tmppath}*; unset dir pathvar tmppath;
}

#: mkcd @ make directory and immediately cd into it @ mkcd directory
function mkcd() {
	if [[ ${#@} < 1 ]]
			then
		return 1;
			else
		mkdir $1
		cd $1
	fi
}

#: colors @ list all available colors with examples @ colors
function colors() {
	echo -e "
Available colors:

${LIGHTGREEN}\${LIGHTGREEN}${RESET}
${LIGHTRED}\${LIGHTRED}${RESET}
${WHITE}\${WHITE}${RESET}
${RESET}\${RESET}${RESET}
${BLUE}\${BLUE}${RESET}
${YELLOW}\${YELLOW}${RESET}
${PURPLE}\${PURPLE}${RESET}
${CYAN}\${CYAN}${RESET}
${BOLD}\${BOLD}${RESET}
${UNDERLINE}\${UNDERLINE}${RESET}
"
}

#: binary @ convert decimal to binary  @ binary 42
function binary() {
	perl -se '
	sub dec2bin {
	   my $str = sprintf ("%b", @_);
	   return $str;
	}
    print dec2bin($ARGV[0]), "\n";
 ' -- "$@"
}

#: unbinary @ convert binary to decimal @ unbinary 101010
function unbinary() {
	perl -se '
	sub bin2dec {
	   return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
	}
	if ($ARGV[0] !~ /^[0-1]+$/) {
	   print "Enter Binary\n";
	} else {
	 print bin2dec($ARGV[0]), "\n";
	}
	' -- "$@"
}

#: rename @ Removes youtube-dl tags @ rename
function rename() {
    ls -1 *.flac|while read f; do name=$(echo $f | sed 's/\-.*.flac/.flac/g'); mv "$f" "$name"; done
}
