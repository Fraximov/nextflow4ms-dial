# Nextflow MS-DIAL 5 Workflow

**Nextflow pipeline for reproducible untargeted metabolomics data processing with MS-DIAL 5.**

This repository is now documented primarily around the MS-DIAL 5 workflow in `main_msdial5.nf`. The legacy MS-DIAL 4 plus MS-FLO pipeline still exists in the codebase, but this README focuses on the MS-DIAL 5 path.

## Overview

- Entrypoint: `main_msdial5.nf`
- Processing engine: official MS-DIAL 5 Linux console release
- Supported input files: `.mzML`, `.abf`, and Thermo `.raw`
- Thermo `.raw` handling: converted automatically to `.mzML` before MS-DIAL 5 runs
- Main outputs: `AlignResult*.mdalign`, `AlignResult*.mdmsp`, `AlignResult*.mzTabM`

## Installation

1. Install Java 11 or newer.
2. Install [Nextflow](https://www.nextflow.io/).
3. Install either Docker or Singularity.

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/Nextflow4Metabolomics/nextflow4ms-dial.git
   cd nextflow4ms-dial
   ```

2. Run the validated example dataset:
   ```bash
   nextflow run main_msdial5.nf -profile functional_test
   ```

## Run Your Own Data

You need:

- an input directory containing `.mzML`, `.abf`, or Thermo `.raw` files
- an MS-DIAL parameter file
- an MS1 library file
- an MS2 library file

Example with `.mzML` input:

```bash
nextflow run main_msdial5.nf -profile docker \
  --input_dir data/raw_data \
  --ref data/raw_data/sample_01.mzML \
  --msdial_config data/msdial_params.txt \
  --ms1_library data/ms1_lib.txt \
  --ms2_library data/MSMS-Pos-MassBank.msp
```

Example with Thermo `.raw` input:

```bash
nextflow run main_msdial5.nf -profile docker \
  --input_dir data/raw_data \
  --ref data/raw_data/sample_01.raw \
  --msdial_config data/msdial_params.txt \
  --ms1_library data/ms1_lib.txt \
  --ms2_library data/MSMS-Pos-MassBank.msp
```

## Input Handling

- `.raw` files are converted to `.mzML` inside the workflow with ThermoRawFileParser.
- `.mzML` and `.abf` files are passed through unchanged.
- Non-input artifacts in the input directory, such as old MS-DIAL sidecar files, are ignored.
- `--ref` must point to one of the files present in `--input_dir`.
- If `--ref` is a Thermo `.raw` file, the staged MS-DIAL parameter file is rewritten automatically so the reference filename matches the converted `.mzML`.

## Outputs

The MS-DIAL 5 workflow publishes results in `results/ms-dial/`:

- `AlignResult*.mdalign`
- `AlignResult*.mdmsp`
- `AlignResult*.mzTabM`

Nextflow execution metadata is written to `results/pipeline_info/`:

- `execution_report.html`
- `execution_timeline.html`
- `execution_trace.txt`
- `pipeline_dag.svg` when Graphviz is available

## Configuration

Key runtime parameters are defined in `nextflow.config` and the profile configs under `conf/`.

Important parameters:

- `--input_dir`
- `--ref`
- `--msdial_config`
- `--ms1_library`
- `--ms2_library`
- `--msdial5_release_url`
- `--thermorawfileparser_image`

Profiles:

- `docker`: local Docker execution
- `functional_test`: validated test profile
- `ci_test`: lighter CI-oriented test profile
- `singularity`: HPC-oriented profile using `conf/HiPerGator.config`

## Additional Documentation

- Thermo RAW preprocessing and MS-DIAL 5 usage: `docs/MSDIAL5_RAW_TO_MZML.md`

## Validation

The MS-DIAL 5 workflow was validated with:

```bash
nextflow run main_msdial5.nf -profile functional_test
```

and with direct Thermo RAW input:

```bash
nextflow run main_msdial5.nf -profile functional_test \
  --input_dir tmp/mtbls334/raw_data \
  --ref tmp/mtbls334/raw_data/10A_Lean.raw \
  --msdial_config tmp/mtbls334/msdial_params_mtbls334.txt
```

## Credits

The original `nextflow4ms-dial` project was mainly developed by Xinsong Du, with important conceptual contributions from Dr. Dominick Lemas.
