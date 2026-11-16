process CYTOTABLE_REPORTS {
    tag "${meta.batch}_${meta.plate}"
    label 'process_single'

    container {
        workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/pip_marimo_pandas_pyarrow:6d8064fc827cc69f' :
        'community.wave.seqera.io/library/pip_marimo_pandas_pyarrow:26ccb9ec3953c76e'
    }

    input:
    tuple val(meta), path(parquet_file)

    output:
    tuple val(meta), path("*_reports.py"),                    emit: app
    tuple val(meta), path("*_metadata.json"),                  emit: metadata
    tuple val(meta), path("*_descriptive_stats.parquet"),      emit: stats
    tuple val(meta), path("*_{size_distributions,dna_intensity}.png"), emit: plots
    tuple val(meta), path("*_reports.html"),                  emit: html
    tuple val(meta), path("*_reports.ipynb"), emit: notebook, optional: true
    tuple val(meta), path("*_reports.md"),    emit: markdown, optional: true
    tuple val("${task.process}"), val('marimo'), eval("python -c \"import importlib.metadata as im; print(im.version('marimo'))\""), topic: versions, emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    template 'cytotable_reports.sh'

    stub:
    def prefix = task.ext.prefix ?: "${meta.batch}_${meta.plate}"
    """
    touch ${prefix}_reports.py
    touch ${prefix}_reports.html
    touch ${prefix}_reports.ipynb
    touch ${prefix}_reports.md
    touch ${prefix}_metadata.json
    touch ${prefix}_descriptive_stats.parquet
    touch ${prefix}_size_distributions.png
    touch ${prefix}_dna_intensity.png
    """
}
