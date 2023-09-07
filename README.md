# 一、Typora

Typora 0.11.18 and 0.9.96

0.11.18 是最后一个免费的beta版本， 后面就要收费了，现在打开会提示版本过期。
0.9.96 是个免费版本， 并且打开不会检测是否过期。

# 二、ORB_SLAM3配置

## 2. 1 基本环境搭建

1. 环境：Ubuntu 20.04，对应ros直接官方教程安装
2. 下载链接：https://github.com/UZ-SLAMLab/ORB_SLAM3.git
3. Eigen：3.3.7
4. Pangolin：0.5
5. opencv：4.4.0

```bash
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt update
sudo apt install libjasper1 libjasper-dev
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local/opencv4.4.0 ..
make -j14
sudo make install
sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo /bin/bash -c 'echo "/usr/local/opencv4.4.0/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig
sudo gedit /etc/bash.bashrc
source /etc/bash.bashrc 
sudo updatedb  
sudo apt-get install mlocate
```

6. boost: 1.8.0
    下载链接：https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/

```bash
sudo apt-get install libssl-dev
sudo apt-get install libcanberra-gtk-module
sudo ./bootstrap.sh
sudo ./b2 install
```

## 2.2 不使用ROS编译

- 编译 ORB-SLAM 3 出现 slots_reference 错误

    ```
    /usr/local/include/sigslot/signal.hpp:1180:65: error: ‘slots_reference’ was not declared in this scope
           cow_copy_type<list_type, Lockable> ref = slots_reference();
    ```

     C++ 11 不支持编译，把 C++版本换到 C++14

    ```
    sed -i 's/++11/++14/g' CMakeLists.txt
    ```

- 出现 `C++: fatal error: Killed signal terminated program cc1plus`
    只需要编译时`make -j2` 数字换小一些，即可

### 运行指令

```bash
##  "Usage: ./stereo_inertial_euroc path_to_vocabulary path_to_settings path_to_sequence_folder_1 path_to_times_file_1 (path_to_image_folder_2 path_to_times_file_2 ... path_to_image_folder_N path_to_times_file_N) last argc is using for saving pose
# ./Examples/Stereo-Inertial/stereo_inertial_euroc ./Vocabulary/ORBvoc.txt ./Examples/Stereo-Inertial/EuRoC.yaml  '/home/pf/iDataSet/EuRoC/MH_01_easy' ./Examples/Stereo-Inertial/EuRoC_TimeStamps/MH01.txt dataset-MH01_stereo
```

使用脚本文件为`run_ORB_SLAM3StereoEurocIMU.sh`



## 2.3 使用ros编译

1. 将ORB_SLAM3/Examples_old的ROS文件拷贝到Exmaples目录下

2. 查看python的软连接，保证是python软链接的环境是python3.8

    查看是否满足要求，不满足使用下面命令进行修改

    ```bash
    which python
    cd /usr/bin/
    ll -a | grep python
    # 备份
    sudo cp python python_backups
    # 删除软连接
    sudo rm -rf python
    ll -a | grep python
    sudo ln -s python3.8 python
    ll -a | grep python
    ```

3.  添加Sophus的库文件

    ```bash
    include_directories(
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/../../../
    ${PROJECT_SOURCE_DIR}/../../../include
    ${PROJECT_SOURCE_DIR}/../../../include/CameraModels
    ${PROJECT_SOURCE_DIR}/../../../Thirdparty/Sophus
    ${Pangolin_INCLUDE_DIRS}
    )
    ```

4. 修改对应的C++11到C++14 

    ```cmake
    # Check C++14 or C++0x support
    include(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX11)
    CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
    if(COMPILER_SUPPORTS_CXX11)
       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
       add_definitions(-DCOMPILEDWITHC11)
       message(STATUS "Using flag -std=c++14.")
    elseif(COMPILER_SUPPORTS_CXX0X)
       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
       add_definitions(-DCOMPILEDWITHC0X)
       message(STATUS "Using flag -std=c++0x.")
    else()
       message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
    endif()
    ```

