require "csv"

sql_rows = []
CSV.foreach("./data/Quantum.csv") do |row|
    next if row[0].nil?
    next if row[1] == "Site Name"

    sql_rows << "INSERT INTO `sites` (`name`, fits_id, created_at, updated_at) VALUES (" + "'" + row[1] + "', '" + row.first + "'" + ", NOW(), NOW());"
end

puts sql_rows.uniq.join("\n")
