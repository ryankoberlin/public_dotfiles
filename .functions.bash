### Functions for bashrc ###

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

#: checkcert @ Leverage OpenSSL to examine cert details @ checkcert www.google.com
function checkcert() {
	openssl s_client -showcerts -connect ${1}:443 | ${PAGER:-less}
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
        if [[ ${#@} -lt 1 ]]
                then
                if [[ -d /home/$(whoami) ]]; then
                        pushd /home/"$(whoami)" 1>/dev/null || return 2
                                else
                        pushd ~/ 1>/dev/null || exit
                fi
                else
                if [[ $1 == '-' ]]; then
                        pushd 1>/dev/null "$OLDPWD" || return 2
                else
                        if [[ -d $1 ]]; then
                                pushd "$1" 1>/dev/null || return 2
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
$(grep ^#:\ ${1} ~/.functions.bash | cut -c4-|sort -nk1)
.TE
"|tbl |nroff 2>/dev/null -ms -Tascii|/usr/bin/less -Fdcs
##-Tascii
}

#: p5lib @ Sets PERL5LIB to /home/$(whoami)/runjob/lib @ p5lib [-u]
function p5lib() {
	case $1 in
		-unset|-u)
		export PERL5LIB=''
		;;
		-display|-d)
		echo $PERL5LIB
		;;
		-set|-s)
		export PERL5LIB=/home/$(whoami)/cvs/runjob/lib
		;;
		*)
		echo "Usage: p5lib -s[et] -d[isplay] -u[nset]"
		;;
	esac
}

#: fnhelp @ Show help for functions @ fnhelp $FUNCTION
function fnhelp() {
	if [[ -e /home/$(whoami)/git/Scripts/${1} ]]; then
		view $(which ${1})
	else	
		awk "/^#: ${1}/, /^$/" ~/.functions.bash|less
	fi
}

#: fnsearch @ Search functions for term @ fnsearch $TERM
function fnsearch() {
	grep -iE ^\#\:.*${1} ~/.functions.bash|awk -F': ' '{print $2}'|less
}

#: lmstat @ License checking @ lmstat $LICSERVER
function lmstat {
	/apps/ansys/v140/fluent/bin/lmstat -a -c $1
}

#: findapp @ Locate app within /apps/ dir @ findapp $APP
function findapp () { 
	find /apps/ -maxdepth 2 -type d -iname \*$1\* 2>&1 |grep -v Permission\ denied
}

#: findso @ Locate SO file within /usr/ @ findso libxml.so
function findso() {
	find /usr/ -type f -iname $1 2>&1 |grep -v Permission\ denied
}

