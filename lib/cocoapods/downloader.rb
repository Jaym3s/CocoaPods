require 'uri'

module Pod
  class Downloader
    autoload :Git,        'cocoapods/downloader/git'
    autoload :GitHub,     'cocoapods/downloader/git'
    autoload :Mercurial,  'cocoapods/downloader/mercurial'
    autoload :Subversion, 'cocoapods/downloader/subversion'
    autoload :Http,       'cocoapods/downloader/http'

    extend Executable

    def self.for_pod(pod)
      spec = pod.top_specification
      for_target(pod.root, spec.source.dup)
    end

    attr_reader :target_path, :url, :options

    def initialize(target_path, url, options)
      @target_path, @url, @options = target_path, url, options
      @target_path.mkpath
    end

    private

    def self.for_target(target_path, options)
      options = options.dup
      if url = options.delete(:git)
        if url.to_s =~ /github.com/
          GitHub.new(target_path, url, options)
        else
          Git.new(target_path, url, options)
        end
      elsif url = options.delete(:hg)
        Mercurial.new(target_path, url, options)
      elsif url = options.delete(:svn)
        Subversion.new(target_path, url, options)
      elsif url = options.delete(:http)
        Http.new(target_path, url, options)
      else
        raise "Unsupported download strategy `#{options.inspect}'."
      end
    end
  end
end
