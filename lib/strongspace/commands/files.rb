require 'ftools'
require 'pathname'

module Strongspace::Command
  class Download < Base
    def index
      path = Pathname.new(args.first)
      display "Downloading #{path.basename}"
      tempfile = strongspace.download(path.to_s)
      File.move(tempfile.path, path.basename)
    end
  end

  class Upload < Base
    def index

      if args.length != 2
        error "usage: strongspace upload <local file> </destination/path>"
      end

      if not File.exist?(args.first)
        error "#{args.first} does not exist"
      end

      if not File.readable?(args.first)
        error "You don't have permissions to read #{args.first}"
      end

      display "Uploading #{Pathname.new(args.first).basename} to #{args[1]}"
      file = File.new(args.first, 'rb')
      strongspace.upload(file, args[1])
      display "Succesfully uploaded #{Pathname.new(args.first).basename}"
    end
  end

  class Mkdir < Base
    def index
      if args.length != 1
        error "please supply a remote path"
      end

      strongspace.mkdir(args[0])
      display "Created #{args[0]}"
    end
  end

  class Delete < Base
    def index
      if args.length != 1
        error "please supply a remote path"
      end

      strongspace.rm(args[0])
      display "Deleted #{args[0]}"
    end
  end

end
