require 'zlib'
require 'fileutils'
input_file = File::open ARGV[0], 'r'
data = ""
until input_file.eof?
    data << input_file.read(256)
end
input_file.close
offset = 2
ec = Encoding::Converter.new('UTF-16BE', Encoding::default_external)

len = data.byteslice(offset...offset+4).unpack("N")[0]
offset += 4
folder_name = ec.convert data.byteslice(offset...offset+len)
offset += len

file_count = data.byteslice(offset...offset+4).unpack("N")[0]
offset += 4

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
    len = data.byteslice(offset...offset+4).unpack("N")[0]
    offset += 4
    IO::binwrite path, Zlib::Inflate.inflate(data.byteslice(offset+4...offset+len))
    offset += len + 2
    puts path
end