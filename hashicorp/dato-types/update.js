const signale = require('signale')
const fs = require('fs-extra')
const prettier = require('prettier')
const { loadSchema } = require('graphql-toolkit')
const { codegen } = require('@graphql-codegen/core')
const { printSchema, parse } = require('graphql')
const { plugin: typescriptPlugin } = require('@graphql-codegen/typescript')
const datoApiConfig = require('@hashicorp/nextjs-scripts/dato/config')

module.exports = async function updateTypes() {
  signale.await('Fetching graphql schema from DatoCMS...')
  const schema = await loadSchema(datoApiConfig.url, {
    headers: datoApiConfig.headers
  })
  signale.await('Creating Typescipt file...')
  const outputFile = 'index.d.ts'
  const config = {
    filename: outputFile,
    schema: parse(printSchema(schema)),
    plugins: [
      {
        typescript: {} // Here you can pass configuration to the plugin
      }
    ],
    pluginMap: {
      typescript: {
        plugin: typescriptPlugin
      }
    }
  }
  // codegen runs prettier by default, but it doesn't pick up our prettier
  // config correctly, so we need to run it again
  const prettierOptions = {
    parser: 'typescript',
    semi: false,
    singlequote: false
  }
  const output = prettier.format(await codegen(config), prettierOptions)
  fs.writeFileSync(outputFile, output)
  signale.success('Types updated from DatoCMS!')
  return output
}
