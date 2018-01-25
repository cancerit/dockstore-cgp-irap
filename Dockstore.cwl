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
    doc: "experiment name, it is used to name the output folder as well"
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
      position: 3
      separate: false

  reference:
    type: string?
    doc: "the reference genome file path, default to whatever in the configuration file"
    inputBinding:
      prefix: reference=
      position: 4
      separate: false

  gtf_file:
    type: string?
    doc: "reference GTF file path, default to whatever in the configuration file"
    inputBinding:
      prefix: gtf_file=
      position: 5
      separate: false

  data_dir:
    type: string?
    doc: "input data directory, default to whatever in the configuration file"
    inputBinding:
      prefix: data_dir=
      position: 6
      separate: false
      shellQuote: true

  mapper:
    type: string?
    doc: "the mapping algorithm to use, default to whatever in the configuration file"
    inputBinding:
      prefix: mapper=
      position: 7
      separate: false

  max_threads:
    type: string?
    doc: "max threads to use for iRAP, default to whatever in the configuration file"
    inputBinding:
      prefix: max_threads=
      position: 8
      separate: false

  quant_method:
    type: string?
    doc: "quantification method, default to whatever in the configuration file"
    inputBinding:
      prefix: quant_method=
      position: 9
      separate: false

  qual_filtering:
    type: string?
    doc: "base quality filtering (on|off|none), default to whatever in the configuration file"
    inputBinding:
      prefix: qual_filtering=
      position: 10
      separate: false

  quant_norm_tool:
    type: string?
    doc: "normalization of counts (irap|none), default is none or whatever in the configuration file"
    inputBinding:
      prefix: quant_norm_tool=
      position: 11
      separate: false

  quant_norm_method:
    type: string?
    doc: "normalization method to use (rpkm|deseq_nlib|tpm|none), default is none or whatever in the configuration file"
    inputBinding:
      prefix: quant_norm_method=
      position: 12
      separate: false

  trim_reads:
    type: string?
    doc: "Trim all reads to the minimum read size after quality trimming (y|n), default whatever in the configuration file"
    inputBinding:
      prefix: trim_reads=
      position: 13
      separate: false

  min_read_length:
    type: string?
    doc: "Minimum read size/length after trimming, default is 85% of the original length or whatever in the configuration file"
    inputBinding:
      prefix: min_read_length=
      position: 14
      separate: false

  min_read_quality:
    type: string?
    doc: "Minimum base quality accepted, default is 10 or whatever in the configuration file"
    inputBinding:
      prefix: min_read_quality=
      position: 15
      separate: false

  exon_quant:
    type: string?
    doc: "Exon level quantification (y|n), default to whatever in the configuration file"
    inputBinding:
      prefix: exon_quant=
      position: 16
      separate: false

  transcript_quant:
    type: string?
    doc: "transcript level quantification (y|n), default to whatever in the configuration file"
    inputBinding:
      prefix: transcript_quant=
      position: 17
      separate: false

  fusion_method:
    type: string?
    doc: "Fusion gene analysis (fusionmap|none), default to whatever in the configuration file"
    inputBinding:
      prefix: fusion_method=
      position: 18
      separate: false

  fusion_support_reads:
    type: string?
    doc: "minimum number of reads that need to support a fusion, default to whatever in the configuration file"
    inputBinding:
      prefix: fusion_support_reads=
      position: 19
      separate: false

outputs:
  result_data:
    type:
      type: array
      items: File
    outputBinding:
      glob: "$(inputs.exp_name)/*"

baseCommand: ["irap"]