5. 报错一

    ```bash
    ORB_SLAM3/Examples/ROS/ORB_SLAM3/src/AR/ros_mono_ar.cc:151:41运行指令: error: conversion from ‘Sophus::SE3f’ {aka ‘Sophus::SE3<float>’} to non-scalar type ‘cv::Mat’ requested
      151 |     cv::Mat Tcw = mpSLAM->TrackMonocular(cv_ptr->image,cv_ptr->header.stamp.toSec());
    ```

    修改为：

    ```
    加入头文件
    #include <Eigen/Dense>
    #include <opencv2/core/eigen.hpp>
    替换代码
        cv::Mat im = cv_ptr->image.clone();
        cv::Mat imu;
    //    cv::Mat Tcw = mpSLAM->TrackMonocular(cv_ptr->image,cv_ptr->header.stamp.toSec());
        cv::Mat Tcw;
        Sophus::SE3f Tcw_SE3f = mpSLAM->TrackMonocular(cv_ptr->image,cv_ptr->header.stamp.toSec());
        Eigen::Matrix4f Tcw_Matrix = Tcw_SE3f.matrix();
        cv::eigen2cv(Tcw_Matrix, Tcw);
        int state = mpSLAM->GetTrackingState();
        vector<ORB_SLAM3::MapPoint*> vMPs = mpSLAM->GetTrackedMapPoints();
        vector<cv::KeyPoint> vKeys = mpSLAM->GetTrackedKeyPointsUn();
    
    ```

6. 报错二 

    ```
    ORB_SLAM3/Examples/ROS/ORB_SLAM3/src/AR/ViewerAR.cc:530:42: error: conversion from ‘Eigen::Vector3f’ {aka ‘Eigen::Matrix<float, 3, 1>’} to non-scalar type ‘cv::Mat’ requested
      530 |             cv::Mat Xw = pMP->GetWorldPos();
    ```

    修改为：

    ```
    加入头文件
    #include <Eigen/Dense>
    #include <opencv2/core/eigen.hpp>
    替换代码
    int nPoints = 0;
        for(int i=0; i<N; i++)
        {
            MapPoint* pMP = mvMPs[i];
            if(!pMP->isBad())
            {
    //            cv::Mat Xw = pMP->GetWorldPos();
                cv::Mat Xw;
                cv::eigen2cv(pMP->GetWorldPos(), Xw);
                o+=Xw;
                A.row(nPoints).colRange(0,3) = Xw.t();
                nPoints++;
            }
        }
    ```

7. 报错三

    ```
    ORB_SLAM3/Examples/ROS/ORB_SLAM3/src/AR/ViewerAR.cc:406:53: error: no matching function for call to ‘std::vector<cv::Mat>::push_back(Eigen::Vector3f)’
      406 |                 vPoints.push_back(pMP->GetWorldPos());
    
    ```

    修改为：

    ```
       for(size_t i=0; i<vMPs.size(); i++)
        {
            MapPoint* pMP=vMPs[i];
            if(pMP)
            {
                if(pMP->Observations()>5)
                {
    //                vPoints.push_back(pMP->GetWorldPos());
                    cv::Mat WorldPos;
                    cv::eigen2cv(pMP->GetWorldPos(), WorldPos);
                    vPoints.push_back(WorldPos);
                    vPointMP.push_back(pMP);
                }
            }
        }
    ```

    编译成功**运行指令**

    ```bash
    ORB_SLAM3/Examples/ROS/ORB_SLAM3/build$ make -j4
    [  0%] Built target rospack_genmsg_libexe
    [  0%] Built target rosbuild_precompile
    [ 61%] Built target Stereo
    [ 61%] Built target Stereo_Inertial
    [ 61%] Built target Mono
    [ 69%] Built target MonoAR
    [100%] Built target Mono_Inertial
    [100%] Built target RGBD
    
    ```

    ### 运行指令

    ```bash
    # rosrun ORB_SLAM3 Stereo_Inertial '/home/pf/allVersionSLAM/ORB_SLAM3/Vocabulary/ORBvoc.txt' '/home/pf/allVersionSLAM/ORB_SLAM3/Examples/Stereo-Inertial/EuRoC.yaml' false
    
    # "Usage: rosrun ORB_SLAM3 Stereo_Inertial path_to_vocabulary path_to_settings do_rectify [do_equalize]"
    ```

    对应脚本文件：`rosrun_ORB_SLAM3StereoEuroc.sh.sh`

