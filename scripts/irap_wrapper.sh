#!/bin/bash

function usage {
  echo -e "\nUsage: irap_wrapper.sh -R genome_ref_file -g GTF_ref_bundle -s species -r raw_read_file ( -c irap_config_file | -i irap_config_string ) [ -o output_folder_name ]\n";
  echo " -R file : The genome reference file.";
  echo " -g file : GTF reference tar ball for iRAP, or a single GTF file.";
  echo " -s : name of the species.";
  echo " -o : experiment name, which is also used as iRAP output folder name.";
  echo " -r file : raw read file (FastQ|BAM), use -r for each file when there are more than one file";
  echo " -c file : iRAP config file";
  echo " -m file : gzipped contamination genomes file in fasta format.";
  echo " -i : iRAP config strings, eg: \"max_threads=8\", \"mapper=tophat1\", etc";
  echo " -h : print this help page"
}

function prepare_input_dir {
  # process arguments
  local data_dir_name="$1"; shift
  local ref_file="$1"; shift
  local gtf="$1"; shift
  local species="$1"; shift
  local exp_name="$1"; shift
  local raw_read_files=("$@")
  local irap_ref_dir="$data_dir_name/reference/$species"
  local irap_raw_data_dir="$data_dir_name/raw_data/$species"
  local irap_raw_bam_dir="$data_dir_name/raw_data/${exp_name}_${species}"
  # the ref dir
  mkdir -p "$exp_name/irap_qc"
  # added to avoid irap exit bug
  touch "$exp_name/irap_qc/qc.tsv"
  mkdir -p "$irap_ref_dir"
  ref_file_name="$(basename "$ref_file")"
  ln -sf "$(realpath "$ref_file")" "$irap_ref_dir/$ref_file_name"
  if tar tf "$gtf" 2> /dev/null 1>&2
  then
    tar xzf "$gtf" --directory "$irap_ref_dir/"
  else
    gtf_file_name="$(basename "$gtf")"
    ln -sf "$(realpath "$gtf")" "$irap_ref_dir/$gtf_file_name"
  fi

  # the raw file dir
  mkdir -p "$irap_raw_data_dir"
  mkdir -p "$irap_raw_bam_dir"
  for raw_read_file in "${raw_read_files[@]}"
  do
    raw_read_file_name="$(basename "$raw_read_file")"
    ln -sf "$(realpath "$raw_read_file")" "$irap_raw_data_dir/$raw_read_file_name"
    # required path by recent version
    ln -sf "$(realpath "$raw_read_file")" "$exp_name/$raw_read_file_name"
    # required when optiton atlas_run is selected
    ln -sf "$(realpath "$raw_read_file")" "$irap_raw_bam_dir/$raw_read_file_name"
  done
}

function setup_contamination_db {
  local data_dir_name="$1"; shift
  local index_dir_name="$1"; shift
  local con_genomes_index_name="$1"; shift
  local cont_files=("$@")

  local con_genomes_file=$(mktemp /tmp/irap_temp_con_genomes.XXXXXX.fa)

  for con_g_file in "${cont_files[@]}"
  do
    if [[ "$con_g_file" =~ \.gz$ ]]
    then
      gunzip -c "$con_g_file" >> "$con_genomes_file"
    else
      cat "$con_g_file" >> "$con_genomes_file"
    fi
  done
  mkdir -p "$data_dir_name/contamination"
  source "$IRAP_OPT/irap_setup.sh"
  "$IRAP_OPT/scripts/irap_add2contaminationDB" -n "$con_genomes_index_name" -f "$con_genomes_file" -d "$data_dir_name/$index_dir_name/"
}

# require at leaest 1 argument
if [ $# -eq 0 ];
then
  echo ""
  echo "Error: No arguments" >&2
  usage >&2
  exit 1
fi

# processing the inputs
while getopts ":hR:g:s:r:c:i:o:m:" opt; do
  case $opt in
    h ) usage
        exit 0 ;;
    R ) REF="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    g ) GTF="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    s ) SPECIES="$OPTARG" ;;
    r ) if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi
        RAW_READ_FILES+=("$OPTARG") ;;
    c ) CONFIG_FILE="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    i ) IRAP_PARA+=("$OPTARG") ;;
    o ) EXP_NAME="$OPTARG" ;;
    m ) CONTAMINATION_FILES+=("$OPTARG") ;;
    \? ) echo ""
        echo "Error: Unimplemented option: -$OPTARG" >&2
        usage >&2
        exit 1 ;;
    : ) echo ""
        echo "Error: Option -$OPTARG needs an argument." >&2
        usage >&2
        exit 1 ;;
    * ) usage >&2
        exit 1 ;;
  esac
