$graph:
- class: CommandLineTool
  id: '#get_urls.cwl'
  inputs:
  - id: '#get_urls.cwl/catalog'
    inputBinding:
      prefix: --catalog
    type:
    - 'null'
    - string
  - id: '#get_urls.cwl/collection'
    inputBinding:
      prefix: --collection
    type:
    - 'null'
    - string
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/figi44/eoap/get_urls:main
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
  outputs:
  - id: '#get_urls.cwl/ids'
    outputBinding:
      glob: ids.txt
      loadContents: true
      outputEval: $(self[0].contents.split('\n'))
    type:
      items: string
      type: array
  - id: '#get_urls.cwl/urls'
    outputBinding:
      glob: urls.txt
      loadContents: true
      outputEval: $(self[0].contents.split('\n'))
    type:
      items: string
      type: array
- class: Workflow
  id: '#main'
  inputs:
  - id: '#main/catalog'
    label: catalog
    doc: full catalog path
    default: supported-datasets/ceda-stac-fastapi
    type: string
  - id: '#main/collection'
    label: collection id
    doc: collection id
    default: sentinel2_ard
    type: string
  outputs: []
  label: Resize collection cogs
  doc: Resize collection cogs
  steps:
  - id: '#main/get_urls'
    in:
    - id: '#main/get_urls/catalog'
      source: '#main/catalog'
    - id: '#main/get_urls/collection'
      source: '#main/collection'
    out:
    - id: '#main/get_urls/urls'
    - id: '#main/get_urls/ids'
    run: '#get_urls.cwl'
cwlVersion: v1.0
