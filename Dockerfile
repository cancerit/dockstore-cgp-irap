FROM ubuntu:16.04

MAINTAINER yx2@sanger.ac.uk

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      description="tool to produce and post file checksum for dockstore.org"

USER root

ENV IRAP_OPT /opt/irap

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

COPY build/build.sh build/
RUN bash build/build.sh $IRAP_OPT

COPY scripts/irap /usr/bin/
COPY scripts/irap_wrapper.sh /usr/bin/
RUN chmod a+x /usr/bin/irap
RUN chmod a+x /usr/bin/irap_wrapper.sh

USER ubuntu
WORKDIR /home/ubuntu

#ENTRYPOINT ["irap"]
CMD ["/bin/bash"]
