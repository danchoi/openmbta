module Generator
  def self.generate(datafile)
    require 'csv'
    path = File.join(Rails.root, 'data', datafile)

    reader = CSV.open(path, 'r') 
    header = reader.shift
    reader.each do |row|
      result = yield row
      if result == false # record was not created 
        nil
      else
        print '.'
      end
    end
  end

end
