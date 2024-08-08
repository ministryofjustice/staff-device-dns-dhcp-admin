Rails.application.config.to_prepare do
  ActiveSupport.on_load :active_record do
    Audited.config do |config|
      config.audit_class = Audit
    end
  end
end
