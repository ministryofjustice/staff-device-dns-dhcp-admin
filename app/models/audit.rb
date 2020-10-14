# Always interact with our own Audit model rather than
# using Audited's internal model
class Audit < Audited::Audit
end
