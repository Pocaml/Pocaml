POCAMLC="./pocamlc"

ulimit -t 30

globallog=testall.log
rm -f $globallog
error=0
globalerror=0

keep=0
pflags="-c"

Usage() {
    echo "Usage: testall.sh [options] [.pml files]"
    echo "-k    Keep intermediate files"
    echo "-l	Run tests locally"
    echo "-h    Print this help"
    exit 1
}

SignalError() {
    if [ $error -eq 0 ] ; then
	echo "FAILED"
	error=1
    fi
    echo "  $1"
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
	SignalError "$1 differs"
	echo "FAILED $1 differs from $2" 1>&2
    }
}

# Run <args>
# Report the command, run it, and report any errors
Run() {
    echo $* 1>&2
    eval $* || {
	SignalError "$1 failed on $*"
	return 1
    }
}

# RunFail <args>
# Report the command, run it, and expect an error
RunFail() {
    echo $* 1>&2
    eval $* && {
	SignalError "failed: $* did not report an error"
	return 1
    }
    return 0
}

Check() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.pml//'`
    reffile=`echo $1 | sed 's/.pml$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."
    testdir="`echo $1 | sed 's/\/[^\/]*$//'`"
    build_dir="_pml_build"

    echo "$basename...\c"

    echo 1>&2
    echo "###### Testing $basename" 1>&2
    generatedfiles=""

    generatedfiles="$generatedfiles ${basename}.diff ${basename}.out" &&
    Run $POCAMLC '-bsf' ${testdir}/${basename}.pml 1>&2 &&
    Run "${build_dir}/${basename}.exe" > ${basename}.out &&
    Compare ${basename}.out ${reffile}.out ${basename}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
	echo "OK"
	echo "###### SUCCESS" 1>&2
    else
    echo "FAILED"
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

CheckFail() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.pml//'`
    reffile=`echo $1 | sed 's/.pml$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."
    testdir="`echo $1 | sed 's/\/[^\/]*$//'`"
    build_dir="_pml_build"

    echo "$basename...\c"

    echo 1>&2
    echo "###### Testing $basename" 1>&2
    generatedfiles=""

    generatedfiles="$generatedfiles ${basename}.diff ${basename}.err" &&
    Run $POCAMLC '-bsf' ${testdir}/${basename}.pml 1>&2 &&
    RunFail "${build_dir}/${basename}.exe" "2>" ${basename}.err ">>" $globallog &&
    Compare ${basename}.err ${reffile}.err ${basename}.diff
    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
    echo "OK"
	echo "###### SUCCESS" 1>&2
    else
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

CompileLib() {
    Run $POCAMLC -a 1>> $globallog 2>&1
}

while getopts khl c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	l) # Run tests locally
	    pflags="-l $pflags"
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`

if [ $# -ge 1 ]
then
    files=$@
else
    files="test/pml/*.pml"
fi

CompileLib

for file in $files
do
    case $file in
	*test_*)
	    Check $file 2>> $globallog
	    ;;
    *fail_*)
	    CheckFail $file 2>> $globallog
	    ;;
	*)
	    echo "unknown file type $file"
	    globalerror=1
	    ;;
    esac
done

exit $globalerror
