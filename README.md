Heppy : a python framework for high-energy physics data analysis
================================================================

Heppy (High Energy Physics with PYthon) is a modular python framework for the analysis of collision events.

If you're not very familiar with python yet, you will probably find the [Python Tutorial](https://docs.python.org/2.7/tutorial/) useful before you get started with heppy.

Table of contents:
master
1. [Installation](doc/Heppy_-_Installation_Instructions.md)
1. [Introduction](doc/Heppy_-_Introduction.md)
1. [A very simple example](doc/Heppy_-_a_very_simple_example.md)
1. [Parallel processing: running jobs](doc/Heppy_-_Parallel_Processing.md)
1. [Full analysis workflows](doc/Heppy_-_Full_analysis_workflows.md)
1. [Reference guide](http://fcc-support-heppy.web.cern.ch/fcc-support-heppy/)
1. [Generic analyses: working in several experiments](doc/particles.md)
1. [Papas, the parametrized particle simulation](doc/papas_-_The_PArametrized_PArticle_Simulation.md)

Support & feedback: [https://github.com/cbernet]()

Testing CONDOR batch system
===========================

1. Log into `lxplus`

   ```
   $ ssh lxplus
   ```

   Note: `lxplus` alias switched to **CC7** on Apr 2nd 2019 - More info at [http://cern.ch/go/K7lq](http://cern.ch/go/K7lq)

2. Get this version of `heppy`

   ```
   $ git clone https://github.com/javiercvilla/heppy
   $ cd heppy
   $ git checkout heppy-condor
   ```

3. Prepare the environment, the following script sources:

  - A view of the LCG Release `LCG_94`
  - A view of the FCC externals `94.2.0`
  - This version of `heppy`, overrading the one provided by the `94.2.0`

   ```
   $ source init.sh
   ```

4. If you want to run an analysis from the `FCChhAnalyses` package, clone it on the parent directory and copy the `FCChhAnalyses` folder inside `heppy` as we only need the python module:

   ```
   # Clone it on the parent directory
   $ git clone https://github.com/hep-fcc/FCChhAnalyses ../FCChhAnalyses

   # Get the module and copy it inside `heppy`
   $ cp -r ../FCChhAnalyses/FCChhAnalyses/ .
   ```

5. Run the analysis:

   ```
   heppy_batch.py -o Outdir FCChhAnalyses/HELHC/Zprime_tt/analysis.py -b 'run_condor.sh --bulk Outdir -f microcentury' --nevent 1000
   ```

That should prepare a bunch of "Chunk" directories inside `Outdir` and submit a job to HTCondor.

**Note: Assumptions to be fixed**

- `FCChhAnalyses` folder needs to be inside `heppy`
- Current configuration assumes that the script `run_condor.sh` is located inside the `script` folder
- The output directory specified passed to the `heppy_batch.py` command with the `-o` option AND the name specified in the `--bulk` option to the `run_condor.sh` script HAS TO be the same.
- If `heppy` does not create "Chunk" directories inside the output directory, then the `heppy_batch.py` command will prepare everything but the final submission. In this case, users will be asked to modify the description file (`.cfg`). For example, the analysis `FCChhAnalyses/FCChh/tttt` does not produce "Chunk" directories due to this [line](https://github.com/HEP-FCC/FCChhAnalyses/blob/master/FCChhAnalyses/FCChh/tttt/analysis.py#L77), instead it creates a folder called `example`. After replacing the `queue` command at the very end of the description file (`.cfg`) users can submit the job manually running:

   ```
   condor_submit <description_filename>
   ```

   where `<description_filename>` should be something like `jobs_desc_Outdir.cfg` or similar.


------------------


New CONDOR batch :
-----------------
submit example :

```
heppy_batch.py -o Outdir FCChhAnalyses/FCChh/tttt/analysis.py -b 'run_condor.sh --bulk Outdir -f microcentury' --nevent 1000
```

In this example, CONDOR will look at all directories (could be Chunk too) in `Outdir` (`--bulk Outdir`) and run jobs for all of them into a single job. For example here, 10 jobs are coming from `FCChhAnalyses/FCChh/tttt/analysis.py`. And each job will be run on 1000 evenmts.

```
[djamin@lxplus037 heppy]$ condor_q


-- Schedd: bigbird09.cern.ch : <188.185.71.142:9618?... @ 03/05/19 15:13:52
OWNER  BATCH_NAME        SUBMITTED   DONE   RUN    IDLE  TOTAL JOB_IDS
djamin CMD: batchScri   3/5  15:05      4      6      _     10 594302.1-9


run_condor.sh has been added in the new script/ directory
```

Instead of flavour (`-f`), it is possible to use `maxruntime` (unit = minute) : `-t 60`

Predefined timing jobs are done from flavour :

 20 mins -> espresso
 1h -> microcentury
 2h -> longlunch
 8h -> workday
 1d -> tomorrow
 3d -> testmatch
 1w -> nextweek

If job fails, can resubmit each failed job with :

```
heppy_check.py Outdir/*Chunk* -b 'run_condor.sh -f microcentury'
```

FCC actually have their own quota. To use it, you need to get yourself added to the egroup:

```
fcc-experiments-comp
```

Then you can add the following to your submit file:

```
+AccountingGroup = "group_u_FCC.local_gen"
```
