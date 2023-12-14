#!/bin/bash
operate=$1
if [ -z "$operate" ]
then
      echo "Operate is empty"
      exit 1
fi
resource_template=$2
if [ -z "$resource_template" ]
then
      echo "Resource template is empty"
      exit 1
fi
count=$3
if [ -z "$count" ]
then
      echo "Count is empty"
      exit 1
fi
cluster_name=$4
if [ -z "$cluster_name" ]
then
      echo "Cluster name is empty"
      exit 1
fi

for((i=1;i<=$count;i++))
do
      if [[ $operate == "delete" ]]
      then
            kubectl apply -f $resource_template --dry-run=client --validate=false -o yaml | sed "s|NUM|${i}|g" \
            | sed "s|MANAGED-CLUSTER-NAME|${cluster_name}|g" | kubectl $operate -f -
      else
            kubectl apply -f $resource_template --dry-run=client --validate=false -o yaml | sed "s|NUM|${i}|g" \
            | sed "s|MANAGED-CLUSTER-NAME|${cluster_name}|g" | kubectl $operate --validate=false -f -
      fi
done