done

# check mandatory options:
if [ "-$REF" == "-" ]; then echo "Error: missing mandatory parameter -R." >&2; exit 1; fi
if [ "-$GTF" == "-" ]; then echo "Error: missing mandatory parameter -g." >&2; exit 1; fi
if [ "-$SPECIES" == "-" ]; then echo "Error: missing mandatory parameter -s." >&2; exit 1; fi
if [ ${#RAW_READ_FILES[@]} == 0 ]; then echo "Error: missing mandatory parameter -r." >&2; exit 1; fi

if [ "-$CONFIG_FILE" == "-" ] && [ ${#IRAP_PARA[@]} == 0 ];
then
  echo "Error: -c or -i must be specified." >&2
  exit 1
fi

if [ "-$CONFIG_FILE" == "-" ];  # "conf=" is mandatory for iRAP
then
  CONFIG_FILE=$(mktemp /tmp/irap_temp_conf.XXXXXX)
fi

if [ "-$EXP_NAME" == "-" ]; then EXP_NAME="irap_analysis"; fi

set -xue

DATA_DIR_NAME="irap_data"

prepare_input_dir "$DATA_DIR_NAME" "$REF" "$GTF" "$SPECIES"  "$EXP_NAME"  "${RAW_READ_FILES[@]}"

# set up contamination db
set +u
if [ ${#CONTAMINATION_FILES[@]} != 0 ]
then
  # set up contamination database
  CON_GENOMES_INDEX_NAME="con_genomes"
  CON_GENOMES_INDEX_DIR_NAME="contamination"
  setup_contamination_db "$DATA_DIR_NAME" "$CON_GENOMES_INDEX_DIR_NAME" "$CON_GENOMES_INDEX_NAME" "${CONTAMINATION_FILES[@]}"
  IRAP_PARA+=("cont_index=$(realpath "$DATA_DIR_NAME")/$CON_GENOMES_INDEX_DIR_NAME/$CON_GENOMES_INDEX_NAME")
fi
set -u

if tar tf "$GTF" 2> /dev/null 1>&2
then
  GTF_FILE=$(tar tzf "$GTF" --wildcards "*gtf" | grep -v "exon_id\.gtf$")
  if [ "$(echo "$GTF_FILE" | wc -l)" != 1 ]
  then
    echo "find none or more reference GTF file in $GTF" >&2
    exit 1
  fi
else
  GTF_FILE=$(basename "$GTF")
fi

# start irap
set +u  # IRAP_PARA could be un-defined
REF_FILE_NAME="$(basename "$REF")"

cat >$CONFIG_FILE <<EOF
species=$SPECIES
reference=$REF_FILE_NAME
gtf_file=$GTF_FILE
name=$EXP_NAME
data_dir=$DATA_DIR_NAME
EOF

for opt_prm in "${IRAP_PARA[@]}"; do
    echo $opt_prm >> $CONFIG_FILE
done

xvfb-run irap conf=$CONFIG_FILE 1> >(tee -a $EXP_NAME.log) 2> >(tee -a $EXP_NAME.err >&2)

set -u
# following lines were added for Dockstore
echo "cleaning symbolic links"
find -type l -delete  # delete symbolic links, as some time they are pointing to non-existing files
echo "deleting fastq files"
find "$EXP_NAME" -name '*.fastq' -print0 | xargs -0 -I {} bash -c 'echo "deleting:" {}; /bin/rm {}'
echo "deleting fastq.gz files"
find "$EXP_NAME" -name '*.fastq.gz' -print0 | xargs -0 -I {} bash -c 'echo "deleting:" {}; /bin/rm {}'
echo "deleting tmp bam files"
find "$EXP_NAME" -name '*.tmp.bam' -print0 | xargs -0 -I {} bash -c 'echo "deleting:" {}; /bin/rm {}'
echo "deleting bam sorted by name"
find "$EXP_NAME" -name '*hits.byname.bam' -print0 | xargs -0 -I {} bash -c 'echo "deleting:" {}; /bin/rm {}'
echo "Copy log files"
cp $EXP_NAME.log $EXP_NAME.err $EXP_NAME
# tar ball the whole output directory as Dosckstore can not upload whole directory to S3 for now. s3cmd-plugin version 0.0.7
tar -zcvf "$EXP_NAME.tar.gz" "$EXP_NAME" && md5sum "$EXP_NAME.tar.gz" > "$EXP_NAME.tar.gz.md5"
# delete the output after data is archived otherwise data remains on instance if same instance is used for another wr job
echo "cleaning the instance"
/bin/rm -rf "$EXP_NAME"
