require "csv"

sql_rows = []
collected_cidrs = []
CSV.foreach("./data/Quantum.csv") do |row|
  fits_id = row[0]
  thename = row[1]
  cidr = row[10]
  start_address = row[11]
  end_address = row[12]
  routers = row[15]

  next if fits_id.nil?
  next if start_address == "Start"
  next if cidr == "?"
  next if routers.nil?

  next if collected_cidrs.include?(cidr)
  collected_cidrs << cidr

  sql_rows << "UPDATE `subnets` SET routers='" +
    routers +
    "' WHERE cidr_block='" +
    "#{cidr}/24';"
end

#  sql_rows << "INSERT INTO `subnets` (site_id, cidr_block, start_address, end_address, created_at, updated_at) SELECT id, '" +
#    "#{cidr}/24'" +
#    ", '" +
#    start_address +
#    "', '" +
#    end_address +
#    "', NOW(), NOW()" +
#    " FROM sites WHERE `name` = '" +
#    thename +
#    "' AND fits_id = '" +
#    fits_id +
#    "';"
# end

puts sql_rows.uniq.join("\n")
