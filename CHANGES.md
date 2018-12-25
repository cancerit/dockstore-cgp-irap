##CHANGES

### 0.1.9
* modified wrapper to cleanup instance after archiving to avoid no space letf issue when same instance is used by WR
* added few custom amendements to qc_stats and wrapper script
### 0.1.8
* corrected Dockerfile
### 0.1.7 
* revrted to docker image 0.1.3 with updated wrapper for atlas_run option
### 0.1.6 
* Added irap-version 1.0.6b
### 0.1.5
* Updated CWL metadata, erquired to publish tool
### 0.1.4
* remove buid script
* added tagged docker image from Nuno

### 0.1.3
* fixed build script

### 0.1.2
* freads is changed to use proper TMPDIR instead of shared memory /dev/shm to load GTF, but this is not a stable fix.

### 0.1.1
* generating the log file will not affect stdout nor stderr

### 0.1.0
* Added log file output
* Removed fastq files from output
* Removed read-name sorted bam
