'use strict';

const EmberAddon = require('ember-cli/lib/broccoli/ember-addon');

module.exports = function(defaults) {
  let app = new EmberAddon(defaults, {
    codemirror: {
      addonFiles: [
        'selection/active-line.js'
      ],

      modes: [
        'apl',
        'asciiarmor',
        'asn.1',
        'asterisk',
        'clike',
        'clojure',
        'cmake',
        'cobol',
        'coffeescript',
        'commonlisp',
        'css',
        'cypher',
        'd',
        'dart',
        'diff',
        'django',
        'dockerfile',
        'dtd',
        'dylan',
        'ebnf',
        'ecl',
        'eiffel',
        'erlang',
        'forth',
        'fortran',
        'gas',
        'gfm',
        'gherkin',
        'go',
        'groovy',
        'haml',
        'haskell',
        'haxe',
        'htmlembedded',
        'htmlmixed',
        'http',
        'idl',
        'javascript',
        'jinja2',
        'julia',
        'livescript',
        'lua',
        'markdown',
        'mathematica',
        'mirc',
        'mllike',
        'modelica',
        'mumps',
        'nginx',
        'ntriples',
        'octave',
        'pascal',
        'pegjs',
        'perl',
        'php',
        'pig',
        'properties',
        'pug',
        'puppet',
        'python',
        'q',
        'r',
        'rpm',
        'rst',
        'ruby',
        'rust',
        'sass',
        'scheme',
        'shell',
        'sieve',
        'slim',
        'smalltalk',
        'smarty',
        'solr',
        'soy',
        'sparql',
        'spreadsheet',
        'sql',
        'stex',
        'tcl',
        'textile',
        'tiddlywiki',
        'tiki',
        'toml',
        'tornado',
        'troff',
        'ttcn',
        'ttcn-cfg',
        'turtle',
        'vb',
        'vbscript',
        'velocity',
        'verilog',
        'xml',
        'xquery',
        'yaml',
        'z80'
      ],

      keyMaps: [
        'emacs',
        'sublime',
        'vim'
      ],

      themes: [
        '3024-day',
        '3024-night',
        'ambiance',
        'ambiance-mobile',
        'base16-dark',
        'base16-light',
        'blackboard',
        'cobalt',
        'eclipse',
        'elegant',
        'erlang-dark',
        'lesser-dark',
        'mbo',
        'mdn-like',
        'midnight',
        'monokai',
        'neat',
        'neo',
        'night',
        'paraiso-dark',
        'paraiso-light',
        'pastel-on-dark',
        'rubyblue',
        'solarized',
        'the-matrix',
        'tomorrow-night-eighties',
        'twilight',
        'vibrant-ink',
        'xq-dark',
        'xq-light'
      ]
    }
  });

  /*
    This build file specifies the options for the dummy test app of this
    addon, located in `/tests/dummy`
    This build file does *not* influence how the addon or the app using it
    behave. You most likely want to be modifying `./index.js` or app's build file
  */

  app.import('node_modules/bootstrap/dist/css/bootstrap.min.css');

  return app.toTree();
};
