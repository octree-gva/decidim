# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to make private notes on proposals in a participatory process.
      class ProposalNotesController < Admin::ApplicationController
        helper_method :proposal

        def reply
          enforce_permission_to(:create, :proposal_note, proposal:)
          parent_note = proposal.notes.find(params[:id])
          @form = form(ProposalNoteForm).from_params(params)

          ReplyProposalNote.call(@form, parent_note) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_notes.reply.success", scope: "decidim.proposals.admin")
              redirect_to proposal_path(id: proposal.id)
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("proposal_notes.reply.error", scope: "decidim.proposals.admin")
              redirect_to proposal_path(id: proposal.id)
            end
          end
        end

        def create
          enforce_permission_to(:create, :proposal_note, proposal:)
          @form = form(ProposalNoteForm).from_params(params)

          CreateProposalNote.call(@form, proposal) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_notes.create.success", scope: "decidim.proposals.admin")
              redirect_to proposal_path(id: proposal.id)
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("proposal_notes.create.error", scope: "decidim.proposals.admin")
              redirect_to proposal_path(id: proposal.id)
            end
          end
        end

        private

        def skip_manage_component_permission
          true
        end

        def proposal
          @proposal ||= Proposal.where(component: current_component).find(params[:proposal_id])
        end
      end
    end
  end
end
