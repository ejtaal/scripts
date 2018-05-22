#!/bin/bash -x

export ftp_proxy="$1"
export http_proxy="$1"
export https_proxy="$1"
export no_proxy=".local,.localdomain,proxy,127.0.0.1/8,::1"

echo "Acquire::http::proxy  \"$1\";
Acquire::https::proxy \"$1\";" > /etc/apt/apt.conf.d/99proxy

# Do git
git config --global http.proxy "$1"


# Do pip/easy_install

# Maven ~/.m2/settings.xml
MAVEN_PROXY_XML="<settings>
  <proxies>
   <proxy>
      <id>CNTLM</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>localhost</host>
      <port>3128</port>
      <nonProxyHosts>www.google.com|*.example.com</nonProxyHosts>
    </proxy>
  </proxies>
</settings>"


