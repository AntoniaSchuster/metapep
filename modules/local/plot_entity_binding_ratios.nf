process PLOT_ENTITY_BINDING_RATIOS {
    label 'cache_lenient'
    label 'process_medium_memory'

    conda (params.enable_conda ? "bioconda::bioconductor-alphabeta:1.8.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-alphabeta:1.8.0--r41hdfd78af_0' :
        'quay.io/biocontainers/bioconductor-alphabeta:1.8.0--r41hdfd78af_0' }"

    publishDir "${params.outdir}/figures", mode: params.publish_dir_mode

    input:
    tuple val(meta), path(prep_entity_binding_ratios)

    output:
    path "entity_binding_ratios.*.png",     emit:   ch_plot_entity_binding_ratios
    path "versions.yml",                    emit:   versions

    script:
    """
    plot_entity_binding_ratios.R \\
        $prep_entity_binding_ratios \\
        $meta.alleles

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot2')))")
        data.table: \$(Rscript -e "library(data.table); cat(as.character(packageVersion('data.table')))")
        dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        stringr: \$(Rscript -e "library(stringr); cat(as.character(packageVersion('stringr')))")
    END_VERSIONS
    """
}
