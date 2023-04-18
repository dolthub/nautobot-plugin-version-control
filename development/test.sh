run_command_step_num=0

run_command() {
  cmd="$1"
  if [ "$2" ]; then
    log_file="logs/$(printf '%02d' "$run_command_step_num")-$2.log"
  else
    log_file="logs/$(printf '%02d' "$run_command_step_num")-$(echo "$cmd" | awk '{print $2}').log"
  fi
  echo "Running command: $cmd"
  echo "Logging to: $log_file"
  start_time=$(date +%s)
  $cmd > "$log_file" 2>&1
  rc=$?
  end_time=$(date +%s)
  duration=$((end_time - start_time))
  if [ $rc -ne 0 ]; then
    echo "Command failed with exit code $rc"
    echo "Opening $log_file in PyCharm..."
    charm "$log_file"
    exit $rc
  else
    echo "Command succeeded in $duration seconds"
  fi
  echo
  run_command_step_num=$((run_command_step_num + 1))
}

rm -rf logs
mkdir logs

defaultTest="nautobot_version_control"
testsToRun="${1:-$defaultTest}"

run_command "invoke destroy"
run_command "invoke build"
run_command "inv unittest -l \"$testsToRun\" --verbose --keepdb --debug" "unittest"

run_command "invoke destroy"
run_command "invoke build"
run_command "inv unittest --verbose --keepdb --debug" "unittest-all"

osascript -e "tell app \"System Events\" to display dialog \"Done!\"" > /dev/null