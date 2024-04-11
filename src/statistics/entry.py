from colorama import Fore, Back, Style
from datetime import datetime
import sys
import os
import pandas as pd


def main():
    data_folder = sys.argv[1]
    start_time_str = sys.argv[2]
    end_time_str = sys.argv[3]
    name = sys.argv[4]

    start_time = datetime.strptime(start_time_str, "%Y-%m-%d %H:%M:%S")
    end_time = datetime.strptime(end_time_str, "%Y-%m-%d %H:%M:%S")

    print(Back.LIGHTYELLOW_EX + "")
    print(
        "************************************************************************************************"
    )
    print("Name: ", name)
    print("Starting datetime for History collection: ", start_time)
    print("End datetime for History collection: ", end_time)
    print(f"Input data folder: ", data_folder)
    print(
        "************************************************************************************************"
    )
    print(Style.RESET_ALL)

    selected_cpu_files = []
    selected_mem_files = []
    cpu_mean_values = {}
    mem_mean_values = {}
    # Traverse files in the specified data folder
    for root, dirs, files in os.walk(data_folder):
        for file in files:
            # Check if the file name contains "acm-pod" and has either "mem-usage-wss.csv" or "cpu-usage.csv"
            if ("acm-pod" in file or "kubelet" in file or "kubeapi" in file) and (
                "cpu-usage.csv" in file
            ):
                selected_cpu_files.append(os.path.join(root, file))
            # Check if the file name contains "acm-pod" and has either "mem-usage-wss.csv" or "cpu-usage.csv"
            if ("acm-pod" in file or "kubelet" in file or "kubeapi" in file) and (
                "mem-usage-wss.csv" in file
            ):
                selected_mem_files.append(os.path.join(root, file))

    for file in selected_cpu_files:
        averages = filter_and_average(file, start_time, end_time, debug=False)
        cpu_mean_values.update(averages.to_dict())

    for file in selected_mem_files:
        averages = filter_and_average(file, start_time, end_time, debug=False)
        mem_mean_values.update(averages.to_dict())

    print("CPU average:")
    for key, value in cpu_mean_values.items():
        rounded_value = round(value, 4)
        print(f"{key}\t{rounded_value}")

    print("Memory average:")
    for key, value in mem_mean_values.items():
        rounded_value = round(value, 1)
        print(f"{key}\t{rounded_value}")

def filter_and_average(path, start_time, end_time, debug=True):
    df = pd.read_csv(path, sep=",")
    df["timestamp"] = pd.to_datetime(df["timestamp"])

    filtered_df = df[(df["timestamp"] >= start_time) & (df["timestamp"] <= end_time)]

    if debug:
        print(f"Filtered data: \n", filtered_df)
    averages = filtered_df.select_dtypes(include="number").mean()
    return averages

if __name__ == "__main__":
    main()
