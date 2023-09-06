#!/bin/bash

# >>> ORB-SLAM3 >>>
# !!run ORB_SLAM3 whith EUROC dataset including imu stereo  !!

ORB_SLAM3_dir="/home/pf/allVersionSLAM/ORB_SLAM3"
if [ ! -d "$ORB_SLAM3_dir" ]; then
  echo "error: ORB_SLAM3_dir don't exist!"
  exit 1
fi
cd "$ORB_SLAM3_dir" || exit
echo "current_dir: $(pwd)"
# shellcheck disable=SC2034
run_file="Examples/Stereo-Inertial/stereo_inertial_euroc"
# shellcheck disable=SC2034
vocabulary_file="/home/pf/allVersionSLAM/ORB_SLAM3/Vocabulary/ORBvoc.txt"
# shellcheck disable=SC2034
setting_file="/home/pf/allVersionSLAM/ORB_SLAM3/Examples/Stereo-Inertial/EuRoC.yaml"
# shellcheck disable=SC2034
dataset_folder="/home/pf/iDataSet/EuRoC/MH_01_easy"
# shellcheck disable=SC2034
times_file="/home/pf/allVersionSLAM/ORB_SLAM3/Examples/Stereo-Inertial/EuRoC_TimeStamps/MH01.txt"
# shellcheck disable=SC2034
saving_trajectory_name="MH01_stereo_imu"

echo "Ready to run ORB_SLAM3................................"
# shellcheck disable=SC2162
read -p "Press Enter to Continue OR Ctrl+C to Quit!"
./"$run_file" "$vocabulary_file" "$setting_file" "$dataset_folder" "$times_file" "$saving_trajectory_name"

##  "Usage: ./stereo_inertial_euroc path_to_vocabulary path_to_settings path_to_sequence_folder_1 path_to_times_file_1 (path_to_image_folder_2 path_to_times_file_2 ... path_to_image_folder_N path_to_times_file_N) last argc is using for saving pose
# ./Examples/Stereo-Inertial/stereo_inertial_euroc ./Vocabulary/ORBvoc.txt ./Examples/Stereo-Inertial/EuRoC.yaml  '/home/pf/iDataSet/EuRoC/MH_01_easy' ./Examples/Stereo-Inertial/EuRoC_TimeStamps/MH01.txt dataset-MH01_stereo
# <<< ORB-SLAM3 <<<