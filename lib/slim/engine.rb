module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options pretty: false,
                   sort_attrs: true,
                   format: :xhtml,
                   attr_quote: '"',
                   merge_attrs: {'class' => ' '},
                   generator: Temple::Generators::ArrayBuffer,
                   default_tag: 'div'

    filter :Encoding
    filter :RemoveBOM
    use Slim::Parser
    use Slim::Embedded
    use Slim::Interpolation
    use Slim::Splat::Filter
    use Slim::DoInserter
    use Slim::EndInserter
    use Slim::Controls
    html :AttributeSorter
    html :AttributeMerger
    use Slim::CodeAttributes
    use(:AttributeRemover) { Temple::HTML::AttributeRemover.new(remove_empty_attrs: options[:merge_attrs].keys) }
    html :Pretty
    filter :Escapable
    filter :ControlFlow
    filter :MultiFlattener
    use :Optimizer do
      (options[:streaming] ? Temple::Filters::StaticMerger : Temple::Filters::DynamicInliner).new
    end
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_key?(k) })
    end
  end
end
