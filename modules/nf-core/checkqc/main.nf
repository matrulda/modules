process CHECKQC {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/checkqc:4.0.1--pyhdfd78af_0':
        'biocontainers/checkqc:4.0.1--pyhdfd78af_0' }"

    input:
    path(run_dir)
    path(checkqc_config)

    output:
    path "*checkqc_report.json", emit: report
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def config = checkqc_config ? "--config $checkqc_config" : ''

    """
    checkqc \
        $args \
        $config \
        --json \
        $run_dir > checkqc_report.json || test -s "checkqc_report.json"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkqc: \$( checkqc --version | sed -e "s/checkqc, version //g" )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch checkqc_report.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkqc: \$( checkqc --version | sed -e "s/checkqc, version //g" )
    END_VERSIONS
    """
}
