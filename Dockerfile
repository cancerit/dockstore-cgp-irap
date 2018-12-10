
FROM nunofonseca/irap_ubuntu:v1.0.6b
MAINTAINER yx2@sanger.ac.uk

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      description="tool to produce and post file checksum for dockstore.org"

USER root

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu


ENV IRAP_OPT /opt/irap

RUN apt-get install -yq --no-install-recommends libtbb-dev
RUN apt-get install -yq --no-install-recommends libtbb2
RUN apt-get install -yq --no-install-recommends bc

RUN apt-get clean

# install latest version of R package data.table, so that iRAP (an R script of iRAP) won't use /dev/shm
RUN set +u
CMD Rscript -e 'remove.packages("data.table"); install.packages(c("data.table","optparse"), quiet=TRUE)'

COPY scripts/irap /usr/bin/
COPY scripts/irap_wrapper.sh /usr/bin/
RUN chmod a+x /usr/bin/irap
RUN chmod a+x /usr/bin/irap_wrapper.sh

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
