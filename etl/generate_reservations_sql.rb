require "csv"

sql_rows = []
file_contents = File.read(File.open("./data/all_reserved_ips_stripped.txt"))
rows = file_contents.split("\n")

rows.uniq.each do |row|
  columns = row.split(",")
  description = columns[4].to_s.empty? ? "NULL" : "\"#{columns[4]}\""

  query = "INSERT INTO `reservations` (subnet_id, hw_address, ip_address, hostname, description, created_at, updated_at)
        SELECT id, \"#{columns[2]}\", \"#{columns[1]}\", \"#{columns[3]}\", #{description}, NOW(), NOW()
        FROM subnets WHERE cidr_block = \"#{columns[0]}/24\";"

  puts query
end
