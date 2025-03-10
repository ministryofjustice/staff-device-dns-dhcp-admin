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
  channel query_logging {
    stderr;
    print-category yes;
    severity info;
    print-time yes;
  };

  channel query_errors_log {
     stderr;
     print-time yes;
     print-category yes;
     print-severity yes;
     severity info;
   };
   channel resolver {
      stderr;
      print-time yes;
      print-category yes;
      print-severity yes;
      severity info;
      };

  category queries { query_logging; };
  category query-errors {query_errors_log; };
  category resolver { resolver; };
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
