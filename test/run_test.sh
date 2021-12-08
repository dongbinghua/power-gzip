export NX_GZIP_CONFIG=./nx-zlib.conf
#export NX_GZIP_LOGFILE=./nx.log
export LD_LIBRARY_PATH=../lib:$LD_LIBRARY_PATH

TS=$(date +"%F-%H-%M-%S")
run_test_log=run_test_${TS}.log
run_test_report=run_test_report_${TS}.txt
> $run_test_log
> $run_test_report

run() {
    test="$1"
    shift 1
    testname=$(basename $test)

    echo "running ${testname}..."
    $TEST_WRAPPER $test "$@" >> $run_test_log 2>&1
    if [ $? -ne 0 ]; then
        echo "${testname} failed."
        exit 1;
    fi
}

run ./test_deflate
run ./test_inflate
run ./test_inflatesyncpoint
run ./test_stress
run ./test_crc32
run ./test_adler32
run ./test_multithread_stress ${TEST_NTHREADS:-$(nproc)} 10 6
run ./test_pid_reuse 2
run ./test_zeroinput
run ./test_buf_error
echo "------------------------------"

grep -E 'run_case|failed' $run_test_log | tee -a $run_test_report

grep -A 17 Thread $run_test_log | tee -a $run_test_report
