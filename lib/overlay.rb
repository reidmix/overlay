##
# A singleton to hold the overlay pattern and current state of any overlay to the view.
module Overlay
  ## The default pattern ':view'
  DEFAULT_PATTERN   = ':view'
  ## The default separator dash '-'
  DEFAULT_SEPARATOR = '-'

  @@default_pattern   = DEFAULT_PATTERN
  @@default_separator = DEFAULT_SEPARATOR

  class << self
    ## Returns the default pattern.  Defaults to ':view'.
    def pattern
      @@default_pattern
    end

    ##
    # Sets a pattern, should only be used for multidimensional overlays.
    # Ex:
    #   Overlay.pattern = ':cobrand-:product'
    def pattern= pattern
      @@default_pattern = pattern
    end

    ## Returns the default separator.  Defaults to '-'.
    def separator
      @@default_separator
    end

    ##
    # Sets the separator used in a pattern, should only be used for
    # multidimensional overlays.  Used to removes superfluous separators
    # when interpolation do not have matches.
    #
    # NOTE: Avoid dots (.) as they will conflict with locales.
    def separator= separator
      @@default_separator = separator
    end

    ##
    # Sets the current overlay to be interpolated in the pattern.
    # Ex.
    #   Overlay.current = 'sprint'
    #
    # For multidimensional patterns pass it a hash, also you can use the
    # +set_view+ alias for sytactic sugar:
    #   Overlay.set_view :cobrand => 'sprint', :product => 'cable'
    #
    # This is set in Thread.current hash.
    def current= overlay
      Thread.current[:overlay] = interpolate(Hash === overlay ? overlay : {:view => overlay})
    end
    alias_method :set_view, :current=

    ## Returns the current overlay
    def current
      Thread.current[:overlay]
    end

    private
      ##
      # Interpolates a hash of keys into a pattern where each segment is defined by +pattern+
      # and each +separator+ is set.
      def interpolate overlay
        result = overlay.keys.inject(pattern.dup) do |result, key|
          if value = overlay[key]
            result.gsub! /:#{key}/, value.to_s
          else
            result.gsub! /:#{key}#{separator}?/, ''
          end
          result
        end
        result.gsub!(/#{separator}$/, '') || result
      end
  end
end

