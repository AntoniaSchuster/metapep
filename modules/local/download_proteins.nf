process DOWNLOAD_PROTEINS {
    tag "$microbiome_ids"
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::biopython=1.78" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.78' :
        'quay.io/biocontainers/biopython:1.78' }"

    input:
    val    microbiome_ids
    path   microbiome_files

    output:
    path    "proteins.entrez.tsv.gz"            , emit:  ch_entrez_proteins
    path    "taxa_assemblies.tsv"               , emit:  ch_entrez_assemblies
    path    "entities_proteins.entrez.tsv"      , emit:  ch_entrez_entities_proteins  // protein_tmp_id (accessionVersion), entity_name (taxon_id)
    path    "microbiomes_entities.entrez.tsv"   , emit:  ch_entrez_microbiomes_entities  // entity_name, microbiome_id, entity_weight
    path    "versions.yml"                      , emit:  versions

    script:
    def key = params.ncbi_key
    def email = params.ncbi_email
    def microbiome_ids = microbiome_ids.join(' ')
    """
    # provide new home dir to avoid permission errors with Docker and other artefacts
    export HOME="\${PWD}/HOME"
    download_proteins_entrez.py --email $email \\
                                --key $key \\
                                -t $microbiome_files \\
                                -m $microbiome_ids \\
                                -p proteins.entrez.tsv.gz \\
                                -ta taxa_assemblies.tsv \\
                                -ep entities_proteins.entrez.tsv \\
                                -me microbiomes_entities.entrez.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
