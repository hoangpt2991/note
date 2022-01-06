set target_dir="C:\Users\bpham26\Desktop\test\New folder"
set target_file_copy="C:\Users\bpham26\Desktop\test\jmeter-code\api\Client.jmx"
set git_folder="jmeter-code"

rd /s /q "./%git_folder%" 
echo "Completed to remote old folder %git_folder%"
git clone -b product https://github.dxc.com/tle252/UIUX-JmeterSample.git %git_folder%
copy /y %target_file_copy% %target_dir%