# 三、VINS-fusion环境配置
## 软件环境为：
- ceres-solver-1.14.0
- eigen-3.2.5
- opencv 3.2.0

**安装ceres出现版本与eigen不匹配问题，解决方法**

报错如下：

```
/home/zll/library/ceres-solver-1.14.0/internal/ceres/gtest/gtest.h:10445:35: error: variable or field ‘it’ declared void
10445 |   for (typename C::const_iterator it = container.begin();
      |                                   ^~ 
```

解决方法

    首先安装eigen，然后安装ceres

###  3.1 安装eigen

- 现在/usr目录下建立eigen3目录

    ```
    sudo mkdir eigen3
    ```

- 下载eigen 3.2.5 https://gitlab.com/libeigen/eigen/-/releases

    ```
    cd eigen_dir
    mkdir build 
    cd build
    cmake-gui
    ```

    1. 在UI界面的源代码处输入：`/home/pf/iSoftware/eigen-3.2.5`

    2. build the binaries 处输入：`/home/pf/iSoftware/eigen-3.2.5/build`

    3. 点击configure ，修改：

        ```
        BUILD_TESTING = true
        CMAKE_INSTALL_PREFIX = /usr/eigen3
        ```

        多次点击generate

    4. 然后使用`sudo make install` 即可

### 3.2 安装ceres

- 替换或者修改/ceres-solver/cmake/FindEigen.cmake文件为

    ```cmake
    macro(EIGEN_REPORT_NOT_FOUND REASON_MSG)
      unset(EIGEN_FOUND)
      unset(EIGEN_INCLUDE_DIRS)
    
      mark_as_advanced(CLEAR EIGEN_INCLUDE_DIR)
    
      if (Eigen_FIND_QUIETLY)
        message(STATUS "Failed to find Eigen - " ${REASON_MSG} ${ARGN})
      elseif (Eigen_FIND_REQUIRED)
        message(FATAL_ERROR "Failed to find Eigen - " ${REASON_MSG} ${ARGN})
      else()
    
        message("-- Failed to find Eigen - " ${REASON_MSG} ${ARGN})
      endif ()
      return()
    endmacro(EIGEN_REPORT_NOT_FOUND)
     
    # TODO: Add standard Windows search locations for Eigen.
    list(APPEND EIGEN_CHECK_INCLUDE_DIRS
      /usr/eigen3/include/eigen3)
    # Additional suffixes to try appending to each search path.
    list(APPEND EIGEN_CHECK_PATH_SUFFIXES
      eigen3 # Default root directory for Eigen.
      Eigen/include/eigen3 ) 
     
    set(EIGEN_FOUND TRUE)
    set(EIGEN_INCLUDE_DIR,/usr/eigen3/include/eigen3)
     
    # This is on a single line s/t CMake does not interpret it as a list of
    # elements and insert ';' separators which would result in 3.;2.;0 nonsense.
    set(EIGEN_VERSION "3.2.5")
     
    # Set standard CMake FindPackage variables if found.
    if (EIGEN_FOUND)
      set(EIGEN_INCLUDE_DIRS /usr/eigen3/include/eigen3)
    endif (EIGEN_FOUND)
     
    # Handle REQUIRED / QUIET optional arguments and version.
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(Eigen
      REQUIRED_VARS EIGEN_INCLUDE_DIRS
      VERSION_VAR EIGEN_VERSION)
    
    if (EIGEN_FOUND)
      mark_as_advanced(FORCE EIGEN_INCLUDE_DIR)
    endif (EIGEN_FOUND)
    ```

- 即可开始安装

    ```
    cmake ..
    make -j4
    make test
    sudo make install
    ```

### 3.3 安装opencv 3.2.0

安装opencv3.2.0以及对应模块，点击[链接](https://blog.csdn.net/Android_WPF/article/details/132734118?spm=1001.2014.3001.5501)即可！

### 3.4 catkin_make编译

如果出错：CSDN一堆，简单修改即可解决！

