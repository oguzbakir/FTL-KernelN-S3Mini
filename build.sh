#!/bin/bash
clear
echo -e " \e[34m"

echo -e " \e[32m"
PS3='Please enter your choice: '
options=("Compile Kernel" "Clean Old Files" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Compile Kernel")
start=`date +%s`
echo -e "\e[33mThis Script Edited By oguzbakir\e[0m"
echo -e "\e[34mSay Thanks To Him İf He Helped U\e[0m"
NOW=$(date +"%d-%m-%Y")
echo "Current Date : $NOW"
echo -e "\e[35mApplying Build Settings\e[0m"

export ARCH=arm
export CCOMPILE=$CROSS_COMPILE
export CROSS_COMPILE=arm-linux-androideabi-
export PATH=toolchains/arm-linux-androideabi-4.9/bin:$PATH

#CONFIGS
export SLEEP=1
echo -e "\e[36mSetting CPU Cores/Threads\e[0m"
export CPUS=`nproc`
echo -e " \e[91m"
read -p "Enter Version Number : " s
v='v'
export VER=$v$s
echo -e "\e[92mVersion Number Is Setting To $v$s\e[0m"

echo -e "\e[93mSetting Defconfig\e[0m"
export DEFCONFIG=golden_android_defconfig
echo -e "\e[94mSetting bzImage Location For FTL-Kernel By oguzbakir Of XDA\e[0m"
export BZIMAGE=arch/arm/boot/zImage
echo -e "\e[36mEnviroment Setup Complete Now Moving To Compiling\e[0m"

#Build
sleep 1
sleep $SLEEP
echo -e "\e[96mStarting Build Process\e[0m"
sleep $SLEEP
if [ -f .config ];
then
   echo -e "\e[97m.config exists\e[0m"
   echo -e "\e[31mContinuing To Compiler\e[0m"
   sleep $SLEEP
else
   echo -e "\e[32m.config Does Not Exists\e[0m"
   echo -e "\e[33mCompiling From $DEFCONFIG\e[0m"
echo -e " \e[34m"
   make $DEFCONFIG
   sleep $SLEEP
fi
echo -e "\e[34mCompiling FTL Kernel\e[0m"
make $EV -j$CPUS

if [ -f $BZIMAGE ];
then
   echo -e "\e[35m$BZIMAGE exists\e[0m"
   echo -e "\e[36mCompile Complete Continuing To Packing\e[0m"
   sleep $SLEEP
else
   echo -e "\e[37m$BZIMAGE Does Not Exists Please Check For Compile Errors\e[0m"
   echo -e "\e[90mNow exiting script\e[0m"
   sleep $SLEEP
   exit 0
fi
clear
echo -e " \e[91m"
echo -e "\e[92mScript Made By Nyks45 From XDA\e[0m"
echo -e " \e[93m"
printf "Say Him To Thanks If He Helped You \n\n"
echo -e " \e[94m"
echo "Version Number = $VER"
echo -e " \e[37m"
echo "Build complete"

#Kernel Packing
echo -e "\e[96mFTL Kernel Packing\e[0m"
echo -e "\e[97mStarting Packing To Recovery Flashable Zip\e[0m"
cd KernelZip/
rm -rf tools/bootimg/kernel/zImage *.zip
sleep $SLEEP
echo -e "\e[31mCopying bzImage\e[0m"
mv ../arch/arm/boot/zImage tools/bootimg/kernel/zImage
sleep $SLEEP
echo -e "\e[32mCompiling FTL-kernel_"$VER".zip\e[0m"
echo -e " \e[33m"
find . -type f -exec zip FTL-Kernel_"$VER".zip {} +
nowf=$(date +"%T")
cd ..
rm KernelZip/tools/bootimg/kernel/zImage
echo -e " \e[34m"
printf "\n\nzip created\n"
echo -e " \e[34m"


end=`date +%s`
runtime=$((end-start))
echo "Completion Time :$runtime sec"

break
            ;;
        "Clean Old Files")
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        make clean && make mrproper
        break
        ;;
    *)
        break
        ;;
esac
echo "Cleaning Compiled Files"
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
