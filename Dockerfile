FROM ubuntu
RUN apt-get update && apt-get install -y \
  autoconf \
  build-essential \
  dh-autoreconf \
  git \
  libssl-dev \
  libtool \
  python-software-properties \
  redis-server \
  tcl8.5

# Clone the Dynomite Git
RUN git clone https://github.com/Netflix/dynomite.git

COPY startup.sh dynomite/startup.sh

COPY pdok-dynomite-test.yml conf/pdok-dynomite-simple.yml

# Move to working directory
WORKDIR dynomite/

# Autoreconf
RUN autoreconf -fvi \
  && ./configure --enable-debug=log \
  && CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full \
  && make \
  && make install

##################### INSTALLATION ENDS #####################

# Expose the peer port
EXPOSE 8101

# Expose the stats/admin port
EXPOSE 22222

# Default port to acccess Dynomite
EXPOSE 8102

# Setting overcommit for Redis to be able to do BGSAVE/BGREWRITEAOF
RUN sysctl vm.overcommit_memory=1

# Set the entry-point to be the startup script
ENTRYPOINT ["/dynomite/startup.sh"]

