#!/usr/bin/env ruby

require 'js_base/test'
require 'backup_set'
require 'shrinkpics'

class TestShrinkPics < Test::Unit::TestCase

  def setup
    #
    # Create a test directory with two subdirectories:
    #
    # work
    # backups
    #
    enter_test_directory('__shrinkpics_test__')

    work_dir = 'work'
    backups_dir = 'backups'

    FileUtils.mkdir_p(work_dir)
    FileUtils.mkdir_p(backups_dir)

    Dir.chdir(work_dir)

    # Use swizzling to put backups in 'backups' dir
    #
    @swizzler = Swizzler.new
    @swizzler.add("BackupSet","get_home_dir") {
      "../#{backups_dir}"
    }
    scalls(@@cmds_start)
  end

  def teardown
    @swizzler.remove_all
    leave_test_directory
  end


  # These commands set up the test directory
  #
  @@cmds_start = <<-eos
    cp ../../sample.jpg .
    mkdir subdir
    cp ../../sample.jpg subdir/sample2.jpg
eos

  def proc(args)
    ShrinkPicsApp.new.run(args.split)
  end

  def test_no_existing_backup_directory_exists
    assert(!File.exist?('../backups/._backupset_shrinkpics_'))
  end

  def test_reduces_image_file_size
    original_length = File.size("sample.jpg")
    assert(original_length)
    proc("-m 200")
    final_length = File.size("sample.jpg")
    assert(final_length && final_length < original_length)
  end

  def test_processes_subdirs
    original_length = File.size("subdir/sample2.jpg")
    assert(original_length)
    proc("-m 200")
    final_length = File.size("subdir/sample2.jpg")
    assert(final_length && final_length < original_length)
  end

  def test_creates_backup_directory
    proc("-m 200")
    assert(File.exist?('../backups/._backupset_shrinkpics_'))
  end

  def test_doesnt_change_with_default_dimensions
    original_length = File.size("sample.jpg")
    assert(original_length)
    proc("")
    final_length = File.size("sample.jpg")
    assert(final_length == original_length)
  end

end
