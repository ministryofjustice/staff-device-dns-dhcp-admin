module UseCases
  class Result
    attr_reader :errors

    def initialize(errors = [])
      @errors = ActiveModel::Errors.new(self)
      Array(errors).each do |error|
        @errors.add(:base, error.message)
      end
    end

    def success?
      errors.none?
    end
  end
end
