from ubuntu:14.04
maintainer bizruntime
run sudo apt-get update && apt-get -y upgrade
run apt-get purge openjdk-*
run apt-get install -y wget git tar unzip nano nfs-common
run mkdir /opt/alfresco


#JDK 1.7u67
run mkdir -p /opt/java
workdir /opt/java
run wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-x64.tar.gz \
    && tar xzvf jdk-7u67-linux-x64.tar.gz && rm -r jdk-7u67-linux-x64.tar.gz
run touch /etc/profile.d/java.sh \
    && echo "export JAVA_HOME=/opt/java/jdk1.7.0_67" >> /etc/profile.d/java.sh \
    && echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin" >> /etc/profile.d/java.sh


#ImageMagick
run apt-get -y install ghostscript imagemagick

#FFMPeg
run apt-get -y install  software-properties-common \
    && add-apt-repository ppa:mc3man/trusty-media \
    && apt-get update \
    && apt-get -y install ffmpeg


#SWFTools

run apt-get -y install libjpeg62 libgif4 libart-2.0-2
run wget http://archive.canonical.com/ubuntu/pool/partner/s/swftools/swftools_0.9.0-0ubuntu2_amd64.deb \
    && chmod a+x swftools_0.9.0-0ubuntu2_amd64.deb \
    && sudo dpkg -i swftools_0.9.0-0ubuntu2_amd64.deb


#LibreOffice
run apt-get -y install libreoffice


#alfresco-5.1 installation
workdir /opt/alfresco
run wget https://sourceforge.net/projects/alfresco/files/alfresco-community-installer-201605-linux-x64.bin
run chmod 777 alfresco-community-installer-201605-linux-x64.bin
workdir /tmp



run git clone -b alfresco https://github.com/akhilrajmailbox/alfresco-5.1.git
workdir /opt/alfresco
run cp /tmp/alfresco-5.1/auto-file /opt/alfresco
run ./alfresco-community-installer-201605-linux-x64.bin --optionfile auto-file
run cp /tmp/alfresco-5.1/mysql-connector-java-5.1.38-bin.jar /opt/alfresco-community/tomcat/lib



workdir /opt/alfresco-community

#########################################################################################
###########################    clustering-conf    #######################################
#########################################################################################

#nfs-configuration and mounting && make sure that nfs server export files to this machine
#change root directory as this mount point in option-file which is used while automatic-alfresco-installation
run mkdir -p /opt/alfresco-community/nfs || pwd
run cat /tmp/alfresco-5.1/clustering-file >> /opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties
run sed -i "s|dir.root=/opt/alfresco-community/alf_data|dir.root=/opt/alfresco-community/nfs/alf_data|g" /opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties


#########################################################################################
###########################    multi-tenet-conf   #######################################
#########################################################################################

#multi-tenet directory also need to be mount with nfs

run mkdir /opt/alfresco-community/t1
run mkdir /opt/alfresco-community/t2

expose 8080 7800 2049


#use --privileged for running the docker, if not then mount option will not work and lead to error
#wait for first container start for for run second container to run.

entrypoint mount -t nfs 192.168.1.234:/opt/alfresco-community/nfs /opt/alfresco-community/nfs \
	   && mount -t nfs 192.168.1.234:/opt/alfresco-community/t1 /opt/alfresco-community/t1 \
	   && mount -t nfs 192.168.1.234:/opt/alfresco-community/t2 /opt/alfresco-community/t2 \
	   && ls /opt/alfresco-community/nfs/alf_data \
	   && /opt/alfresco-community/alfresco.sh start \
           && tail -f /opt/alfresco-community/tomcat/logs/catalina.out && bash \
	   || cp -r /opt/alfresco-community/alf_data /opt/alfresco-community/nfs/ \
	   && /opt/alfresco-community/alfresco.sh start \
	   && tail -f /opt/alfresco-community/tomcat/logs/catalina.out && bash
