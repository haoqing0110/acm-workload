#!/bin/bash

# Namespace where the resources are located
NAMESPACE="local-cluster"

# Get the list of resources
RESOURCES=$(kubectl get manifestwork -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

# Directory to store the exported JSON files
EXPORT_DIR="./exported_resources"
mkdir -p $EXPORT_DIR

# Array to hold file sizes in KB
file_sizes_kb=()

# Header for the table
printf "%-50s %-15s\n" "Resource Name" "File Size (KB)"
printf "%-50s %-15s\n" "-------------" "--------------"

# Loop through each resource and export it as JSON
for RESOURCE in $RESOURCES; do
  # Export the resource as JSON
  kubectl get manifestwork $RESOURCE -n $NAMESPACE -o json > "$EXPORT_DIR/$RESOURCE.json"
  
  # Get file size in bytes based on OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    FILE_SIZE=$(stat -f %z "$EXPORT_DIR/$RESOURCE.json")
  else
    # Linux
    FILE_SIZE=$(stat --format="%s" "$EXPORT_DIR/$RESOURCE.json")
  fi
  FILE_SIZE_KB=$(echo "scale=2; $FILE_SIZE/1024" | bc)
  
  # Store the file size in the array
  file_sizes_kb+=($FILE_SIZE_KB)
  
  # Print the resource name and file size in table format
  printf "%-50s %-15s\n" "$RESOURCE.json" "$FILE_SIZE_KB"
done

# Sort the file sizes array
sorted_sizes=($(printf '%s\n' "${file_sizes_kb[@]}" | sort -n))

# Calculate the median
count=${#sorted_sizes[@]}
if (( $count % 2 == 1 )); then
  median=${sorted_sizes[$((count/2))]}
else
  mid=$((count/2))
  median=$(echo "scale=2; (${sorted_sizes[mid-1]} + ${sorted_sizes[mid]}) / 2" | bc)
fi

# Display the median
echo
echo "Median file size: $median KB"

echo "All resources exported to $EXPORT_DIR."

