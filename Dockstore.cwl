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
    coresMin: 1 # works but long, 24 recommended
    ramMin: 32000
    outdirMin: 20000

inputs:
  reference:
    type: File
    doc: "The core reference (fa, fai, dict) as tar.gz"
    inputBinding:
      prefix: -reference
      position: 1
      separate: true

  annot:
    type: File
    doc: "The VAGrENT cache files"
    inputBinding:
      prefix: -annot
      position: 2
      separate: true

  snv_indel:
    type: File
    doc: "Supporting files for SNV and INDEL analysis"
    inputBinding:
      prefix: -snv_indel
      position: 3
      separate: true

  cnv_sv:
    type: File
    doc: "Supporting files for CNV and SV analysis"
    inputBinding:
      prefix: -cnv_sv
      position: 4
      separate: true

  subcl:
    type: File
    doc: "Supporting files for allele counts used by Battenberg Subclonal CNV analysis"
    inputBinding:
      prefix: -subcl
      position: 5
      separate: true

  tumour:
    type: File
    secondaryFiles:
    - .bai
    - .bas
    doc: "Tumour BAM or CRAM file"
    inputBinding:
      prefix: -tumour
      position: 6
      separate: true

  normal:
    type: File
    secondaryFiles:
    - .bai
    - .bas
    doc: "Normal BAM or CRAM file"
    inputBinding:
      prefix: -normal
      position: 7
      separate: true

  exclude:
    type: string
    doc: "Contigs to block during indel analysis"
    inputBinding:
      prefix: -exclude
      position: 8
      separate: true
      shellQuote: true

  species:
    type: string?
    doc: "Species to apply if not found in BAM headers"
    default: ''
    inputBinding:
      prefix: -species
      position: 9
      separate: true
      shellQuote: true

  assembly:
    type: string?
    doc: "Assembly to apply if not found in BAM headers"
    default: ''
    inputBinding:
      prefix: -assembly
      position: 10
      separate: true
      shellQuote: true

  skipbb:
    type: boolean?
    doc: "Skip Battenberg allele counts"
    inputBinding:
      prefix: -skipbb
      position: 11
      separate: true

  cavereads:
    type: int?
    doc: "Number of reads in a split section for CaVEMan"
    default: 350000
    inputBinding:
      prefix: -cavereads
      position: 12
      separate: true

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
