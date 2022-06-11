ARG IMAGE=quay.vapo.va.gov/helm/irishealth/irishealth
FROM $IMAGE AS src

#-Labels------------------------------------------------------------------------

LABEL version="0.0.1"


USER root   

RUN sed -i '/jfrog/d' /etc/apt/sources.list \ 
    && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \ 
    && export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -y upgrade \
    && apt-get -yq install unattended-upgrades \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/1.8/intersystems-cloud-manager-1.2.27.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/1.8/intersystems-cloudclient-1.0.0.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/1.8/intersystems-integratedml-1.0.1.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/1.8/intersystems-loader-1.0.1.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/1.8/intersystems-utils-3.3.0.jar \ 
    && rm -rf $ISC_PACKAGE_INSTALLDIR/dev/java/lib/datarobot/ \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/dev/java/lib/uima/uimaj-core-2.10.3.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/fop/lib/avalon-framework-impl-4.3.1.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/fop/lib/commons-logging-1.0.4.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/fop/lib/pdfbox-app-2.0.21.jar \ 
    && rm -f $ISC_PACKAGE_INSTALLDIR/fop/lib/xmlgraphics-commons-2.4.jar

WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild

USER ${ISC_PACKAGE_MGRUSER}
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} HS/Local/VA/eSCM src
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} Mail.inc src
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} ZFILECONTROL.mac src
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} Installer.xml Installer.xml
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} iris.script iris.script
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} %ZSTART.xml %ZSTART.xml

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
