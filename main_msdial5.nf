#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/**
    A Nextflow-based reproducible pipeline for untargeted metabolomics data analysis
    Description  : MS-DIAL 5-only variant of RUMP for untargeted metabolomics data processing
    Author       : Xinsong Du
    Creation Date: 11/01/2022
    License      : MIT License

    This script is free software: you can redistribute it and/or modify
    it under the terms of the MIT License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    MIT License for more details.

    You should have received a copy of the MIT License
    along with this script. If not, see <https://opensource.org/licenses/MIT>.
*/

version='1.0dev-msdial5'
timestamp='20260320'

def msdial5ReleaseUrl = params.msdial5_release_url ?: 'https://github.com/systemsomicslab/MsdialWorkbench/releases/download/MSDIAL-v5.5.251021/MSDIAL.console.v5.5.251021-linux-net8.zip'

println "Project : $workflow.projectDir"
println "Git info: $workflow.repository - $workflow.revision [$workflow.commitId]"
println "Cmd line: $workflow.commandLine"
println "Manifest's pipeline version: $workflow.manifest.version"

if (params.help) {
    System.out.println("")
    System.out.println("MS-DIAL 5-only variant for untargeted metabolomics data analysis - Version: $version ($timestamp)")
    System.out.println("This variant runs MS-DIAL 5 only and does not execute MS-FLO post-processing.")
    System.out.println("")
    System.out.println("Usage:")
    System.out.println("   nextflow run main_msdial5.nf -profile [options: functional_test; docker; singularity]")
    System.out.println("")
    System.out.println("Arguments:")
    System.out.println("    -profile                                docker, singularity, or functional_test")
    System.out.println("    --msdial5_release_url                   official MS-DIAL 5 Linux console zip URL")
    System.out.println("    --help                                  whether to show help information or not, default is null")
    System.out.println("")
    exit 1
}

custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
    custom_runName = workflow.runName
}

def summary = [:]
summary['Pipeline Name']  = 'RUMP MS-DIAL 5'
if(workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Run Name']         = custom_runName ?: workflow.runName
summary['Input']            = params.input
summary['MS-DIAL 5 URL']    = msdial5ReleaseUrl
summary['Max Resources']    = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
if (workflow.containerEngine) summary['Container'] = "$workflow.containerEngine - $workflow.container"
summary['Output dir']       = params.outdir
summary['Launch dir']       = workflow.launchDir
summary['Working dir']      = workflow.workDir
summary['Script dir']       = workflow.projectDir
summary['User']             = workflow.userName
summary['Config Profile']   = workflow.profile
summary['Config Files']     = workflow.configFiles.join(', ')
log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"

process msdial5_download {

    output:
    path "msdial5", emit: msdial5

    shell:
    """
    wget -O msdial5.zip "${msdial5ReleaseUrl}" &&
    unzip -q msdial5.zip -d msdial5 &&
    chmod +x msdial5/MSDIALCUI
    """
}

process peak_detection_msdial5 {

    debug true

    publishDir './results/'

    input:
    path msdial5
    path msdial_config
    path data
    path ms1_lib
    path ms2_lib
    path ref

    output:
    path "ms-dial/AlignResult*.mdalign", emit: msdial_result
    path "ms-dial/AlignResult*.mdmsp", emit: msdial_spectra
    path "ms-dial/AlignResult*.mzTabM", emit: msdial_mztabm
    stdout emit: msdial_result_log

    shell:
    """
    echo "peak detection via MS-DIAL 5 software" &&
    mkdir "ms-dial" &&
    cp -L ${msdial_config} "ms-dial" &&
    cp -L ${ms1_lib} "ms-dial" &&
    cp -L ${ms2_lib} "ms-dial" &&
    cp -L ${ref} "ms-dial" &&
    cp -rL ${data} "ms-dial" &&
    cp -rL ${msdial5} "ms-dial" &&
    cd "ms-dial" &&
    chmod +x ./msdial5/MSDIALCUI &&
    ./msdial5/MSDIALCUI lcms -i ${data} -o ./ -m ${msdial_config}
    """
}

workflow {
    msdial5_download()

    peak_detection_msdial5(
        msdial5_download.out.msdial5,
        Channel.fromPath(params.msdial_config),
        Channel.fromPath(params.input_dir, type: 'dir'),
        Channel.fromPath(params.ms1_library),
        Channel.fromPath(params.ms2_library),
        Channel.fromPath(params.ref)
    )
}
