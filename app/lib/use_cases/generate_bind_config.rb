class UseCases::GenerateBindConfig
  def initialize(zones: [])
    @zones = zones
  end

  def execute
    pdns_ips = JSON.parse(ENV.fetch("PDNS_IPS")).join(";\n")

    %(
options {
  directory "/var/bind";

  allow-recursion {
    127.0.0.1/32;
  };

  forwarders {
#{pdns_ips};
  };

  forward only;

  listen-on { 127.0.0.1; };
  listen-on-v6 { none; };

  pid-file "/var/run/named/named.pid";

  allow-transfer { none; };
};

zone "." IN {
  type hint;
  file "named.ca";
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
)
  end

  private

  attr_reader :zones

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
