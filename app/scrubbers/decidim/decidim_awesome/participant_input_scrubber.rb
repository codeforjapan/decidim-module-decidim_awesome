# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # The tags of Decidim::UserInputScrubber and images, for the content written
    # by participants when images or custom fields are enabled.
    class ParticipantInputScrubber < Decidim::UserInputScrubber
      private

      def custom_allowed_tags
        super + %w(img)
      end
    end
  end
end
