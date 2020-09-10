require "rails_helper"

describe UseCases::GenerateBindConfig do
  let(:generated_config) { UseCases::GenerateBindConfig.new.execute(zones: all_zones) }

  describe "#execute" do
    let(:all_zones) { [] }

    it "generates a BIND template with no dynamic zones" do
      expected_config = %(
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

)
      expect(generated_config).to eq(expected_config)
    end
  end

  describe "Dynamic zones" do
    before do
      create(:zone, name: "example.test.com", forwarders: "127.0.0.1;127.0.0.2;")
      create(:zone, name: "example2.test.com", forwarders: "10.0.0.1;10.0.0.255;")
    end

    let(:all_zones) { Zone.all }

    it "Renders dynamic zones from the database" do
      expected_config = %(
zone "example.test.com" IN {
  type forward;
  forwarders {127.0.0.1;127.0.0.2;};
};

zone "example2.test.com" IN {
  type forward;
  forwarders {10.0.0.1;10.0.0.255;};
};
)
      expect(generated_config).to include(expected_config)
    end
  end
end
