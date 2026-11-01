# Converts PNG/JPEG images to WebP and points the posts at the smaller files.
# Originals stay in place so old links keep working.
# Usage: ruby optimize_images.rb <images_dir> <posts_dir>
require 'open3'

images_dir, posts_dir = ARGV
MAX_WIDTH = 1680
QUALITY = '82'

def width_of(path)
  output, = Open3.capture2('file', '-b', path)
  match = output.scan(/(\d+)\s*x\s*(\d+)/).last
  match && match.first.to_i
end

converted = {}
saved = 0
Dir.glob(File.join(images_dir, '**', '*.{png,jpg,jpeg}')).sort.each do |path|
  webp = path.sub(/\.\w+\z/, '.webp')
  args = ['cwebp', '-quiet', '-mt', '-q', QUALITY, '-metadata', 'none']
  width = width_of(path)
  args += ['-resize', MAX_WIDTH.to_s, '0'] if width && width > MAX_WIDTH
  next warn("skip #{path}") unless system(*args, path, '-o', webp)

  if File.size(webp) < File.size(path)
    saved += File.size(path) - File.size(webp)
    relative = path.delete_prefix("#{images_dir}/")
    converted[relative] = relative.sub(/\.\w+\z/, '.webp')
  else
    File.delete(webp)
  end
end

Dir.glob(File.join(posts_dir, '*.md')).each do |post|
  content = File.read(post, encoding: 'utf-8')
  updated = content.gsub(%r{(?<=[("'])(/?images/)([^\s)"']+\.(?:png|jpe?g))}) { "#{$1}#{converted.fetch($2, $2)}" }
  File.write(post, updated) unless updated == content
end

puts "Converted #{converted.size} images, saved #{saved / 1024 / 1024} MB"
