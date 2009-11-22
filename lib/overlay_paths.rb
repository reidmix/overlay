# Monkey-patch to the ActionView::PathSet to insert overlay functionality.

ActionView::PathSet.class_eval do
  ##
  # Will attempt to find an overlay match from the +load_path+s, honoring +locale+ and +format+
  # extensions that may be used on the filename.  If it cannot find a match it will rever to the
  # original +find_template+.
  def find_template_with_overlay(original_template_path, format = nil, html_fallback = true)
    return original_template_path if original_template_path.respond_to?(:render)
    template_path = original_template_path.sub(/^\//, '')

    each do |load_path|
      if format && (template = load_path["#{template_path}_#{Overlay.current}.#{I18n.locale}.#{format}"])
        return template
      elsif format && (template = load_path["#{template_path}_#{Overlay.current}.#{format}"])
        return template
      elsif template = load_path["#{template_path}_#{Overlay.current}.#{I18n.locale}"]
        return template
      else
        return find_template_without_overlay(original_template_path, format, html_fallback)
      end
    end
  end
  alias_method_chain :find_template, :overlay
end