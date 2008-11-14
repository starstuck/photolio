require 'jsmin'

module ActionView::Helpers::AssetTagHelper

  private

  # Add compression of content, if all files to join are detected to be
  # stylesheets or javascripts
  def join_asset_file_contents(paths)
    # Has been: 
    #paths.collect { |path| File.read(File.join(ASSETS_DIR, path.split("?").first)) }.join("\n\n")
    # Updated to:
    all_javascript = true
    all_stylesheets = true
    paths.each do |path|
      all_javascript = false if path.split("?").first !~ /\.js\Z/
      all_stylesheets = false if path.split("?").first !~ /\.css\Z/
    end


    content = paths.collect { |path| File.read(File.join(ASSETS_DIR, path.split("?").first)) }.join("\n\n")
    if all_javascript
      compress_javascript(content)      
    elsif all_stylesheets
      compress_stylesheet(content)
    else
      content
    end
  end

  # Fix computation of javascripts paths.
  #
  # It should return disk path, but otyginaly it used compute_public path, 
  # which calculates resource urlpath. This lead to problems, when ruby is not
  # accesssed on server root.
  #
  # This is used only by sed by cached stylesheet_include_tag invocation.
  def compute_javascript_paths(sources)
    # Has been:
    #expand_javascript_sources(sources).collect { |source| compute_public_path(source, 'javascripts', 'js', false) }
    # Updated to:
    expand_stylesheet_sources(sources).collect { |source| File.join('javascripts', source + '.js') }
  end

  # Fix computation of stylesheets paths.
  #
  # Originaly should return disk path, but i used compute_public path, which
  # calculates url resource path. This lead to problems, when ruby is not
  # accesssed on server root.
  #
  # This is used only by sed by cached stylesheet_include_tag invocation.
  def compute_stylesheet_paths(sources)
    # Has been:
    #expand_stylesheet_sources(sources).collect { |source| compute_public_path(source, 'stylesheets', 'css', false) }
    # Updated to: 
    expand_stylesheet_sources(sources).collect { |source| File.join('stylesheets', source + '.css') }
  end

  def compress_javascript(source)
    JSMin.minify(source)
  end

  # Extracted form asset_packager plugin by Scott Becker
  def compress_stylesheet(source)
    source.gsub!(/\s+/, " ")           # collapse space
    source.gsub!(/\/\*(.*?)\*\/ /, "") # remove comments - caution, might want to remove this if using css hacks
    source.gsub!(/\} /, "}\n")         # add line breaks
    source.gsub!(/\n$/, "")            # remove last break
    source.gsub!(/ \{ /, " {")         # trim inside brackets
    source.gsub!(/; \}/, "}")          # trim inside brackets
    source
  end

end
