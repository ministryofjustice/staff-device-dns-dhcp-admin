class UseCases::GenerateBindConfig
  def initialize(pdns_ips:, private_zone:, zones: [])
    @zones = zones
    @pdns_ips = parse_pdns_ips(pdns_ips)
    @private_zone = private_zone
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

  dnssec-validation no;

  allow-transfer { none; };
  allow-query { any; };
  querylog yes;
};

statistics-channels {
  inet 127.0.0.1 port 8080 allow { 127.0.0.1; };
};

logging {
  channel stderr_channel {
    stderr;
    severity debug 3;
    print-time yes;
    print-severity yes;
    print-category yes;
  };

  channel query_error {
    stderr;
    severity debug 3;
    print-time yes;
    print-severity yes;
    print-category yes;
  };

  category query-errors { query_error; };
  category queries { stderr_channel; };
  category resolver { stderr_channel; };
  category client { stderr_channel; };
  category security { stderr_channel; };

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
#{render_reverse_lookup_zone}
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

  attr_reader :zones,
    :private_zone

  def parse_pdns_ips(pdns_ips)
    raise "PDNS IPs have not been set" if pdns_ips.blank?

    pdns_ips.split(",").join(";\n")
  end

  def render_zones
    zones.map { |zone|
      %(
zone "#{zone.name}" IN {
  type forward;
  forward only;
  forwarders {#{format_zone_forwarders(zone.forwarders)}};
};
)
    }.join
  end

  def format_zone_forwarders(forwarders)
    forwarders.join(";") + ";"
  end

  def render_reverse_lookup_zone
    raise "No Private Zone has been set" if private_zone.blank?

    %(
zone "0.0.100.in-addr.arpa" IN {
  type master;
  file "/etc/bind/zones/reverse.#{private_zone}";
  allow-update { none; };
  notify no;
};)
  end
end
