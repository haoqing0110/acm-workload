#!/bin/bash
set -e

KUBECTL=${KUBECTL:-oc}

# Check if cluster name is provided
cluster_name=$1
if [ -z "$cluster_name" ]; then
    echo "Error: Cluster name is empty. Provide a valid cluster name."
    exit 1
fi

# Function to calculate and format cron schedule given timestamp
calculate_and_format_cron_schedule() {
    local timestamp=$(date -u -d "@$1" +"%Y-%m-%dT%H:%M:%SZ")

    # Adjust day_of_week to 0 if it's 7 (Sunday)
    local day_of_week=$(date -u -d "$timestamp" "+%u")
    if [ "$day_of_week" -eq 7 ]; then
        day_of_week=0
    fi

    local cron_schedule=$(date -u -d "$timestamp" "+%M %H %d %m $day_of_week")
    echo "$cron_schedule"
}

# Create YAML files using templates
create_yaml_file_from_template() {
    local template=$1
    local output_file=$2

    if [ -e "$template" ]; then
        sed -e "s/<CRON_SCHEDULE>/${3}/g; s/<CLUSTER_NAME>/${cluster_name}/g" "$template" > "$output_file"
        echo "- $output_file" >> kustomization.yaml
    fi

}

# Create YAML files based on offset
create_yaml_by_offset() {
    local base_timestamp=$1
    local create_offset=$2
    local delete_offset=$3
    local name=$4

    local base_unix_timestamp=$(date -u -d "$base_timestamp" +"%s")

    local create_unix_timestamp=$(echo "$base_unix_timestamp + $create_offset * 3600" | bc)
    local create_cron_schedule=$(calculate_and_format_cron_schedule $create_unix_timestamp) 

    local delete_unix_timestamp=$(echo "$base_unix_timestamp + $delete_offset * 3600" | bc)
    local delete_cron_schedule=$(calculate_and_format_cron_schedule $delete_unix_timestamp) 

    echo "$name create schedule: $create_cron_schedule"
    echo "$name delete schedule: $delete_cron_schedule"

    create_yaml_file_from_template "${name}_create_template" "output/${name}_create.yaml" "$create_cron_schedule"
    create_yaml_file_from_template "${name}_delete_template" "output/${name}_delete.yaml" "$delete_cron_schedule"
}

# Check if kubectl command succeeded
if ! mc_timestamp=$(${KUBECTL} get managedcluster "$cluster_name" -o json | jq -r '.metadata.creationTimestamp'); then
    echo "Error: Failed to retrieve managed cluster information using ${KUBECTL}."
    exit 1
fi

rm -r output || true
mkdir output

echo "managed cluster creationTimestamp: $mc_timestamp"
create_yaml_by_offset "$mc_timestamp" "6" "7.5" "job_app"
create_yaml_by_offset "$mc_timestamp" "7.5" "9" "job_policy"
create_yaml_by_offset "$mc_timestamp" "9" "10.5" "job_obs"
# uncomments below code when testing benchmark for addon combinations
#create_yaml_by_offset "$mc_timestamp" "10.5" "12" "job_enable_app"
#create_yaml_by_offset "$mc_timestamp" "12" "13.5" "job_enable_policy_proxy"
#create_yaml_by_offset "$mc_timestamp" "13.5" "15" "job_enable_policy_search"
#create_yaml_by_offset "$mc_timestamp" "15" "16.5" "job_enable_all"
