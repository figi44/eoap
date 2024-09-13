class: Workflow
id: resize-collection
inputs:
- id: catalog
  label: catalog
  doc: full catalog path
  default: supported-datasets/ceda-stac-fastapi
  type: string
- id: collection
  label: collection id
  doc: collection id
  default: sentinel2_ard
  type: string
outputs: []
label: Resize collection cogs
doc: Resize collection cogs
cwlVersion: v1.0
steps:
- id: get_urls
  in:
  - id: catalog
    source: resize-collection/catalog
  - id: collection
    source: resize-collection/collection
  out:
  - id: urls
  - id: ids
  run: /home/runner/work/eoap/eoap/eoap-gen-out/cli/get_urls/get_urls.cwl
