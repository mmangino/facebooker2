require 'spec_helper'
require 'jslint_on_rails'

def be_lintable
  ::Spec::Matchers::Matcher.new :be_lintable do
    match do |actual|
      tmp_js_output = Tempfile.new 'output.js'
      tmp_js_output.puts(actual)
      lint = JSLint::Lint.new(
        :paths => [tmp_js_output.path]
      )
      lint.run
      true
    end
  end
end
