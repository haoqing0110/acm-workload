#!/bin/bash

KUBECTL=${KUBECTL:-oc}

operate=$1
if [ -z "$operate" ]
then
      echo "Operate is empty"
      exit 1
fi

count=$2
if [ -z "$count" ]
then
      echo "Count is empty"
      exit 1
fi

#group=$(( (count - 1) / 5 + 1 ))
#for((g=1;g<=$group;g++))
#do
#      ${KUBECTL} apply -f mclset.yaml --dry-run=client -o yaml | sed "s|GROUP|${g}|g" | ${KUBECTL} $operate -f -
#done

for((i=1;i<=$count;i++))
do
      ${KUBECTL} apply -f mclset.yaml --dry-run=client -o yaml | sed "s|GROUP|${i}|g" | ${KUBECTL} $operate -f -

      ${KUBECTL} apply -f mc.yaml --dry-run=client -o yaml | sed "s|NUM|${i}|g" \
      | sed "s|GROUP|${i}|g" | ${KUBECTL} $operate -f -

      ${KUBECTL} apply -f placement.yaml --dry-run=client -o yaml | sed "s|NUM|${i}|g" \
      | sed "s|GROUP|${i}|g" | ${KUBECTL} $operate -f -
done

#for((i=1;i<=$count;i++))
#do
#      g=$(( (i - 1) / 5 + 1 ))
#      ${KUBECTL} apply -f placement.yaml --dry-run=client -o yaml | sed "s|NUM|${i}|g" \
#      | sed "s|GROUP|${g}|g" | ${KUBECTL} $operate -f -
#done

for((i=1;i<=$count;i++))
do
      cluster_name="cluster-${i}"
      for((j=1;j<=5;j++))
      do
            ${KUBECTL} apply -f mcv.yaml --dry-run=client -o yaml | sed "s|NUM|${j}|g" \
            | sed "s|MANAGED_CLUSTER_NAME|${cluster_name}|g" | ${KUBECTL} $operate -f -
      done
      for((j=1;j<=10;j++))
      do
            ${KUBECTL} apply -f msa.yaml --dry-run=client -o yaml | sed "s|NUM|${j}|g" \
            | sed "s|MANAGED_CLUSTER_NAME|${cluster_name}|g" | ${KUBECTL} $operate -f -
      done
      for((j=1;j<=24;j++))
      do
            ${KUBECTL} apply -f mw.yaml --dry-run=client -o yaml | sed "s|NUM|${j}|g" \
            | sed "s|MANAGED_CLUSTER_NAME|${cluster_name}|g" | ${KUBECTL} $operate -f -
      done
done