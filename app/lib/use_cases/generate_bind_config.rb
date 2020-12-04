class UseCases::GenerateBindConfig
  def initialize(pdns_ips:, zones: [])
    @zones = zones
    @pdns_ips = parse_pdns_ips(pdns_ips)
  end

  def call
    %(
options {
  directory "/var/bind";

  allow-recursion {
    any;
  };

  listen-on port 53 { any; };
  listen-on-v6 { none; };

  pid-file "/var/run/named/named.pid";

  allow-transfer { none; };
};

statistics-channels {
  inet 127.0.0.1 port 8080 allow { 127.0.0.1; };
};

zone "localhost" IN {
  type master;
  file "pri/localhost.zone";
  allow-update { none; };
  notify no;
};

zone "127.in-addr.arpa" IN {
  type master;
  file "pri/127.zone";
  allow-update { none; };
  notify no;
};
#{render_zones}
zone "." IN {
  type forward;
  forward only;
  forwarders {
    #{@pdns_ips};
    };
};
)
  end

  private

  attr_reader :zones

  def parse_pdns_ips(pdns_ips)
    raise "PDNS IPs have not been set" if pdns_ips.blank?

    pdns_ips.split(",").join(";\n")
  end

  def render_zones
    zones.map { |zone|
      %(
zone "#{zone.name}" IN {
  type forward;
  forwarders {#{format_zone_forwarders(zone.forwarders)}};
};
)
    }.join
  end

  def format_zone_forwarders(forwarders)
    forwarders.join(";") + ";"
  end
end
