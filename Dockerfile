FROM ubuntu
ENV REPO="xenial"

# Install Kurento Media Server

RUN apt-get update && apt install -y curl wget nano openjdk-8-jdk maven git
RUN echo "deb http://ubuntu.kurento.org $REPO kms6" | tee /etc/apt/sources.list.d/kurento.list
RUN wget http://ubuntu.kurento.org/kurento.gpg.key -O - | apt-key add -
RUN apt-get update && apt-get install -y kurento-media-server-6.0 kms-datachannelexample
RUN sed -i 's/sudo/#/' /etc/init.d/kurento-media-server-6.0

# Install cozycast-server

RUN cd /root/ && git clone https://github.com/Vorlent/cozycast.git
WORKDIR /root/cozycast/cozycast-server

# Install RTSP Server

RUN apt-get install -y libmoose-perl liburi-perl libmoosex-getopt-perl libsocket6-perl libanyevent-perl make
#RUN echo | cpan
RUN cpan AnyEvent::MPRPC::Client || :
WORKDIR /root/
RUN git clone https://github.com/revmischa/rtsp-server
WORKDIR /root/rtsp-server
RUN perl Makefile.PL
RUN make
RUN make test
RUN make install

# start kurento media server, rtsp server, drop to shell
# you can manually start the webserver with mvn compile exec:java

#WORKDIR /root/cozycast/cozycast-server

CMD service kurento-media-server-6.0 start && (perl /root/rtsp-server/rtsp-server.pl > /dev/null 2>&1 &) && /bin/bash #mvn compile exec:java
