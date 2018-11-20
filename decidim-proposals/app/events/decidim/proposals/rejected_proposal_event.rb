# frozen-string_literal: true

module Decidim
  module Proposals
    class RejectedProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def resource_text
        translated_attribute(resource.answer)
      end
    end
  end
end
