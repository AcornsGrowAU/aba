class Aba
  class Batch
    class Headers
      include Aba::Validations

      attr_accessor :bsb, :financial_institution, :user_name, :user_id,
        :description, :process_at

      # BSB
      validates_bsb         :bsb, allow_blank: true

      # Financial Institution
      validates_length      :financial_institution, 3

      # User Name
      validates_presence_of :user_name
      validates_max_length  :user_name, 26
      validates_becs        :user_name

      # User ID
      validates_presence_of :user_id
      validates_max_length  :user_id, 6
      validates_integer     :user_id, false

      # Description
      validates_max_length  :description, 12
      validates_becs        :description

      # Process at Date
      validates_length      :process_at, 6
      validates_integer     :process_at, false

      def initialize(attrs = {})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def validate!
        unless valid?
          raise RuntimeError, 'Headers are invalid - check output of #errors method for more information'
        end
      end

      def to_s
        validate!

        # Record type
        # Max: 1
        # Char position: 1
        output = "0"

        # Optional branch number of the funds account with a hyphen in the 4th character position
        # Char position: 2-18
        # Max: 17
        # Blank filled
        output += @bsb.nil? ? " " * 17 : @bsb.to_s.ljust(17)

        # Sequence number
        # Char position: 19-20
        # Max: 2
        # Zero padded
        output += "01"

        # Name of user financial instituion
        # Max: 3
        # Char position: 21-23
        output += @financial_institution.to_s

        # Reserved
        # Max: 7
        # Char position: 24-30
        output += " " * 7

        # Name of User supplying File
        # Char position: 31-56
        # Max: 26
        # Full BECS character set valid
        # Blank filled
        output += @user_name.to_s.ljust(26)

        # Direct Entry User ID
        # Char position: 57-62
        # Max: 6
        # Zero padded
        output += @user_id.to_s.rjust(6, "0")

        # Description of payments in the file (e.g. Payroll, Creditors etc.)
        # Char position: 63-74
        # Max: 12
        # Full BECS character set valid
        # Blank filled
        output += @description.to_s.ljust(12)

        # Date on which the payment is to be processed
        # Char position: 75-80
        # Max: 6
        output += @process_at.to_s.rjust(6, "0")

        # Reserved
        # Max: 40
        # Char position: 81-120
        output += " " * 40

        return output
      end
    end
  end
end
