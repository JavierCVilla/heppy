#!/bin/bash

# Read input arguments
if [[ "$1" == "--help" || "$1" == "-h"  || "$1" == "-?" ]]; then
    echo "usage: $0 [ -f flavour | -t max_runtime_in_minutes ] script.sh "
    exit 1;
fi

bulk=""
if [[ "$1" == "--bulk" ]]; then
    bulk=$2; shift; shift;
fi

flavour=""
if [[ "$1" == "-f" && "$2" != "" ]]; then
    flavour=$2;
    shift; shift
fi
maxruntime="-t" # time in minutes
if [[ "$1" == "-t" && "$2" != "" ]]; then
    if [[ "${flavour}" != "" ]]; then 
        echo "Can't set both flavour and maxruntime"; 
        exit 1; 
    fi;
    maxruntime=$(( $2 * 60 ));
    shift; shift
fi

here=$(pwd)
if [[ "$bulk" != "" ]]; then
    # Remove slashes for cases "dirA/dirB"
    bulk_name=${bulk//"/"/-}
    jobdesc="jobs_desc_${bulk_name}.cfg"
    prefix="\$(Chunk)/";
    here="$here/\$(Chunk)"
else
    jobdesc="job_desc.cfg"
    prefix=""
fi;

scriptName=${1:-./batchScript.sh}

# SLCern6 -> CentOS7 when ready
# requirements:  (Machine =!= LastRemoteHost) 
cat > $jobdesc <<EOF
Executable     = ${prefix}${scriptName}
Log            = ${prefix}condor_job_\$(ProcId).log
Output         = ${prefix}condor_job_\$(ProcId).out
Error          = ${prefix}condor_job_\$(ProcId).error
getenv         = True
environment    = "LS_SUBCWD=${here}"
request_memory = 2G
requirements   = (OpSysAndVer =?= "CentOS7") 
on_exit_remove = (ExitBySignal == False) && (ExitCode == 0)
max_retries    = 3
+AccountingGroup = "group_u_FCC.local_gen"
EOF

[[ "${flavour}" != "" ]] && echo "+JobFlavour = \"${flavour}\"" >> $jobdesc
[[ "${maxruntime}" != "" ]] && [[ "${maxruntime}" != "-t" ]] && echo "+MaxRuntime = ${maxruntime}" >> $jobdesc

if [[ "$bulk" != "" ]]; then
    # Check if $bulk exists as a directory
    if [ -d $bulk ]; then
      # Check if heppy has created "*_Chunk*" dirs inside the output directory
      # The following expression will be True if any directory contains 
      # "_Chunk" as part of its name 
      if ls $bulk/*_Chunk* 1> /dev/null 2>&1; then
        echo "queue Chunk matching dirs ${bulk}/*_Chunk*" >> $jobdesc
      else
        # TODO: Change this for a smarter checking
        # heppy could provide this information to this script
        queueCmd="queue Chunk matching dirs ${bulk}/<REPLACE>"
        echo $queueCmd >> $jobdesc
        echo ""
        echo "WARNING: The following INCOMPLETE command has been added to $jobdesc"
        echo
        echo $queueCmd
        echo 
        echo "Please, substitute \"<REPLACE>\" by the name of the directory inside \"$bulk\" created by Heppy"
        echo "It may be the following: "
        echo 
        dirname=`ls -lct $bulk | head -n 2 | tr -s " " | cut -d" " -f 9 | xargs`
        echo $bulk/$dirname
        echo 
        echo "Once modified run the followin command to submit the job:"
        echo "condor_submit $jobdesc"
        exit 1
      fi
    else
      echo "$bulk directory does not exist"
      echo "You need to specify the same output directory passed to heppy_batch.py"
      echo "Do you mean one of these?"
      echo `find . -maxdepth 2 -iname "$bulk"`
      exit 1
    fi
else
    echo "queue 1" >> $jobdesc
fi;

# Submit job
/usr/bin/condor_submit $jobdesc
