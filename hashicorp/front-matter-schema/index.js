const core = require("@actions/core");
const slugify = require("slugify");
const frontmatter = require('@github-docs/frontmatter');
const fs = require("fs").promises;

/**
 * Checks changed files against relevant directories.
 *
 * @param files
 * @param directories
 * @returns {boolean}
 */
const filesInDirectories = (files, directories) =>
  files.length &&
  files
    .split(",")
    .some((file) => directories.some((directory) => file.includes(directory)));

async function action() {
  const files = core.getInput("files", { required: true });
  const directories = core.getMultilineInput("directories", { required: true });
  const schema = JSON.parse(core.getInput("schema", { required: true }));

  // Check that the modified file is in a watched directory
  if (files.length && filesInDirectories(files,directories)) {
    for (const target of files.split(",")) {
      //core.notice(`Loading file ${target}...`);
      console.log(`Loading file ${target}...`);

      // Load markdown file as string
      const markdown = (await fs.readFile(target)).toString();

      // Check the Markdown against the schema and return any errors
      //core.notice(`Testing Markdown schema...`);
      console.log(`Testing Markdown schema...`);
      const { data, content, errors } = frontmatter(markdown,{schema,target});

      if (errors && errors.length > 0) {
        console.log(errors);
        core.error(errors[0].message);
        core.setFailed(JSON.stringify(errors));
      }

      // Set the output of the action to be the metadata
      for (let k in data) {
        core.setOutput(slugify(k, { lower: true, strict: true }), data[k]);
      }
    }
  }
}

if (require.main === module) {
  action();
}

module.exports = action;
