FROM alpine:3.11.3 as stage1
WORKDIR /opt_download
RUN wget "https://sourceforge.net/projects/pentaho/files/Pentaho%209.0/server/pentaho-server-ce-9.0.0.0-423.zip"
RUN unzip *.zip && rm -rf *.zip


FROM alpine:3.11.3
COPY --from=stage1 /opt_download /opt
WORKDIR /opt

RUN apk add --update --no-cache unzip wget busybox-suid shadow bash openjdk8 tzdata postgresql-client terminus-font msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f && \
    rm -rf /etc/localtime &&  mkdir -p /opt/pentaho && touch /etc/localtime /etc/timezone

COPY ./configs/start.sh /usr/bin/start.sh
COPY ./configs/startup.sh /opt/pentaho-server/tomcat/bin/startup.sh
# 
# This is removed in the future since we now use confd wich inject the file for as
#COPY ./configs/context.xml /opt/pentaho-server/tomcat/webapps/pentaho/META-INF/context.xml
#COPY ./configs/repository.xml /opt/pentaho-server/pentaho-solutions/system/jackrabbit/repository.xml
#COPY ./configs/postgresql.hibernate.cfg.xml /opt/pentaho-server/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
#COPY ./configs/hibernate-settings.xml /opt/pentaho-server/pentaho-solutions/system/hibernate/hibernate-settings.xml

# Confd to replace file with ENV vars
ENV POSTGRES_HOST somehost
ENV POSTGRES_PORT 6643
#
# Install confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
	mkdir -p /opt/confd/bin && \
	mv confd-0.16.0-linux-amd64 /opt/confd/bin/confd && \
	chmod +x /opt/confd/bin/confd && \
	mkdir -p /etc/confd/{conf.d,templates} && \
	export PATH="$PATH:/opt/confd/bin"
# Copy configs and templates
COPY ./configs/confd /etc/confd/
# End Confd

##RUN adduser -D -u 1001 s2i && usermod -aG 0 s2i && \
##chown 1001 -R /opt/pentaho-server /usr/bin/start.sh /home/s2i && \
##chgrp -R 0 /opt/pentaho-server /usr/bin/start.sh /etc/localtime /home/s2i /etc/timezone && \
##chmod -R g=u /opt/pentaho-server /usr/bin/start.sh /etc/localtime /home/s2i /etc/timezone
##ENV HOME /home/s2i
##USER 1001
##EXPOSE 8080 8009

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["/opt/pentaho-server/start-pentaho.sh"]