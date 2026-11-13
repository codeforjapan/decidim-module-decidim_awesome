# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ApplicationHelper do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component:, body: { en: body }) }
    let(:official_proposal) { create(:proposal, :official, component:, body: { en: body }) }
    let(:awesome_config) { { allow_images_in_editors: true } }
    let(:custom_fields) { {} }
    let(:image) { '<img src="https://www.example.com/someimage.jpeg">' }
    let(:video) { '<iframe src="https://www.youtube-nocookie.com/embed/abc" title="Video" frameborder="0" allowfullscreen></iframe>' }
    let(:audio) { '<audio src="https://www.example.com/sound.mp3" controls></audio>' }
    let(:body) { "<p>Body #{image}</p><!-- Comment --><p>#{video}</p><p>#{audio}</p>" }
    let(:rendered) { Nokogiri::HTML::DocumentFragment.parse(helper.render_proposal_body(proposal)) }

    before do
      allow(helper).to receive(:awesome_config).and_return(awesome_config)
      allow(helper).to receive(:awesome_proposal_custom_fields).and_return(custom_fields)
      allow(helper).to receive(:current_organization).and_return(organization)
    end

    describe "#render_proposal_body" do
      it "keeps the images" do
        expect(rendered.at_css("img")["src"]).to eq("https://www.example.com/someimage.jpeg")
      end

      it "does not keep the iframes or the other media" do
        expect(rendered.css("iframe, .disabled-iframe, audio, video, source")).to be_empty
      end

      it "does not keep the comments written in the body" do
        expect(rendered.xpath(".//comment()")).to be_empty
      end

      context "when the proposal has custom fields" do
        let(:awesome_config) { {} }
        let(:custom_fields) { { "foo" => '[{"type":"text","label":"Title","subtype":"text","name":"text"}]' } }
        let(:body) { "<xml><dl><dt>Title</dt><dd id=\"text\"><div>Value</div></dd></dl></xml><!-- Comment -->" }

        it "keeps the fields" do
          expect(rendered.at_css("dl dd").text).to eq("Value")
        end

        it "does not keep the comments written in the body" do
          expect(rendered.xpath(".//comment()")).to be_empty
        end
      end

      context "when the proposal is official" do
        let(:proposal) { official_proposal }
        let(:disabled_iframe) { Nokogiri::HTML::DocumentFragment.parse(rendered.at_css(".disabled-iframe").children.find(&:comment?).content) }

        it "keeps the videos as disabled iframes" do
          expect(disabled_iframe.at_css("iframe")["src"]).to eq("https://www.youtube-nocookie.com/embed/abc")
        end
      end
    end
  end
end
