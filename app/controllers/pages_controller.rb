class PagesController < ApplicationController
	include ApplicationHelper
	require 'securerandom'

	def valid_json?(json)
	    JSON.parse(json)
	    return true
	  rescue JSON::ParserError => e
	    return false
	end

	def index
		@donations = Donation.pluck(:name)
		@submission = ""
		@data = "[]"
		@email = ""
		@signature = ""
		@recipient_select = []
		@purpose_select = []
		@processing_select = []
		@storage_location_select = []
		@storage_duration_select = []
		if params["donation"].to_s != ""
			@donation_uuid = params["donation"]
			@dr = DonationRecord.find_by_key_id(@donation_uuid)
			if !@dr.nil?
				@donation = Donation.find(@dr.donation_id)
				if !@donation.nil?
					@donation_url = @donation.container +  "/api/data"
					@data = create_submission(@dr, @donation.container +  "/api/desc")
				end
				@submission = @dr.submission
				@records = JSON.parse(@dr.submission).count

				@email = @dr.email.to_s
				@signature = @dr.signature.to_s
				@recipient_select = JSON.parse(@dr.recipient).reject(&:blank?)
				@purpose_select = JSON.parse(@dr.purpose).reject(&:blank?)
				@processing_select = JSON.parse(@dr.processing).reject(&:blank?)
				@storage_location_select = JSON.parse(@dr.storage_location).reject(&:blank?)
				@storage_duration_select = @dr.storage_duration.to_s
			end
		end
	end

	def submit
		if params["button"] == "results"
			redirect_to results_path(donation: params["scenario"])
			return
		end

		if params["button"] == "info"
			# redirect_to info_url(donation: params["scenario"]), status: 200
			redirect_to info_path(donation: params["scenario"])
			return
		end

		if params["button"] == "reset"
			redirect_to root_path
			return
		end

		if ((params["button"] == "donate") or (params["button"] == "submit"))
			scenario = params["scenario"]
			data = params["json_data"]
			email = params["email"].to_s
			signature = params["data_signature"].to_s
			diffpriv = (params["diffpriv"].to_s != "0")
			recipient = params["recipient"].to_s
			purpose = params["purpose"].to_s
			processing = params["processing"].to_s
			check_participants = (params["check_participants"].to_s != "0")
			num_participants = params["num_participants"].to_i
			storage_location = params["storage_location"].to_s
			storage_duration = params["storage_duration"].to_s

			# check if valid JSON
			if !valid_json?(data)
				flash[:warning] = "Error: " + t('error.invalidJson')
				redirect_to root_path
				return
			end

			# check if empty
			if JSON.parse(data).count == 0
				flash[:warning] = "Error: " + t('error.emptyJson')
				redirect_to root_path
				return
			end

			if JSON.parse(data).first.count == 0
				flash[:warning] = "Error: " + t('error.emptyJson')
				redirect_to root_path
				return
			end

			# upload
			@donation = Donation.find_by_name(scenario)
			@donation_url = @donation.container +  "/api/data"

			# create/update record
			if params["donation"].to_s != ""
				@donation_uuid = params["donation"]
				@dr = DonationRecord.find_by_key_id(@donation_uuid)
				if @dr.nil?
					@dr = DonationRecord.new(
						donation_id: @donation.id,
						key_id: SecureRandom.uuid,
						submission: data,
						email: email,
						signature: signature,
						diffpriv: diffpriv,
						recipient: recipient,
						purpose: purpose,
						processing: processing,
						min_participants: check_participants,
						min_participants_number: num_participants,
						storage_location: storage_location,
						storage_duration: storage_duration)
					@dr.save
				else
					@dr.update_attributes(
						donation_id: @donation.id,
						key_id: SecureRandom.uuid,
						submission: data,
						email: email,
						signature: signature,
						diffpriv: diffpriv,
						recipient: recipient,
						purpose: purpose,
						processing: processing,
						min_participants: check_participants,
						min_participants_number: num_participants,
						storage_location: storage_location,
						storage_duration: storage_duration)

				end
			else
				@dr = DonationRecord.new(
					donation_id: @donation.id,
					key_id: SecureRandom.uuid,
					submission: data,
					email: email,
					signature: signature,
					diffpriv: diffpriv,
					recipient: recipient,
					purpose: purpose,
					processing: processing,
					min_participants: check_participants,
					min_participants_number: num_participants,
					storage_location: storage_location,
					storage_duration: storage_duration)
				@dr.save
			end

			if params["check"].to_s == "0"
				response = HTTParty.post(@donation_url,
					headers: { 'Content-Type' => 'application/json' },
			        body: create_submission(@dr, @donation.container +  "/api/desc"))

				if response.code.to_s == "200"
					flash[:success] = "Success, Donation ID: " + @dr.key_id.to_s
				else
					flash[:warning] = "Error: " + response.parsed_response["error"]
				end
				
			else
				redirect_to root_path(donation: @dr.key_id, anchor: "submit_data")
				return
			end
		end	
		redirect_to root_path	
	end

	def results
		@donation_name = params[:donation]
		@donation = Donation.find_by_name(@donation_name)
		@output = "[" +  HTTParty.get(Donation.first.container + "/api/data").parsed_response.each do |item|
			JSON.pretty_generate(JSON.parse(item.to_s.gsub("=>", ":"))).to_s
   		end.join(",") + "]"
	end

	def info
		begin
			@donation_name = params[:donation]
			@donation = Donation.find_by_name(@donation_name)
			@container = @donation.container
			@response = HTTParty.get(@container + "/api/desc").parsed_response
			@description = @response["@graph"].first["sh:description"]
			@example = @response["@graph"].first["sc:example"]
			@title = @donation_name
		rescue
			@example = "[]"
			@response = "[]"
			@title = ""
		end
	end

	def faq
	end

	def donation_request
	end

end