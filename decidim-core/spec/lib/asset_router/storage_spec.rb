# frozen_string_literal: true

require "spec_helper"

module Decidim::AssetRouter
  describe Storage do
    subject { router }

    let(:router) { described_class.new(asset) }
    let(:asset) { organization.official_img_footer }
    let(:organization) { create(:organization) }

    describe "#url" do
      subject { router.url(**options) }

      let(:options) { {} }
      let(:default_port) { Capybara.server_port }

      context "with an ActiveStorage::Attached" do
        it "creates the disk service route to the blob" do
          expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.jpg$})
        end

        context "when requesting the local redirect path to the asset" do
          let(:options) { { only_path: true } }

          it "creates the redirect route to the blob" do
            expect(subject).to match(%r{^/rails/active_storage/blobs/redirect/[^/]+/avatar.jpg$})
          end

          context "with extra URL options" do
            let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }

            it "handles the extra URL options correctly" do
              expect(subject).to match(%r{^/rails/active_storage/blobs/redirect/[^/]+/avatar.jpg\?utm_campaign=testing&utm_medium=email&utm_source=website$})
            end
          end
        end
      end

      context "with an ActiveStorage::Blob" do
        let(:asset) { organization.official_img_footer.blob }

        it "creates the disk service route to the blob" do
          expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.jpg$})
        end

        context "when requesting the local redirect path to the asset" do
          let(:options) { { only_path: true } }

          it "creates the redirect route to the blob" do
            expect(subject).to match(%r{^/rails/active_storage/blobs/redirect/[^/]+/avatar.jpg$})
          end

          context "with extra URL options" do
            let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }

            it "handles the extra URL options correctly" do
              expect(subject).to match(%r{^/rails/active_storage/blobs/redirect/.*/avatar.jpg\?utm_campaign=testing&utm_medium=email&utm_source=website$})
            end
          end
        end
      end

      context "with a variant" do
        let(:asset) { organization.official_img_footer.variant(resize_to_fit: [160, 160]) }
        let(:track_variants) { true }

        before do
          # This is typically set through `config.active_storage.track_variants`
          # and for test environment it seems to be enabled by default at the
          # time of writing these specs. This config is overridden for these
          # specs because the default configurations may be changed through
          # other changes or gem updates.
          allow(ActiveStorage).to receive(:track_variants).and_return(track_variants)
        end

        it "creates the route to the variant" do
          expect(subject).to match(%r{^/rails/active_storage/representations/redirect/.*/avatar.jpg$})
        end

        context "when the asset has been processed" do
          before { asset.processed }

          it "creates the route to the variant through the storage service" do
            expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.jpg$})
          end
        end

        context "when track_variants is disabled" do
          let(:track_variants) { false }

          it "creates the route to the variant" do
            expect(subject).to match(%r{^/rails/active_storage/representations/redirect/.*/avatar.jpg$})
          end

          context "and the asset has been processed" do
            before { asset.processed }

            it "creates the route to the variant through the storage service" do
              expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.jpg$})
            end
          end
        end

        context "when the variant has a different file extension" do
          let(:asset) { organization.official_img_footer.variant(resize_to_fit: [160, 160], format: "png") }

          it "creates the route to the variant with converted file extension" do
            expect(subject).to match(%r{^/rails/active_storage/representations/redirect/.*/avatar.png$})
          end

          context "when the asset has been processed" do
            before { asset.processed }

            it "creates the route to the variant through the storage service" do
              expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.png$})
            end
          end

          context "when track_variants is disabled" do
            let(:track_variants) { false }

            it "creates the route to the variant with converted file extension" do
              expect(subject).to match(%r{^/rails/active_storage/representations/redirect/.*/avatar.png$})
            end

            context "and the asset has been processed" do
              before { asset.processed }

              it "creates the route to the variant through the storage service" do
                expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/disk/[^/]+/avatar.png$})
              end
            end
          end
        end
      end

      context "when the CDN host is defined" do
        before do
          allow(Rails.application.secrets).to receive(:dig).and_call_original
          allow(Rails.application.secrets).to receive(:dig).with(:storage, :cdn_host).and_return("https://cdn.example.org")
        end

        it "creates the route to the CDN blob" do
          expect(subject).to match(%r{^https://cdn.example.org/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end

        context "with extra URL options" do
          let(:options) { { utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }

          it "handles the extra URL options correctly" do
            expect(subject).to match(%r{^https://cdn.example.org/rails/active_storage/blobs/redirect/.*/avatar.jpg\?utm_campaign=testing&utm_medium=email&utm_source=website$})
          end
        end
      end
    end
  end
end
