module Generator
  def self.generate(datafile)
    require 'csv'
    path = File.join(Rails.root, 'data', datafile)

    reader = CSV.open(path, 'r') 
    header = reader.shift
    reader.each_with_index  do |row, index|
      result = yield row
      if result == false # record was not created 
        nil
      else
        puts("#{datafile}: #{index}") if index % 1000 == 0 
      end
    end
  end

end
