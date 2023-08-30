
# 一、Typora

Typora 0.11.18 and 0.9.96

0.11.18 是最后一个免费的beta版本， 后面就要收费了，现在打开会提示版本过期。
0.9.96 是个免费版本， 并且打开不会检测是否过期。


# 二、ORB_SLAM3配置

1. 环境：Ubuntu 20.04，对应ros直接官方教程安装
2. 下载链接：https://github.com/UZ-SLAMLab/ORB_SLAM3.git
3. Eigen：3.3.7
4. Pangolin：0.5
6. opencv：4.4.0
'''bash
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

'''
8. boost: 1.8.0
   下载链接：https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/
'''bash
   sudo apt-get install libssl-dev
   sudo apt-get install libcanberra-gtk-module
   sudo ./bootstrap.sh
   sudo ./b2 install
'''


编译时 使用命令：
- 编译 ORB-SLAM 3 出现 slots_reference 错误
'''bash
/usr/local/include/sigslot/signal.hpp:1180:65: error: ‘slots_reference’ was not declared in this scope
         cow_copy_type<list_type, Lockable> ref = slots_reference();
'''
 C++ 11 不支持编译，把 C++版本换到 C++14

'''bash
sed -i 's/++11/++14/g' CMakeLists.txt
'''
- 出现 C++: fatal error: Killed signal terminated program cc1plus
只需要编译时
make -j2 数字换小一些，即可
