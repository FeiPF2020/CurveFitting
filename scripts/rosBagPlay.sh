#!/bin/bash

# >>> ORB-SLAM3 >>>
# !!run ORB_SLAM3 whith EUROC dataset including imu stereo  !!

rosbag_dir="/home/pf/iDataSet/EuRoC/"
bag_name="MH_01_easy.bag"
if [ ! -d "$rosbag_dir" ]; then
  echo "error: rosbag_dir don't exist!"
  exit 1
fi

cd "$rosbag_dir" || exit
echo "current_dir: $(pwd)"
echo "${rosbag_dir}${bag_name}"
rosbag info "${rosbag_dir}${bag_name}"
sleep 1

echo "Ready to play ROS_bag................................"
# shellcheck disable=SC2162
read -p "Press Enter to Continue OR Ctrl+C to Quit!"
rosbag play "${rosbag_dir}${bag_name}"
# <<< ORB-SLAM3 <<<
