ActionView::Base.class_eval do
  def render_with_missing_default(options = {}, local_assigns = {}, &block) #:nodoc:
    if options.respond_to?(:key?) && options.key?(:default)
      has_default, default = true, options.delete(:default)
    end

    render_without_missing_default(options, local_assigns, &block)
  rescue ActionView::MissingTemplate => e
    if Thread.current[:missing_default]
      Thread.current[:missing_default] = nil
      return default if has_default
    end

    raise e
  end
  alias_method_chain :render, :missing_default
end
