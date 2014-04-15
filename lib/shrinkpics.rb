#!/usr/bin/env ruby

require 'js_base'
require 'backup_set'

class ShrinkPicsApp

  IMG_EXT = Set.new ['jpg','jpeg','png','gif']

  def initialize
    @maxDim = 1000
    @saveDir = nil
    @dryRun = false
    @verbose = false
  end

  def pic_arg(pic, name)
    cmd = "sips -g #{name} \"#{pic}\""
    res,_ = scall(cmd)
    arg = res.split.last
    arg.to_i
  end

  def resize(pic)
    w = pic_arg(pic,"pixelWidth")
    h = pic_arg(pic,"pixelHeight")

    if w <= @maxDim and h <= @maxDim
      puts("Not resizing #{pic}, dimensions (#{w},#{h}) not greater than maximum #{@maxDim}") if @verbose
      return
    end

    puts("Resizing, dimensions (#{w},#{h}) greater than maximum #{@maxDim}") if @verbose

    cmd = "sips --resampleHeightWidthMax #{@maxDim} \"#{pic}\""
    puts("#{cmd}") if @verbose

    return if @dryRun

    @backups.backup_file(pic)

    scall(cmd)
  end

  def proc_dir(dirname)
    fl = Dir.entries(dirname)
    fl.each do |x|
      next if x == '.' or x == '..'
      y = File.join(dirname,x)
      if File.directory?(y)
        proc_dir(y)
      else
        ext = File.extname(x).downcase
        if ext.size > 0
          ext = ext[1..-1]
        end
        next if not IMG_EXT.member?(ext)
        resize(y)
      end
    end
  end

  def run(argv = nil)
    argv ||= ARGV
    p = Trollop::Parser.new do
      opt :maxdim, "maximum width or height: PIXELS", :default => 2048
      opt :dryrun, "show which files will be modified, but make no changes"
      opt :verbose, "verbose operation"
    end

    options = Trollop::with_standard_exception_handling p do
      p.parse(argv)
    end

    @dryRun = options[:dryrun]
    @maxDim = options[:maxdim]
    @verbose = options[:verbose]

    fail("bad argument") if @maxDim < 100 || @maxDim > 4000

    d = Dir.pwd

    @backups = BackupSet.new('shrinkpics')

    proc_dir(d)

  end

end


if __FILE__ == $0
  ShrinkPicsApp.new.run()
end
