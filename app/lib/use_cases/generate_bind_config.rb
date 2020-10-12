class UseCases::GenerateBindConfig
  def initialize(zones: [])
    @zones = zones
  end

  def execute
    %(
options {
  directory "/var/bind";

  allow-recursion {
    127.0.0.1/32;
  };

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
  forwarders {#{zone.kea_forwarders}};
};
)
    }.join
  end
end
