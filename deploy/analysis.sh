#!/bin/bash

KUBECTL=${KUBECTL:-oc}

# Get the directory of the currently executing script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "$( dirname "${DIR}" )" && pwd )"
printf "DIR: ${DIR}, BASE_DIR: ${BASE_DIR}\n"

# Check if cluster name is provided
cluster_name=$1
if [ -z "$cluster_name" ]; then
    echo "Error: Cluster name is empty. Provide a valid cluster name."
    exit 1
fi

folder_name=$BASE_DIR/$cluster_name
analysis_file=$folder_name/acm_analysis
analysis_file_relative_path="./$cluster_name/acm_analysis"
mc_file=$folder_name/acm_managedcluster
cronjob_file=$folder_name/acm_cronjob

# Function to gather metrics and perform analysis
gather_and_analyze() {
    local folder_name=$1
    local base_timestamp=$2
    local start_offset=$3
    local end_offset=$4
    local name=$5

    if [ "$base_timestamp" = "null" ]; then
        echo "no base timestamp"
        return
    fi

    local base_unix_timestamp=$(date -u -d "$base_timestamp" +"%s")

    local start_unix_timestamp=$(echo "$base_unix_timestamp + $start_offset * 3600" | bc)
    local start_timestamp=$(date -u -d "@$start_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    local end_unix_timestamp=$(echo "$base_unix_timestamp + $end_offset * 3600" | bc)
    local end_timestamp=$(date -u -d "@$end_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    python3 $BASE_DIR/src/statistics/entry.py "$folder_name" "$start_timestamp" "$end_timestamp" "$name" >> $analysis_file
}

# save managed cluster
if [ -f "$mc_file" ]; then 
    echo "File '$mc_file' already exists."
else
    ${KUBECTL} get managedcluster $cluster_name  -o json > "$mc_file" 
    echo "Save managed cluster into file '$mc_file'."
fi

# save cron job list
if [ -f "$cronjob_file" ]; then
    echo "File '$cronjob_file' already exists."
else
    ${KUBECTL} get cronjob --template '{{range .items}}{{.metadata.name}}{{"\t"}}{{.status.lastScheduleTime}}{{"\n"}}{{end}}' > "$cronjob_file"
    echo "Save cronjob into file '$cronjob_file'."
fi

# get managed cluster create time
mc_timestamp=$(cat $mc_file | jq -r '.metadata.creationTimestamp')

gather_and_analyze "$folder_name" "$mc_timestamp" "-2" "0" "no acm"
gather_and_analyze "$folder_name" "$mc_timestamp" "1" "6" "idle acm"

# get cron job list
cron_job_list=($(cat $cronjob_file | grep create-${cluster_name} | awk '{print $1}'))

for job in "${cron_job_list[@]}"
do
    echo "analysising $job ..."
    job_schedule_timestamp=($(cat $cronjob_file | grep ${job} | awk '{print $2}'))
    gather_and_analyze "$folder_name" "$job_schedule_timestamp" "0.5" "1.5" $job
done
