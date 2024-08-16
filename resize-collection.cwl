cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: resize-collection
    label: Resize collection cogs
    doc: Resize collection cogs
    requirements:
      - class: ScatterFeatureRequirement
    inputs:
      catalog:
        label: catalog
        doc: full catalog path
        type: string
        default: "supported-datasets/ceda-stac-fastapi"
      collection:
        label: collection
        doc: collection id
        type: string
        default: "sentinel2_ard"
    outputs:
      - id: stac_output
        outputSource:
          - stac_step/stac_catalog
        type: Directory
    steps:
      get_urls_step:
        run: "#get_urls_cmd"
        in:
          catalog: catalog
          collection: collection
        out:
          - urls
          - ids
      resize_step:
        run: "#resize_cmd"
        in:
          url: get_urls_step/urls
          id: get_urls_step/ids
        scatter:
          - url
          - id
        scatterMethod: dotproduct
        out:
          - resized
      stac_step:
        run: "#stac_cmd"
        in:
          items: resize_step/resized
        out:
          - stac_catalog

  - class: CommandLineTool
    id: get_urls_cmd
    requirements:
      InlineJavascriptRequirement: {}
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/figi44/eoap/get_urls:main
    baseCommand:
      - python
      - /app/app.py
    inputs:
      catalog:
        type: string
        inputBinding:
          prefix: --catalog
      collection:
        type: string
        inputBinding:
          prefix: --collection
    outputs:
      urls:
        type: string[]
        outputBinding:
          loadContents: true
          glob: urls.txt
          outputEval: $(self[0].contents.split('\n'))
      ids:
        type: string[]
        outputBinding:
          loadContents: true
          glob: ids.txt
          outputEval: $(self[0].contents.split('\n'))

  - class: CommandLineTool
    id: resize_cmd
    requirements:
      InlineJavascriptRequirement: {}
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/osgeo/gdal:ubuntu-small-latest
    baseCommand: gdal_translate
    inputs:
      url:
        type: string
        inputBinding:
          position: 1
          prefix: /vsicurl/
          separate: false
      id:
        type: string
        inputBinding:
          position: 2
          valueFrom: $(self + "_resized.tif")
      outsize_x:
        type: string
        inputBinding:
          position: 3
          prefix: -outsize
        default: 5%
      outsize_y:
        type: string
        inputBinding:
          position: 4
        default: 5%
    outputs:
      resized:
        type: File
        outputBinding:
          glob: "*.tif"

  - class: CommandLineTool
    id: stac_cmd
    requirements:
      InlineJavascriptRequirement: {}
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/figi44/eoap/make_stac:main
    baseCommand:
      - python
      - /app/app.py
    inputs:
      items:
        type: File[]
        inputBinding: {}
    outputs:
      stac_catalog:
        outputBinding:
          glob: .
        type: Directory
