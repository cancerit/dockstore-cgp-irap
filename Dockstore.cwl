#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "cgp-irap"

label: "Dockerised iRAP for RNAseq data analysis"

cwlVersion: v1.0

doc: |
    ![build_status](https://quay.io/repository/wtsicgp/dockstore-cgp-irap/status)
    A Docker container of iRAP. See the [dockstore-cgp-irap](https://github.com/cancerit/dockstore-cgp-irap) website for more information.

dct:creator:
  "@id": "yaobo.xu@sanger.ac.uk"
  foaf:name: Yaobo Xu
  foaf:mbox: "yx2@sanger.ac.uk"

requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/wtsicgp/dockstore-cgp-irap:0.0.1"

hints:
  - class: ResourceRequirement
    coresMin: 1 # works but long, 8 recommended
    ramMin: 4000
    outdirMin: 8000

inputs:
  config:
    type: File
    doc: "The configuration file for a analysis."
    inputBinding:
      prefix: conf=
      position: 1
      separate: false

  exp_name:
    type: string
    doc: "experiment name, output folder has the same name"
    inputBinding:
      prefix: name=
      position: 2
      separate: false
      shellQuote: true

  species:
    type: string?
    doc: "species name, default to whatever in the configuration file"
    inputBinding:
      prefix: species=
      position: 2
      separate: false

  reference:
    type: string?
    doc: "the reference genome file path, default to whatever in the configuration file"
    inputBinding:
      prefix: reference=
      position: 2
      separate: false

  gtf_file:
    type: string?
    doc: "reference GTF file path, default to whatever in the configuration file"
    inputBinding:
      prefix: gtf_file=
      position: 2
      separate: false

  data_dir:
    type: string?
    doc: "input data directory, default to whatever in the configuration file"
    inputBinding:
      prefix: data_dir=
      position: 2
      separate: false
      shellQuote: true

  mapper:
    type: string?
    doc: "the mapping algorithm to use, default to whatever in the configuration file"
    inputBinding:
      prefix: mapper=
      position: 2
      separate: false

  max_threads:
    type: string?
    doc: "max threads to use for iRAP, default to whatever in the configuration file"
    default: ''
    inputBinding:
      prefix: max_threads=
      position: 9
      separate: false

  quantifacation_method======   #####:
    type: string?
    doc: "Assembly to apply if not found in BAM headers"
    default: ''
    inputBinding:
      prefix: -assembly
      position: 10
      separate: true
      shellQuote: true

outputs:
  run_params:
    type: File
    outputBinding:
      glob: run.params

  result_archive:
    type: File
    outputBinding:
      glob: WGS_*_vs_*.result.tar.gz

  # named like this so can be converted to a secondaryFile set once supported by dockstore cli
  timings:
    type: File
    outputBinding:
      glob: WGS_*_vs_*.timings.tar.gz

  global_time:
    type: File
    outputBinding:
      glob: WGS_*_vs_*.time

baseCommand: ["/opt/wtsi-cgp/bin/ds-wrapper.pl"]
