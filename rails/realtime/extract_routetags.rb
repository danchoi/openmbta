STDIN.readlines.each do |line|
  if line =~ /route/
    tag = line[/tag="([^"]+)"/, 1]
    puts tag
  end
end
