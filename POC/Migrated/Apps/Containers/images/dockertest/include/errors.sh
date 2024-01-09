#!/bin/bash -e
TMP=$(mktemp)

#The signals SIGKILL and SIGSTOP cannot be caught, blocked, or ignored.
SYS_SIGHUP=1    #      Term    Hangup detected on controlling terminal or death of controlling process
SYS_SIGINT=2    #      Term    Interrupt from keyboard or syntax error
SYS_SIGQUIT=3   #      Core    Quit from keyboard
SYS_SIGILL=4    #      Core    Illegal Instruction
SYS_SIGABRT=6   #      Core    Abort signal from abort(3)
SYS_SIGFPE=8    #      Core    Floating point exception
SYS_SIGKILL=9   #      Term    Kill signal
SYS_SIGSEGV=11  #      Core    Invalid memory reference
SYS_SIGPIPE=13  #      Term    Broken pipe: write to pipe with no readers
SYS_SIGALRM=14  #      Term    Timer signal from alarm(2)
SYS_SIGTERM=15  #      Term    Termination signal

get_system_signal_message(){
  sig="$1"

  if [ "$sig" == "" ]; then
    echo "No signal code provided to obtain error message."; exit
  fi

  if [ "$sig" == "$SYS_SIGHUP" ]; then
    echo "Hangup detected on controlling terminal or death of controlling process."; exit
  fi

  if [ "$sig" == "$SYS_SIGINT" ]; then
    echo "Interrupt from keyboard"; exit
  fi

  if [ "$sig" == "$SYS_SIGQUIT" ]; then
    echo "Quit from keyboard"; exit
  fi

  if [ "$sig" == "$SYS_SIGILL" ]; then
    echo "Illegal Instruction"; exit
  fi

  if [ "$sig" == "$SYS_SIGABRT" ]; then
    echo "Abort signal from abort(3)"; exit
  fi

  if [ "$sig" == "$SYS_SIGFPE" ]; then
    echo "Floating point exception"; exit
  fi

  if [ "$sig" == "$SYS_SIGSEGV" ]; then
    echo "Invalid memory reference"; exit
  fi

  if [ "$sig" == "$SYS_SIGPIPE" ]; then
    echo "Broken pipe: write to pipe with no readers"; exit
  fi

  if [ "$sig" == "$SYS_SIGALRM" ]; then
    echo "Timer signal from alarm(2)"; exit
  fi

}

function set_trap {  
	echo "#### SET TRAP ####"
	trap 'send_error ? $LINENO' EXIT ERR SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGSEGV SIGPIPE SIGALRM
}

function unset_trap {
	echo "#### UNSET TRAP ###"
  trap - EXIT ERR SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGSEGV SIGPIPE SIGALRM
}

send_error(){
  exit_code="$?"
	line_no="$2"

	unset_trap
  	
  if [ $exit_code == 0 ]; then return 0; fi

	REQUESTID="$(cat $REQUESTID_TMP)"

  echo "#### HANDLE ERROR FOR ID: $REQUESTID SCHEME: $SCHEME ####"
  	
	err_msg="$(echo $(cat $TMP) | sed 's/\"//g')"
	rm $TMP

  if [ "$err_msg" == "" ]; then
    err_msg=$(get_system_signal_message "$exit_code")
  fi

  error_type="init"

  if [ "$REQUESTID" != "" ]; then
      error_type="invocation/$REQUESTID"
  fi

	err_msg="An error occurred on line $line_no. Exit code $exit_code. $err_msg"

  ERROR_JSON="{\"errorMessage\" : \"$err_msg\", \"error_type\" : \"$error_type\"}"
  
  URL="$SCHEME://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/$error_type/error"

	echo "Scheme: $SCHEME"
	echo "Exit Code: $exit_code"
	echo "Line Number: $line_no"
  echo "Error: $err_msg"
	echo "Request ID: $REQUESTID"
	echo "Error Type: $error_type"
	echo "URL: $URL"
	echo "ERROR_JSON: $ERROR_JSON"
	echo "####"

	curl "$URL" -d "$ERROR_JSON" --header "Lambda-Runtime-Function-Error-Type: Unhandled"


}

       #OTHER CODES NOT CURRENTLY HANDLED

       #SIGUSR1   30,10,16    Term    User-defined signal 1
       #SIGUSR2   31,12,17    Term    User-defined signal 2
       #SIGCHLD   20,17,18    Ign     Child stopped or terminated
       #SIGCONT   19,18,25    Cont    Continue if stopped
       #SIGSTOP   17,19,23    Stop    Stop process
       #SIGTSTP   18,20,24    Stop    Stop typed at terminal
       #SIGTTIN   21,21,26    Stop    Terminal input for background process
       #SIGTTOU   22,22,27    Stop    Terminal output for background process
       #SIGBUS      10,7,10     Core    Bus error (bad memory access)
       #SIGPOLL                 Term    Pollable event (Sys V).
       #                                Synonym for SIGIO
       #SIGPROF     27,27,29    Term    Profiling timer expired
       #SIGSYS      12,31,12    Core    Bad argument to routine (SVr4)
       #SIGTRAP        5        Core    Trace/breakpoint trap
       #SIGURG      16,23,21    Ign     Urgent condition on socket (4.2BSD)
       #SIGVTALRM   26,26,28    Term    Virtual alarm clock (4.2BSD)
       #SIGXCPU     24,24,30    Core    CPU time limit exceeded (4.2BSD)
       #SIGXFSZ     25,25,31    Core    File size limit exceeded (4.2BSD)
       #SIGIOT         6        Core    IOT trap. A synonym for SIGABRT
       #SIGEMT       7,-,7      Term
       #SIGSTKFLT    -,16,-     Term    Stack fault on coprocessor (unused)
       #SIGIO       23,29,22    Term    I/O now possible (4.2BSD)
       #SIGCLD       -,-,18     Ign     A synonym for SIGCHLD
       #SIGPWR      29,30,19    Term    Power failure (System V)
       #SIGINFO      29,-,-             A synonym for SIGPWR
       #SIGLOST      -,-,-      Term    File lock lost (unused)
       #SIGWINCH    28,28,20    Ign     Window resize signal (4.3BSD, Sun)
       #SIGUNUSED    -,31,-     Core    Synonymous with SIGSYS
