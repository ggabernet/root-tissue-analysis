// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process RATIOCONV {
    //tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }
    container "ghcr.io/waseju/fiji:latest"
    containerOptions "--network=none"

    input:
    path input

    output:
    path("*ratios") , emit: ratios
    path("*brightfields") , emit: brightfields

    script:
    def software = getSoftwareName(task.process)
    """
    mkdir output
    xvfb-run -a ImageJ-linux64 --run ratio_macro.ijm 'inDir="$input/",outDir="output/"'
    mkdir ratios
    mkdir brightfields
    mv output/*_ratio.tif ratios/
    mv output/*.tif brightfields/
    """
}
