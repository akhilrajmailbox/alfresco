from ubuntu:14.04
maintainer bizruntime
run sudo apt-get update && apt-get -y upgrade
run apt-get purge openjdk-*
run apt-get install -y wget git tar unzip nano
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

expose 8080
entrypoint /opt/alfresco-community/alfresco.sh start && tail -f /opt/alfresco-community/tomcat/logs/catalina.out && bash
