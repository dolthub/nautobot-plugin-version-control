# Description: Run all the steps of starting nautobot
# Main flow is outlined in README and You: https://www.youtube.com/watch?v=XHrTHwhbZLc

# General settings
editor="charm"
editor="code"
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
    "$editor" "$log_file"
    exit $rc
  else
    echo "Command succeeded in $duration seconds"
  fi
  echo
  run_command_step_num=$((run_command_step_num + 1))
}

# Clean up
echo "Cleaning up..."
rm -rf logs
mkdir logs

# Pre-flight checks
echo "Checking for required files..."
if [ ! -f "./development/creds.env" ]; then
  echo "./development/creds.env file not found. Please create it - for example, by copying ./development/creds.example.env - and try again."
  exit 1
fi
if [ ! -f "./development/hosted_ca.pem" ]; then
  echo "./development/hosted_ca.pem file not found. Please download a copy from https://hosted.doltdb.com/deployments/ and try again."
  exit 1
fi

# Load environment variables
echo "Loading environment variables..."
source ./development/creds.env

# Create databases
echo "Creating databases..."
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "DROP DATABASE IF EXISTS nautobot;"
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "CREATE DATABASE nautobot CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "DROP DATABASE IF EXISTS test_nautobot;"
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "CREATE DATABASE test_nautobot CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "DROP DATABASE IF EXISTS test_nautobot_hosted;"
mysql -h"$DOLT_HOST" -u"$DOLT_USER" -p"$DOLT_PASSWORD" -e "CREATE DATABASE test_nautobot_hosted CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
echo "Done creating databases!"

# Run commands
run_command "invoke destroy"
run_command "invoke build"
run_command "invoke migrate"
run_command "invoke load-data"
run_command "invoke start"

# Notify user
# osascript -e "tell app \"System Events\" to display dialog \"Done!\""
