# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimDeviseMailer do
    describe "confirmation_instructions" do
      let(:mail) { described_class.confirmation_instructions(user, "foo", {}) }

      let(:mail_subject) { "Instruccions de confirmació" }
      let(:body) { "Pots confirmar el correu electrònic del teu compte" }
      let(:default_subject) { "Confirmation instructions" }
      let(:default_body) { "You can confirm your email account through the link below" }

      include_examples "localised email"
    end

    describe "reset_password_instructions" do
      let(:mail) { described_class.reset_password_instructions(user, "foo", {}) }

      let(:mail_subject) { "Instruccions de regeneració de contrasenya" }
      let(:body) { "Algú ha demanat un enllaç per canviar la teva contrasenya" }
      let(:default_subject) { "Reset password instructions" }
      let(:default_body) { "Someone has requested a link to change your password" }

      include_examples "localised email"
    end

    describe "password_change" do
      let(:mail) { described_class.password_change(user, {}) }

      let(:mail_subject) { "Contrasenya modificada" }
      let(:body) { "Ens posem en contacte amb tu per notificar-te que la teva contrasenya ha estat canviada" }
      let(:default_subject) { "Password changed" }
      let(:default_body) { "contacting you to notify you that your password has been changed" }

      include_examples "localised email"
    end

    describe "invitation_instructions" do
      let(:mail) do
        user.invitation_created_at = Time.current
        described_class.invitation_instructions(user, "foo", invitation_instructions: "organization_admin_invitation_instructions")
      end

      let(:mail_subject) do
        I18n.with_locale(locale) do
          "T'han convidat a administrar #{translated_attribute(user.organization.name)}"
        end
      end
      let(:body) { "Acceptar invitaci" }
      let(:default_subject) { "You have been invited to manage #{translated_attribute(user.organization.name)}" }
      let(:default_body) { "Accept invitation" }

      include_examples "localised email"
    end
  end
end