#: findext @ Finds files with the specified extension @ findext .ext
function findext() {
	find $PWD -type f -iname \*$1
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

#: nodestat @ Display basic information about the current node @ nodestat
function nodestat() {
mem_total=$(free -g|awk '/Mem:/{print $2}')
mem_used=$(free -g|awk '/Mem:/{print $3}')
mem_free=$(($mem_total - $mem_used))
ncpus=$(nproc)
cpu_type=$(grep model\ name /proc/cpuinfo|cut -d' ' -f4-|head -n1)
ip=$(ip a 2>/dev/null |awk '/inet\ 19\./{print $2, $NF}')
if [[ -f /etc/SuSE-release ]]; then
	os=$(grep SUSE /etc/SuSE-release)
	else
	os=$(cat /etc/redhat-release)
fi
kernel=$(uname -r)
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
jobs=$(fqmgr -n $(hostname)|grep jobs  |tr ',' '\n'|cut -d\/ -f1|awk '{print $NF}'|uniq -c|awk '{print $1"*"$2}')
building=$(cat /etc/conf/BUILDING)
printf $LIGHTGREEN
printf "
.TS
allbox, tab(*), center;
cB s.
Nodestat
.T&
cB s.
::General::
.T&
l l.
Node:*$HOSTNAME
IP:*$ip
LOC:*$building
OS:*$os
Kernel:*$kernel
Load:*$load
.T&
cB s.
::CPU::
.T&
l l.
Cores:*$ncpus
Type:*$cpu_type
.T&
cB s.
::Memory::
.T&
l l.
Total:*$mem_total Gb
Used:*$mem_used Gb 
Free:*$mem_free Gb 
.T&
cB s.
::Jobs Running::
.T&
l l.
CPUs*Job ID
$jobs
.TE
"|tbl|nroff|more -sp
printf $WHITE
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
	who -u | sed -e '/^\(.\{38\} \)  .  /home//\1 0.00/' \
 	-e '/^\(.\{38\} \) old /home//\124.00/' -e 's/^\(.\{38\} \)/\1 /' -e 's/ (/  (/' |
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
"dib..........Delete block between braces",
"dtX..........Delete until symbol 'X'",
"daX..........Delete until (and) symbol 'X'",
"zf{action}...Create fold",
"zfa{symbol}..Create fold until next match of {symbol}",
"za...........Toggle fold",
"zd...........Delete fold",
"zR...........Unfold all folds",
"zM...........Fold all folds",
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

#: view @ Open a file in Vim (RO) @ view ~/.bashrc
function view() { 
if [[ ${#@} -ne 0 ]]; then
	if [[ -e $1 ]]; then
		vim -nM -c "set nonumber" -c "set foldcolumn=0" -c "set foldmethod=manual" -c "noremap q :exit <CR>" $1
	else 
		echo "No such file: $1"
	fi
else
	return 1
fi
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
	if [[ $1 ]]; then
		dir=$1
	else 
		dir="."
	fi
	find $dir -maxdepth 1 -type d|sed 's|\./||g;'| sed 1d|sort
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

#: lsmyvnc @ show all of my VNC sessions on all login nodes @ lsmyvnc
function lsmyvnc() {

	ME=$(whoami)

	login_nodes=" "
	for PID in $(ls /home/${ME}/.vnc/*.pid|cut -d\: -f1|uniq); 
	do 
	login_nodes+="$(basename $PID) "
	done

    echo "VNC Sessions on all login servers:";
    for i in $login_nodes;
    do
        printf "${i}:\n";
        ls /home/${ME}/.vnc/${i}*.pid 2>&1 | grep -Po "(?<=\:).*(?=\.)" | grep -v cannot\ access;
    done
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

#: coltest @ test number of columns because Cygwin is dumb @ coltest
function coltest() {
	perl -e '
	print qq(Columns reported: \001\033[1;32m\002$ENV{COLUMNS}\001\033[0;00m\002\nLines should not exceed terminal width\n);
	print "-" x $ENV{COLUMNS};
	print "\n";
'
}

#: qlist @ Query fqstat and parse number of jobs in states Q, D, R @ qlist
function qlist() {
dc=0 
qc=0
rc=0 
if [[ ${#@} > 1 ]]; then
	echo "qlist function takes no arguments"
	return 127
fi
while read LINE; 
	do 
		case $LINE in
		   Q) (( qc+=1 )) ;;
		   D) (( dc+=1 )) ;;
		   R) (( rc+=1 )) ;;
		esac
	done < <(fqstat -u all | awk '{if ($5 ~ "(Q|R|D)") { print $5 } }')
echo -ne "Running:\t$rc\nQueued:\t\t$qc\nDep:\t\t$dc\n\n";
}

#: compare @ compare file across hosts @ compare [HOST] [FILE]
function compare() {
ID=$(whoami)
FILE=$(realpath $2)
RHOST=$1
RFILE=$(ssh -q ${ID}@${RHOST} md5sum ${FILE}|awk '{print $1}')
LFILE=$(md5sum ${FILE}|awk '{print $1}')
if [[ ${#@} != 2 ]]; then
        printf "Usage: $0 [FILE] [Remote Host]\n"
        exit
fi
if [[ ! -e $FILE ]]; then
        printf "ERR: $FILE not found\n"
        exit
    else
        printf "\nComparing $FILE on ${YELLOW}${HOSTNAME}${RESET} and ${YELLOW}${RHOST}${YELLOW}\n\n"
        if [[ $RFILE == $LFILE ]]; then
                printf "${YELLOW}Local file checksum:\n${LFILE}\n${RESET}"
                printf "${LIGHTGREEN}Remote file checksum:\n${RFILE}\n${RESET}\n"
        else
                printf "${YELLOW}Local file checksum:\n${LFILE}\n${RESET}"
                printf "${LIGHTRED}Remote file checksum:\n${RFILE}\n${RESET}\n"
        fi
fi
}

#: cpustat @ Show core usage for all jobs @ cpustat
function cpustat() {
	nodes=$(fqstat |awk '{if ($4 ~ /[0-9]{1,}/) { print $4 } }')
	num_jobs=$(echo "$nodes" | wc -l)
	num_cpus=$(echo "$nodes" | paste -sd+ | bc)
	echo -e "$num_jobs jobs\n${num_cpus} cores"
}

#: getumask @ Looks up umask for user from LDAP @ getumask $username
function getumask() {
	test ${#@} == 1 || return 1
	ldapsearch -xLLL uid=${1} gecos | grep -Eo 'umask=[0-7]{3}'
}

#: fld @ Add lines and fold text file @ fld $FILE
function fld() {
	FILE="$1"
	OUTFILE=$(basename ${FILE}.fld)
	if [[ ! -f "$FILE" ]]; then
		echo "$FILE not found!"
		return 1
	fi
	nl -ba "$FILE" |fold -sc100 >> /home/$(whoami)/Documents/Print/${OUTFILE}
}

#: sehelp @ Show SELinux help notes @ sehelp
function sehelp() {
	echo "
	ausearch -m avc -ts today 	# View denials for today
	ausearch -m avc 			# View all denials
	ausearch -m avc -c httpd 	# View denails for specific comm
	
	aureport -a					# Produces summary report of all audit system logs
	
	restorecon -R -v $DIR/		# Restore context of directory (recursive)
	"
}

#: bup @ Backup file @ bup FILE
function bup() {
	declare -a FILES
	FILES=${@}
	TIME=$(date +%H%M.%m%d%y)
	for f in ${FILES[*]}; 
		do mv "$f" "${f}.bup.${TIME}"
	done
	}

#: killnast @ Kill all running nastran processes @ killnast
function killnast() {
	ps faux|grep -i [n]astran|awk '{print $2}'| \
	while read PID; 
		do 
			kill -9 $PID
		done
}

#: deploy @ Create run directories for Nastran testing @ create $RUN $ZIP
function deploy() {
	if [[ ${#@} != 1 ]]; then
		echo "deploy takes one argument"
		return 1
	fi
	ZIP=$1
	ZIPDIR=/home/$(whoami)/models/NASTRAN/tars
	RUNDIR=/home/$(whoami)/models/NASTRAN/NUMA
	OLD=$(basename $(ls -1vd ${RUNDIR}/run* | tail -n1) | cut -c4-)
	NEW=$(( $OLD+1 ))
	RUN=run${NEW}
	mkdir -p ${RUNDIR}/${RUN}/{0..3}
	echo "${RUNDIR}/${RUN}:"
	for i in ${RUNDIR}/${RUN}/{0..3};
		do pushd 2>&1 > /dev/null $i;
		echo "${NEW},$(basename $i)"
			tar -xzvf ${ZIPDIR}/${ZIP} 1>/dev/null;
		popd 2>&1 > /dev/null;
	done;
}

#: _deploy @ Tab completion for deploy() @ NULL
function _deploy() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    local zips=$(for f in $(ls -1 /home/$(whoami)/models/NASTRAN/tars/*.tar.gz); do echo $(basename ${f}); done)
    COMPREPLY=($(compgen -W "${zips}" $cur))
}

#: cdl @ cd to most recently created directory @ cdl
function cdl() {
	DIR=$(ls -rtd1 ${PWD}/*|tail -n1)
	if [ -d $DIR ]; then
		cd $DIR
	else 
		echo "$DIR does not exist"
		return 1
	fi
}

#: psgrep @ Quickly search the ps tree for match @ psgrep -m nastran
function psgrep() {
	echo 'USER       PID STAT  START COMMAND'
	echo '----------------------------------'
	if [[ $1 == -m ]]; then
		ps -u $(whoami) -ouser,pid,stat,bsdstart,command --sort stat | grep --color=never -i $(echo $2|sed 's/^./\[&\]/g')
	else
		ps ax -ouser,pid,stat,bsdstart,command --sort stat| grep --color=never -i $(echo $1|sed 's/^./\[&\]/g')
	fi
}

#: vtmp @ Edit text quickly in a volitile file in vanilla(ish) vim @ vtmp
function vtmp() {
	if [[ ${#@} > 1 ]]; then
	 	echo "vtmp takes no arguments"
		return 1
	fi
	T_FILE=$(mktemp --tmpdir=/home/$(whoami)/tmp)
	vim -n -c "set nonumber" -c "set foldcolumn=0" -c "set foldmethod=manual"  $T_FILE
	rm -f $T_FILE
}

