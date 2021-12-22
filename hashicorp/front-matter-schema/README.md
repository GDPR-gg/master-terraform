# Front Matter Schema Checker

This Github Action checks the schema of YAML front matter.

## Usage

```yaml
---
 name: Check Front Matter
 on: [push]

 jobs:
   front-matter:
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v2
         with:
           fetch-depth: 0
       - name: Get changed files
         id: changed-files
         uses: tj-actions/changed-files@v1.1.3
         with:
           separator: ","
       - name: Front Matter
         id: lint
         uses: hashicorp/front-matter-schema@main
         with:
           files: ${{ steps.changed-files.outputs.all_modified_files }}
           directories: |
             items
           schema: |
             {
               "properties": {
                   "title": {
                      "type": "string",
                      "required": true
                 }
               }
             }
```

> Given Github Actions not supporting multi-dimensional inputs like hashes, I'm just passing the `schema` in as raw JSON. This could however be the output of another step as well. 
