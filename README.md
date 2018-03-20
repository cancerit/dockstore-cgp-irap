# dockstore-cgp-irap

Dockerised [iRAP](https://github.com/nunofonseca/irap) for Dockstore.

[![Docker Repository on Quay](https://quay.io/repository/wtsicgp/dockstore-cgp-irap/status "Docker Repository on Quay")](https://quay.io/repository/wtsicgp/dockstore-cgp-irap)

master: [![Build Status](https://travis-ci.org/cancerit/dockstore-cgp-irap.svg?branch=master)](https://travis-ci.org/cancerit/dockstore-cgp-irap)
develop: [![Build Status](https://travis-ci.org/cancerit/dockstore-cgp-irap.svg?branch=develop)](https://travis-ci.org/cancerit/dockstore-cgp-irap)

This project wraps iRAP into a Dockstore tool.

Required inputs are:

1. reference: A FastA file of the reference genome to map reads to. The file can be gzipped.
1. gtf: Reference gene annotation in GTF format. The file can be gzipped. It can be a tar file of GTF gene reference files genereated by previous iRAP runs.
1. species: species name, can be any string as well, this might be recorded in output file names and bam headers.
1. raw_read_file(s): raw read files, can be FastQ(s) or BAM(s). Theie relations to samples will need to be set in either configuration files or using `irap_conf_string`.
1. config and/or irap_conf_string(s): `config` should be a file with analysis configurations for iRAP. Details are in [iRAP wiki](https://github.com/nunofonseca/irap/wiki/8-Configuration-file). These parameters can be supplied with `irap_conf_string` as well. When same parameter is set in both the configuration file and with `irap_conf_string`, the one in configuration file will be overwritten.

Optional inputs are:

1. exp_name - experiment name to distinguish your analysis, output folder will have the same name.
1. conta_genomes: FastA format of genomes to filter raw reads. If supplied, iRAP will remove reads that can be mapped to these genomes from raw reads.

## Release process

This project is maintained using HubFlow.

1. Make appropriate changes
1. Bump version in `Dockerfile` and `Dockstore.cwl`
1. Push changes
1. Check state on Travis
1. Generate the release (add notes to GitHub)
1. Confirm that image has been built on [quay.io](https://quay.io/repository/wtsicgp/dockstore-cgp-irap?tab=builds)
1. Update the [dockstore](https://dockstore.org/containers/quay.io/wtsicgp/dockstore-cgp-irap) entry, see [their docs](https://dockstore.org/docs/getting-started-with-dockstore).

## LICENCE

Copyright (c) 2018 Genome Research Ltd.

Author: Cancer Genome Project <cgpit@sanger.ac.uk>

This file is part of dockstore-cgp-irap.

dockstore-cgp-irap is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

1. The usage of a range of years within a copyright statement contained within this distribution should be interpreted as being equivalent to a list of years including the first and last year specified and all consecutive years between them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-2009, 2011-2012’ should be interpreted as being identical to a statement that reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012’."
