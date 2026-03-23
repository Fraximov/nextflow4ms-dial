# MS-DIAL 5 on macOS: Thermo RAW to mzML

This note documents the integrated Thermo RAW preprocessing path for the MS-DIAL 5-only Nextflow variant and the commands that were validated on macOS.

## Summary

- Direct Thermo `.raw` import did not work with the MS-DIAL 5 Linux console used by `main_msdial5.nf`.
- The pipeline now preprocesses Thermo `.raw` files by converting them to `.mzML` with ThermoRawFileParser.
- Existing `.mzML` and `.abf` inputs are passed through unchanged.
- The reference filename in the staged MS-DIAL parameter file is updated automatically when the selected reference input is a Thermo RAW file.

## Validated Tool

- Docker image: `quay.io/biocontainers/thermorawfileparser:2.0.0.dev--h9ee0642_0`
- Converter command inside the container: `ThermoRawFileParser`

## Integrated Pipeline Behavior

- If an input file ends in `.raw`, the pipeline converts it to `.mzML` before MS-DIAL 5 runs.
- If an input file ends in `.mzML` or `.abf`, the pipeline copies it into the prepared input directory unchanged.
- Other files in the input directory are ignored so MS-DIAL sidecar files from previous runs are not fed back as inputs.

## Run the MS-DIAL 5 Pipeline

The `--ref` file must point to one of the files in `--input_dir`.

- If `--ref` is a Thermo `.raw` file, the pipeline rewrites the staged MS-DIAL parameter file so the reference filename becomes the converted `.mzML` basename automatically.
- If `--ref` is already `.mzML` or `.abf`, the reference filename is preserved.

Validated command using Thermo RAW input directly:

```bash
nextflow run main_msdial5.nf -profile functional_test \
  --input_dir tmp/mtbls334/raw_data \
  --ref tmp/mtbls334/raw_data/10A_Lean.raw \
  --msdial_config tmp/mtbls334/msdial_params_mtbls334.txt
```

## Outputs

The MS-DIAL 5-only pipeline publishes alignment outputs in `results/ms-dial/`:

- `AlignResult*.mdalign`
- `AlignResult*.mdmsp`
- `AlignResult*.mzTabM`

From the validated MTBLS334 Thermo RAW test run:

- `results/ms-dial/AlignResult-20263211045.mdalign`
- `results/ms-dial/AlignResult-20263211045.mdmsp`
- `results/ms-dial/AlignResult-20263211045.mzTabM`

## Notes

- This workflow is for the MS-DIAL 5-only variant in `main_msdial5.nf`.
- It skips MS-FLO.
- On macOS, the integrated Thermo RAW preprocessing path in `main_msdial5.nf` is the reliable workflow that was validated here.
