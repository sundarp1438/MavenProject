FROM redhat/ubi8
MAINTAINER sundarp1@yahoo.com
RUN yum install java-11* -y
RUN java -version
ENV tomcat_test 123
RUN mkdir -p /opt/tomcat/
WORKDIR /opt/tomcat/
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.109/bin/apache-tomcat-7.0.109.tar.gz
RUN tar xvf apache-tomcat-7.0.109.tar.gz
RUN mv apache-tomcat-7.0.109/* /opt/tomcat/
WORKDIR /opt/tomcat/webapps
RUN curl -O https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
# Set environment variables
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
# Expose Tomcat port
EXPOSE 8080
COPY ./webapp.war /usr/local/tomcat/webapps
