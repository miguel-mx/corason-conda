# DOCKER-VERSION 0.3.4
FROM bioperl/bioperl

## Installing perl module
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm SVG
RUN cpanm Bio::SeqIO;
RUN cpanm Bio::SeqFeature::Generic;
#RUN cpanm Bio::Seq;
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget

###____________________________________________
RUN if [ ! -d /opt ]; then mkdir /opt; fi
###____________________________________________
# Installing blast
RUN mkdir /opt/blast && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz | tar -zxC /opt/blast --strip-components=1
######_____________________________________________________________________________________
# Instaling muscle
 RUN wget -O /opt/muscle3.8.tar.gz http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
 RUN mkdir /opt/muscle && tar -C /opt/muscle -xzvf /opt/muscle3.8.tar.gz && ln -s /opt/muscle/muscle3.8.31_i86linux64 /o
pt/muscle/muscle
####___________________________________________________________________
## Instaling FastTree
RUN mkdir /opt/fasttree && wget -O /opt/fasttree/FastTree http://www.microbesonline.org/fasttree/FastTree && chmod +x /o
pt/fasttree/FastTree
#________________________________________________________________________________
# Installing NewickTools
RUN wget -O /opt/newick-utils-1.6.tar.gz https://github.com/tjunier/newick_utils/archive/refs/heads/master.tar.gz
RUN mkdir /opt/nw && tar -C /opt/nw -xzvf /opt/newick-utils-1.6.tar.gz && cd /opt/nw/newick_utils-master && cp src/* /us
r/local/bin
##___________________________________________________
#### Vim
RUN cd ~
RUN apt-get update && apt-get install -y software-properties-common
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y git-all libncurses5-dev libncursesw5-dev
RUN apt-get build-dep -y vim
RUN git clone https://github.com/vim/vim.git
RUN cd vim && ./configure && make VIMRUNTIMEDIR=/usr/share/vim/vim74 && make install
#_________________________________________________________________________________________________
## CORASON
RUN cd /opt && git clone https://github.com/miguel-mx/corason-conda.git
####__________________________________________________________________
# Installing GBlocks
RUN tar -xf /opt/corason-conda/CORASON/Gblocks_Linux64_0.91b.tar.Z -C /opt/ && ln -s /opt/Gblocks_0.91b/Gblocks /usr/bin
/Gblocks
## Other perl modules
RUN locale-gen en_US.utf8

######### PATHS ENVIRONMENT
ENV PATH /opt/blast/bin:$PATH:/opt/muscle:/opt/Gblocks:/opt/quicktree/quicktree_1.1/bin:/opt/corason/CORASON:/opt/fasttr
ee
RUN chmod +x /opt/corason-conda/CORASON/*pl
## Moving to myapp directory
RUN mkdir /home/output
WORKDIR /home/output
## Como paso variables ?
CMD ["perl", "/opt/corason-conda/CORASON/corason.pl"]
## Volumen para escribir la salida
