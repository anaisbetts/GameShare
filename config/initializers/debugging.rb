if %w(development test).include?(RAILS_ENV)
  begin
    SCRIPT_LINES__
  rescue NameError
    SCRIPT_LINES__ = {}
  end
  begin
    require 'ruby-debug'
  rescue LoadError
    warn "Debugging will be unavailable: #{$!}"
  end
end
