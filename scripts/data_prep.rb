# The following is used to prepare the scene data (image, audio, & metadata) for Animal Fun
# NOTE: The sox command line client is required to convert .ogg files to .aiff
#       http://sox.sourceforge.net/

# the following snippet was used to generate letter sounds
# ("a".."z").to_a.each{ |l| system("/Users/brianpfeil/bin/TextToSpeechUtility #{l} #{l}.aiff")}

require 'rubygems'
require 'json'
require 'find'
require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'ostruct'
require 'pp'

include FileUtils

# path to the tuxpaint stamps
TUXPAINT_STAMPS_ROOT='/Users/brianpfeil/Temp/stamps'

SRC_AUDIO_FILE_TYPE='ogg'
TARGET_AUDIO_FILE_TYPE='aiff'

# broken (audio) or explictly excluded stamps
SCENE_EXCLUDE_LIST = ['xanthia']

# find all files (recursive directory decent from "path") having a file name that matches "pattern"  
def find_paths(path, pattern)
  file_paths = []
  Find.find(path) do |entry|
    if File.file?(entry) and entry[pattern]
      file_paths << entry
    end
  end
  file_paths
end

# get paths for all image (png) files
file_paths = find_paths(TUXPAINT_STAMPS_ROOT, /.+\.png$/)

scenes = []

file_paths.each do |file_path|
  # data container
  s = OpenStruct.new
  
  # basic file name/path info
  s.file_path = file_path
  s.basename = File.basename(file_path) # apple.png
  s.dirname = File.dirname(file_path) # /stamps/fruit
  s.extname = File.extname(file_path) # .png
  s.barefilename = s.basename.gsub(s.extname, '') # apple
  
  # build various names and paths
  s.text_file_path = "#{s.dirname}/#{s.barefilename}.txt"
  s.image_sound_effect_file_name = "#{s.barefilename}.ogg"
  s.image_sound_effect_file_path = "#{s.dirname}/#{s.image_sound_effect_file_name}"   
  s.image_sound_description_file_name = "#{s.barefilename}_desc.ogg"
  s.image_sound_description_file_path = "#{s.dirname}/#{s.image_sound_description_file_name}"
  s.relative_directory_path = file_path.gsub(TUXPAINT_STAMPS_ROOT, '').gsub(s.basename, '')

  # check for the existence of various files.
  s.text_file_exists = File.exists?(s.text_file_path)
  s.image_sound_effect_file_path_exists = File.exists?(s.image_sound_effect_file_path)
  s.image_sound_description_file_path_exists = File.exists?(s.image_sound_description_file_path)

  scenes << s
end

# build filtered scene arrays by various criteria
scenes_with_text_file = scenes.select{ |s| s.text_file_exists }
scenes_with_sound_effect_file = scenes.select{ |s| s.image_sound_effect_file_path_exists }
scenes_with_sound_description_file = scenes.select{ |s| s.image_sound_description_file_path_exists }
scenes_with_all_supporting_files = scenes.select{ |s| s.text_file_exists && s.image_sound_effect_file_path_exists && s.image_sound_description_file_path_exists }

puts "scenes_with_text_file.size = #{scenes_with_text_file.size}"
puts "scenes_with_sound_effect_file.size = #{scenes_with_sound_effect_file.size}"
puts "scenes_with_sound_description_file.size = #{scenes_with_sound_description_file.size}"
puts "scenes_with_all_supporting_files.size = #{scenes_with_all_supporting_files.size}"

# create working directory
work_dir = "#{Dir.tmpdir}/animalfun/data_prepe"
rm_rf(work_dir)
mkdir_p work_dir

scenes_metadata = []

# filter out excluded scenes because they have a corrupt audio file, etc.
scenes_with_all_supporting_files = scenes_with_all_supporting_files.select{ |s| !SCENE_EXCLUDE_LIST.include?(s.barefilename) }

scenes_with_all_supporting_files.each do |s|
  # get image description text and remove 'A ', 'An ', and '.'
  s.image_description_text = File.open(s.text_file_path).readlines.first.chomp.gsub(/(A )|(An )/, '').gsub('.', '')
  
  # has with scene metadata
  scene_metadata = {}
  scene_metadata[:basename] = s.basename
  scene_metadata[:barefilename] = s.barefilename 
  scene_metadata[:image_file_name] = s.basename
  scene_metadata[:image_description_text] = s.image_description_text
  scene_metadata[:image_sound_effect_file_name] = s.image_sound_effect_file_name.gsub(".#{SRC_AUDIO_FILE_TYPE}", ".#{TARGET_AUDIO_FILE_TYPE}")
  scene_metadata[:image_sound_description_file_name] = s.image_sound_description_file_name.gsub(".#{SRC_AUDIO_FILE_TYPE}", ".#{TARGET_AUDIO_FILE_TYPE}")
  scenes_metadata << scene_metadata
  
  # copy relevant files to working directory
  cp s.file_path, work_dir
  cp s.image_sound_effect_file_path, work_dir
  cp s.image_sound_description_file_path, work_dir
  
  # change to working directory to ease constructing commands (don't need full path references)
  cd(work_dir) do
    puts "processing #{s.barefilename} - #{s.image_description_text}"
    
    # create json formatted metadata file for scene
    File.open("#{s.barefilename}.json", 'w').write(scene_metadata.to_json)

    # convert .ogg audio files to .caf (core audio file) using the sox command line utility
    system "sox #{s.barefilename}.#{SRC_AUDIO_FILE_TYPE} #{s.barefilename}.#{TARGET_AUDIO_FILE_TYPE}"
    system "sox #{s.barefilename}_desc.#{SRC_AUDIO_FILE_TYPE} #{s.barefilename}_desc.#{TARGET_AUDIO_FILE_TYPE}"  

    # remove .ogg files
    rm_f "#{s.barefilename}.ogg"
    rm_f "#{s.barefilename}_desc.ogg"
  end
end

# create json metadata file with info about all the scenes in the directory
cd(work_dir) do
  File.open("metadata.json", 'w').write(scenes_metadata.to_json)
end

# display output directory
system("open #{work_dir}")
