Example call:

Assume you have setup the following structure in the project path (look at startAndroidBuild17.sh for PROJECT_PATH):
PROJECT_PATH=/development/lenovo/android17_dev

```
android
ccache
out
zips
```

In the "android" folder you have to setup your repository:
repo init ...
repo sync ...

After the repository is synced you can call the following script to build your image:
./startAndroidBuild17.sh nice -n20 ionice -c2 /bin/bash -c ". build/envsetup.sh && export USE_CCACHE=true && export CCACHE_EXEC=/usr/sbin/ccache && lunch lineage_YTX703L-userdebug && make 2>&1 | tee build.log" ; date

This would start a shell where the neccessary lunch and make steps are included. For convinience there should be an build.log file inside the android folder.
