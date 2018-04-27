FROM base/archlinux
MAINTAINER Julian Xhokaxhiu <info at julianxhokaxhiu dot com>

# Environment variables
#######################

ENV SRC_DIR /srv/src
ENV CCACHE_DIR /srv/ccache
ENV ZIP_DIR /srv/zips
ENV LMANIFEST_DIR /srv/local_manifests

# Delay creation of user and group
ARG THEUSER=buildbot
ARG THEGROUP=users

ENV USER ${THEUSER}
ENV GROUP ${THEGROUP}
#RUN groupadd -g 100 -r "${GROUP}"
RUN  useradd -u 1000 -rmg "${GROUP}" "${USER}"

# Configurable environment variables
####################################

# By default we want to use CCACHE, you can disable this
# WARNING: disabling this may slow down a lot your builds!
ENV USE_CCACHE 1

# Environment for the LineageOS Branch name
# See https://github.com/LineageOS/android_vendor_cm/branches for possible options
ENV BRANCH_NAME 'cm-14.1'

# Environment for the device list ( separate by comma if more than one)
# eg. DEVICE_LIST=hammerhead,bullhead,angler
ENV DEVICE_LIST ''

# OTA URL that will be used inside CMUpdater
# Use this in combination with LineageOTA to make sure your device can auto-update itself from this buildbot
ENV OTA_URL ''

# User identity
ENV USER_NAME 'LineageOS Buildbot'
ENV USER_MAIL 'lineageos-buildbot@docker.host'

# If you want to start always fresh ( re-download all the source code everytime ) set this to 'true'
ENV CLEAN_SRCDIR false

# If you want to preserve old ZIPs set this to 'false'
ENV CLEAN_OUTDIR true

# Change this cron rule to what fits best for you
# By Default = At 10:00 UTC ~ 2am PST/PDT
ENV CRONTAB_TIME '0 10 * * *'

# Print detailed output rather than only summary
ENV DEBUG false

# Clean artifacts output after each build
ENV CLEAN_AFTER_BUILD true

# Provide root capabilities builtin inside the ROM ( see http://lineageos.org/Update-and-Build-Prep/ )
ENV WITH_SU true

# Provide a default JACK configuration in order to avoid out-of-memory issues
ENV ANDROID_JACK_VM_ARGS "-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"

# Create Volume entry points
############################

VOLUME $SRC_DIR
VOLUME $CCACHE_DIR
VOLUME $ZIP_DIR
VOLUME $LMANIFEST_DIR

# Copy required files and fix permissions
#####################

COPY src/* /root/

# Create missing directories
############################

RUN mkdir -p $SRC_DIR
RUN mkdir -p $CCACHE_DIR
RUN mkdir -p $ZIP_DIR
RUN mkdir -p $LMANIFEST_DIR

# Set the work directory
########################

WORKDIR $SRC_DIR

# Fix permissions
#################

RUN chmod 0755 /root/*
RUN chown -R "${USER}":"${GROUP}" /root/*

# Enable multilib support
#########################

RUN sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Set mirrorlist
#########################

RUN cp /root/mirrorlist /etc/pacman.d/mirrorlist && rm /root/mirrorlist

# Update installation
##############################

RUN pacman -Syu --noconfirm --noprogressbar

# Reinstall keyring
##############################

RUN pacman -Sy --noconfirm --noprogressbar archlinux-keyring

# Install development tools
##############################

RUN pacman -Sy --needed --noconfirm --noprogressbar base-devel

# Replace conflicting packages
##############################

RUN yes | pacman -Sy --noprogressbar --needed gcc-multilib

# Install manually compiled packages
####################################

RUN pacman -U --noconfirm --noprogressbar /root/ncurses5-compat-libs-6.0+20161224-1-x86_64.pkg.tar.xz \
    && rm /root/ncurses5-compat-libs-6.0+20161224-1-x86_64.pkg.tar.xz \
    && pacman -U --noconfirm --noprogressbar /root/lib32-ncurses5-compat-libs-6.0-4-x86_64.pkg.tar.xz \
    && rm /root/lib32-ncurses5-compat-libs-6.0-4-x86_64.pkg.tar.xz \
    && pacman -U --noconfirm --noprogressbar /root/curl-7.55.1-2-x86_64.pkg.tar.xz \
    && rm /root/curl-7.55.1-2-x86_64.pkg.tar.xz

# Install required Android AOSP packages
########################################

RUN pacman -Sy --needed --noconfirm --noprogressbar \
      git \
      gnupg \
      flex \
      bison \
      gperf \
      sdl \
      wxgtk \
      squashfs-tools \
      ncurses \
      zlib \
      schedtool \
      perl-switch \
      zip \
      unzip \
      libxslt \
      bc \
      lib32-zlib \
      lib32-ncurses \
      lib32-readline \
      rsync \
      maven \
      repo \
      imagemagick \
      ccache \
      libxml2 \
      cronie \
      ninja \
      wget \
      zsh \
      mc \
      jdk8-openjdk

# Create missing symlink to python2
###################################
RUN ln -s /usr/bin/python2 /usr/local/bin/python
RUN ln -s /usr/bin/python2 /usr/bin/python

# Allow redirection of stdout to docker logs
############################################
RUN ln -sf /proc/1/fd/1 /var/log/docker.log

# Cleanup
#########

RUN yes | pacman -Scc

RUN echo "root:Docker!" | chpasswd

USER "${USER}":"${GROUP}"

# Set the entry point to init.sh
###########################################

CMD /root/init.sh && /root/build.sh
