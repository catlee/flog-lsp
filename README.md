# FlogLsp

FlogLsp is an LSP server for running
[`flog`](https://github.com/seattlerb/flog) on your Ruby code, integrated into your code editor.

`flog` is a static code complexity analyzer for Ruby; it calculates a score for each method in the code being analyzed. A higher score indicates a higher level of complexity. Language constructs such as conditionals, loops, `.send`, etc. each contribute to the complexity of the code.

![image](https://github.com/catlee/flog-lsp/assets/54458/a9d733b3-acfe-4eb3-a0be-137a7c81aa79)

## Installation

TBH, installing and integrating this into your editor is a bit of a pain currently :( If you have ideas on how to improve, please let me know!

The gem needs to be installed via something like `gem install flog-lsp`. It exposes a commandline script named `flog-lsp`.

## Usage

Normally `flog-lsp` is run from your editor.

It supports a `-v` / `--verbose` flag to increase log verbosity.

## Configuration

The threshold overwhich `flog-lsp` warns about code that is too complex can be configured via the LSP's [initializationOptions](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initializeParams). For example, in neovim:
```
opts.init_options = {
  score_threshold = 15,
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/catlee/flog-lsp.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
