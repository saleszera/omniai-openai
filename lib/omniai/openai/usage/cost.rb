# frozen_string_literal: true

module OmniAI
  module OpenAI
    module Usage
      # An OpenAI cost implementation.
      class Cost
        # @!attribute [r] start_time
        #   @return [Time]
        attr_reader :start_time

        # @!attribute [r] end_time
        #   @return [Time, nil]
        attr_reader :end_time

        # @!attribute [r] bucket_width
        #   @return [String, nil]
        attr_reader :bucket_width

        # @!attribute [r] project_ids
        #   @return [Array<String>, nil]
        attr_reader :project_ids

        # @!attribute [r] group_by
        #   @return [Array<String>, nil]
        attr_reader :group_by

        # @!attribute [r] limit
        #   @return [Integer, nil]
        attr_reader :limit

        # @!attribute [r] page
        #   @return [Integer, nil]
        attr_reader :page

        # Factory method: validates parameters and builds the object.
        #
        # @param args [Hash] keyword arguments
        # @return [Cost]
        # @raise [ArgumentError] if validation fails
        def self.build!(**args)
          validate_array_params!(args)

          new(**args)
        end

        # @param start_time [Time]
        # @param end_time [Time, nil] optional
        # @param bucket_width [String, nil] optional
        # @param project_ids [Array<String>, nil] optional
        # @param group_by [Array<String>, nil] optional
        # @param limit [Integer, nil] optional
        # @param page [Integer, nil] optional
        def initialize(
          start_time:,
          end_time: nil,
          bucket_width: nil,
          project_ids: nil,
          group_by: nil,
          limit: nil,
          page: nil
        )
          @start_time = start_time
          @end_time = end_time
          @bucket_width = bucket_width
          @project_ids = project_ids
          @group_by = group_by
          @limit = limit
          @page = page
          @client = OmniAI::OpenAI::Client.new(api_key: OmniAI::OpenAI.config.admin_api_key)
        end

        # @param response [HTTP::Response]
        def self.get(**args)
          build!(**args).get
        end

        # @param response [HTTP::Response]
        def get
          response = @client.connection
            .accept(:json)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/organization/costs", params: request_params)

          raise HTTPError, response.flush unless response.status.ok?

          response.parse
        end

      private

        # @return [String]
        def request_params
          {
            start_time:,
            end_time:,
            bucket_width:,
            project_ids: project_ids&.join(","),
            group_by: group_by&.join(","),
            limit:,
            page:,
          }.compact
        end

        # Validates that if present, project_ids and group_by are Arrays.
        #
        # @param args [Hash]
        # @raise [ArgumentError] if a parameter is not an Array
        def self.validate_array_params!(args)
          { project_ids: "project_ids", group_by: "group_by" }.each do |key, name|
            value = args[key]
            raise ArgumentError, "#{name} must be an Array" if value && !value.is_a?(Array)
          end
        end

        private_class_method :validate_array_params!
      end
    end
  end
end
