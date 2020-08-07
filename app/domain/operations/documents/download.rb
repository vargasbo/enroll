# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Operations
  module Documents
    class Download
      send(:include, Dry::Monads[:result, :do])

      include Config::SiteHelper

      def self.call(opts)
        self.new.call(opts)
      end

      def call(opts)
        return Failure({:message => 'Please login to download the document'}) if opts[:user].blank?

        payload = yield validate_params(opts[:params])
        resource = yield fetch_resource(payload)
        document = yield fetch_document(resource, opts[:params][:relation_id])
        header = yield construct_headers(resource, opts[:user])
        body = yield construct_body(resource, document)
        response = yield download_from_doc_storage(document, header, body)

        Success(response)
      end

      private

      def validate_params(params)
        result = ::Validators::Documents::DownloadContract.new.call(params)
        result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
      end

      def fetch_secret_key
        Rails.application.secrets.secret_key_base
      end

      def encoded_payload(payload)
        Base64.strict_encode64(payload.to_json)
      end

      def fetch_url
        Rails.application.config.cartafact_document_base_url
      end

      def fetch_resource(params)
        model = params[:model].camelize

        model_object = Object.const_get(model)

        if model_object == BenefitSponsors::Organizations::AcaShopDcEmployerProfile
          BenefitSponsors::Operations::Profiles::FindProfile.new.call(profile_id: params[:model_id])
        elsif model_object == Person
          ::Operations::People::Find.new.call(person_id: params[:model_id])
        else
          Success(model_object.find(params[:model_id]))
        end
      end

      def fetch_document(resource, document_id)
        document = resource.documents.where(id: document_id).first

        if document.present?
          Success(document)
        else
          Failure({:message => 'Unable to find Document'})
        end
      end

      def construct_headers(resource, user)
        payload_to_encode = { "authorized_identity": {"user_id": user.id.to_s, "system": site_name},
                              "authorized_subjects": [{"type": "notice", "id": resource.id.to_s}] }

        Success({ 'X-REQUESTINGIDENTITY' => encoded_payload(payload_to_encode),
                  'X-REQUESTINGIDENTITYSIGNATURE' => Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", fetch_secret_key, encoded_payload(payload_to_encode))) })
      end

      def construct_body(resource, document)
        Success({ document: { subjects: [{"id": resource.id.to_s, "type": resource.class.to_s}], "document_type": 'notice' }.to_json,
                  id: document.doc_identifier })
      end

      def download_from_doc_storage(document, header, body)
        if Rails.env.production?
          response = HTTParty.get(fetch_url + "/#{document.doc_identifier}/download", :body => body, :headers => header)

          response.code == 200 ? Success(response) : Failure({:message => 'Unable to download document'})
        else
          Failure({:message => 'Unable to download document'})
        end
      end
    end
  end
end