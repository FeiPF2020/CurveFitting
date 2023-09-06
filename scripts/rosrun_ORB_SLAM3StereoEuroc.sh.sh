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
run_file="Stereo_Inertial"
# shellcheck disable=SC2034
vocabulary_file="/home/pf/allVersionSLAM/ORB_SLAM3/Vocabulary/ORBvoc.txt"
# shellcheck disable=SC2034
setting_file="/home/pf/allVersionSLAM/ORB_SLAM3/Examples/Stereo-Inertial/EuRoC.yaml"

echo "Ready to run ROS_ORB_SLAM3................................"
# shellcheck disable=SC2162
read -p "Press Enter to Continue OR Ctrl+C to Quit!"
rosrun ORB_SLAM3 "$run_file" "$vocabulary_file" "$setting_file" fasle


# rosrun ORB_SLAM3 Stereo_Inertial '/home/pf/allVersionSLAM/ORB_SLAM3/Vocabulary/ORBvoc.txt' '/home/pf/allVersionSLAM/ORB_SLAM3/Examples/Stereo-Inertial/EuRoC.yaml' false

# "Usage: rosrun ORB_SLAM3 Stereo_Inertial path_to_vocabulary path_to_settings do_rectify [do_equalize]"

# <<< ORB-SLAM3 <<<
