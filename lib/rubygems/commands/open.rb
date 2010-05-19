class Gem::Commands::OpenCommand < Gem::Command
  def description
    "Open a gem into your favorite editor"
  end

  def arguments
    "GEM       gem's name"
  end

  def usage
    "#{program_name} GEM"
  end

  def initialize
    super "open", description
  end

  def execute
    gemname = options[:args].first

    unless gemname
      say "Usage: #{usage}"
      return terminate_interaction
    end

    spec = search(gemname)

    if spec
      open(spec)
    else
      say "The #{gemname.inspect} gem couldn't be found"
      return terminate_interaction
    end
  end

  def search(gemname)
    regex = /^(.*?)-*([\d.]+[\w\d]*)?$/
    _, required_name, required_version = *gemname.match(regex)

    gemspecs = Dir["{#{Gem::SourceIndex.installed_spec_directories.join(",")}}/*.gemspec"].select do |gemspec|
      basename = File.basename(gemspec).gsub(/\.gemspec$/, "")

      if required_version
        basename == gemname
      else
        _, name, version = *basename.match(regex)
        name == gemname
      end
    end

    gemspec = gemspecs.sort.last

    return unless gemspec

    Gem::SourceIndex.load_specification(gemspec)
  end

  def open(spec)
    if ENV["GEM_EDITOR"]
      system "#{ENV["GEM_EDITOR"]} #{spec.full_gem_path}"
    else
      say "You must set your editor in your .bash_profile or equivalent:"
      say "  export GEM_EDITOR='mate'"
      return terminate_interaction
    end
  end
end
