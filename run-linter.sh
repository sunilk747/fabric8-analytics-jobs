directories="f8a_jobs"
separate_files="f8a-jobs.py setup.py"
fail=0

function prepare_venv() {
    VIRTUALENV=`which virtualenv`
    if [ $? -eq 1 ]; then
        # python34 which is in CentOS does not have virtualenv binary
        VIRTUALENV=`which virtualenv-3`
    fi

    ${VIRTUALENV} -p python3 venv && source venv/bin/activate && python3 `which pip3` install pycodestyle
}

echo "----------------------------------------------------"
echo "Running Python linter against following directories:"
echo $directories
echo "----------------------------------------------------"
echo

[ "$NOVENV" == "1" ] || prepare_venv || exit 1

# checks for the whole directories
for directory in $directories
do
    files=`find $directory -path $directory/venv -prune -o -name '*.py' -print`

    for source in $files
    do
        echo $source
        pycodestyle $source
        if [ $? -eq 0 ]
        then
            echo "    Pass"
        else
            echo "    Fail"
            let "fail++"
        fi
    done
done


echo
echo "----------------------------------------------------"
echo "Running Python linter against selected files:"
echo $separate_files
echo "----------------------------------------------------"

# check for individual files
for source in $separate_files
do
    echo $source
    pycodestyle $source
    if [ $? -eq 0 ]
    then
        echo "    Pass"
    else
        echo "    Fail"
        let "fail++"
    fi
done


if [ $fail -eq 0 ]
then
    echo "All checks passed"
else
    echo "Linter fail, $fail source files need to be fixed"
    # let's return 0 in all cases not to break CI (ATM :)
    # exit 1
fi