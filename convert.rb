require 'cocoapods-core'
require 'fileutils'

FileUtils.mkdir_p 'Sources'
FileUtils.rm_rf 'Sources/ReactiveObjC'
FileUtils.cp_r 'ReactiveObjC/ReactiveObjC', 'Sources'

spec = Pod::Specification.from_file('ReactiveObjC/ReactiveObjC.podspec')

AVAILABLE_PLATFORMS = %i[ios osx tvos watchos]

def platform_definition_for(platform)
  case platform
  when :ios
    'TARGET_OS_IOS'
  when :osx
    'TARGET_OS_OSX'
  when :watchos
    'TARGET_OS_WATCH'
  when :tvos
    'TARGET_OS_TV'
  end
end

Dir.chdir('Sources') do 
  platforms_for_file = {}

  AVAILABLE_PLATFORMS.each do |platform|
    files = Dir[*spec.consumer(platform).source_files] - Dir[*spec.consumer(platform).exclude_files]
    files.each do |filename|
      platforms_for_file[filename] ||= []
      platforms_for_file[filename] << platform
    end
  end

  platforms_for_file.each_pair do |filename, platorms|
    next if platorms.count == AVAILABLE_PLATFORMS.count

    header = "#if (#{platorms.map(&method(:platform_definition_for)).join(' || ')})"
    footer = "#endif"

    contents = "#{header}\n#{File.read(filename)}\n#{footer}\n"

    File.open(filename, 'w') { |f| f.write(contents) }
  end

  Dir['**/*.{d,plist,swift}'].each { |f| FileUtils.rm(f) }

  extobj_command = <<-'CMD'.strip_heredoc
                     find . -regex '.*\.[hm]' \
                     -exec perl -pi \
                       -e 's@<ReactiveObjC/(?:(?!RAC)(EXT.*))\.h>@"\1.h"@' '{}' \;
                   CMD
  system(extobj_command)

  File.open('ReactiveObjC/RACCompoundDisposableProvider.h', 'w') do |file|
    file.puts '#define RACCOMPOUNDDISPOSABLE_ADDED_ENABLED() 0'
    file.puts '#define RACCOMPOUNDDISPOSABLE_ADDED(a,b,c) do {} while(0)'
    file.puts '#define RACCOMPOUNDDISPOSABLE_REMOVED_ENABLED() 0'
    file.puts '#define RACCOMPOUNDDISPOSABLE_REMOVED(a,b,c) do {} while(0)'
  end

  File.open('ReactiveObjC/RACSignalProvider.h', 'w') do |file|
    file.puts '#define RACSIGNAL_NEXT_ENABLED() 0'
    file.puts '#define RACSIGNAL_NEXT(a,b,c) do {} while(0)'
    file.puts '#define RACSIGNAL_ERROR_ENABLED() 0'
    file.puts '#define RACSIGNAL_ERROR(a,b,c) do {} while(0)'
    file.puts '#define RACSIGNAL_COMPLETED_ENABLED() 0'
    file.puts '#define RACSIGNAL_COMPLETED(a,b) do {} while(0)'
  end

  FileUtils.rm 'ReactiveObjC/ReactiveObjC.h'
  FileUtils.mkdir_p 'ReactiveObjC/include'

  headers = Dir[*spec.consumer(:ios).source_files].select { |f| f.end_with?('.h') } - Dir[*spec.consumer(:ios).private_header_files]

  headers.each do |header|
    FileUtils.mv header, 'ReactiveObjC/include'
  end

  File.open('ReactiveObjC/include/ReactiveObjC.h', 'w') do |umbrella|
    headers.map { |h| File.basename(h) }.sort.each { |h| umbrella.puts "#import \"#{h}\"" }
  end
end
