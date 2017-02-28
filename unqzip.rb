require 'zlib'
require 'fileutils'
filename = ARGV[0]
data = File.read filename
offset = 2
ec = Encoding::Converter.new('UTF-16BE', Encoding::default_external)

len = data.byteslice(offset...offset+4).unpack("N")[0]
offset += 4
folder_name = ec.convert data.byteslice(offset...offset+len)
offset += len

file_count = data.byteslice(offset...offset+4).unpack("N")[0]
offset += 4

puts file_count

filenames = (1..file_count).map do
    len = data.byteslice(offset...offset+4).unpack("N")[0]
    offset += 4
    filename = data.byteslice(offset...offset+len)
    offset += len
    ec.convert filename
end

filenames.each do |filename|
    path = "#{folder_name}/#{filename}"
    FileUtils.mkdir_p(File::dirname(path))
    f = File.new path, 'w'
    len = data.byteslice(offset...offset+4).unpack("N")[0]
    offset += 4
    f.write Zlib::Inflate.inflate(data.byteslice(offset+4...offset+len))
    offset += len + 2
    f.close
    puts path
end