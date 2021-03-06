#!/bin/bash
# handles a test suite: makes, runs and collects results
# $1 - the directory containing the test
# $2 - the test platform
# $3 - the test suite
testdir=$1
platform=$2
suite=$3

# initialze environment
ci_dir=$(dirname $0)
. $ci_dir/test_setup.sh
. $ci_dir/functions.sh

# bring in info on platform -> cores
. $ci_dir/cores

export core_name=${name[$platform]}

# make the firmware 
echo Building test suite in "$1"
$ci_dir/make_test.sh $platform $suite || die 

# flash the firmware
echo OTA flashing firmware
spark flash $core_name $target_file || die 
# todo - verify test suite build time or fix spark-cli return codes

# give enough time for the core to go into OTA mode
sleep 10 || die

echo "Waiting for test suite to party"
waitForState waiting 120 || die "Timeout waiting for test suite"

# do it
$ci_dir/configure_and_run_test.sh $1 $2 $3 
result=$?
echo Test $platform/$suite complete. 
exit "$result"
