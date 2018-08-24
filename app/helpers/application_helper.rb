module ApplicationHelper
    # dr = DonationRecord
	def create_submission(dr, semcon)
        input = JSON.parse(dr.submission)

        # transform to JSON-LD
        enriched_input = []
        if input.count > 1
            input.each do |item|
                item["@type"]= "sc:StepCount"
                enriched_input << item
            end
        else
            item = input.first
            item["@type"] = "sc:StepCount"
            enriched_input << item
        end

        recipients = JSON.parse(dr.recipient).reject(&:blank?)
        if recipients == []
            spl_recipient = "spl:AnyRecipient"
        else
            spl_recipient = recipients.map { |e| "svr:" + e}
        end

        purposes = JSON.parse(dr.purpose).reject(&:blank?)
        if purposes == []
            svpu_purpose = "spl:AnyPurpose"
        else
            svpu_purpose = purposes.map { |e| "svpu:" + e}
        end

        processings = JSON.parse(dr.processing).reject(&:blank?)
        if processings == []
            svpr_processing = "spl:AnyProcessing"
        else
            svpr_processing = processings.map { |e| "svpr:" + e}
        end

        storage_locations = JSON.parse(dr.storage_location).reject(&:blank?)
        if storage_locations == []
            svl_location = "spl:AnyLocation"
        else
            svl_location = storage_locations.map { |e| "svl:" + e}
        end

        if dr.storage_duration == ""
            svdu_duration = "spl:AnyDuration"
        else
            svdu_duration = "svdu:" + dr.storage_duration.to_s
        end

        if dr.privacy == 0
            contributionProvenance = {
                "@type": "prov:Activity",
                "dc:description": "web site upload",
                "prov:wasGeneratedBy": "http://donate.ownyourdata.eu"
            }.stringify_keys
        else
            if dr.signature.to_s == ""
                contributionProvenance = {
                    "@type": "prov:Activity",
                    "dc:description": "web site upload",
                    "prov:wasAttributedTo":
                    {
                        "@type": "foaf:Person",
                        "rdfs:label": dr.email.to_s
                    }.stringify_keys,
                    "prov:wasGeneratedBy": "http://donate.ownyourdata.eu"
                }.stringify_keys
            else
                contributionProvenance = {
                    "@type": "prov:Activity",
                    "dc:description": "web site upload",
                    "prov:wasAttributedTo":
                    {
                        "@type": "foaf:Agent",
                        "email": dr.email.to_s,
                        "signature": dr.signature.to_s
                    }.stringify_keys,
                    "prov:wasGeneratedBy": "http://donate.ownyourdata.eu"
                }.stringify_keys
            end
        end
        sc_content = {
            "@type": "sc:ContributionContent",
            "sc:contributionData": enriched_input,
            "sc:contributionConsent":{
                "spl:hasData": "spl:anyData",
                "spl:hasDuration": svdu_duration,
                "spl:hasLocation": svl_location,
                "spl:hasProcessing": svpr_processing,
                "spl:hasPurpose": svpu_purpose,
                "spl:hasRecipient": spl_recipient,
                "spl:hasStorage": "spl:AnyStorage"
            }.stringify_keys,
            "sc:contributionProvenance": [ contributionProvenance ]
        }.stringify_keys
        sc_content_hash = Digest::SHA256.hexdigest(sc_content.to_s.gsub("=>", ":").gsub(/([ \r\n\t]+|(".*?"))/, "\\2"))

        complete = {
            "@context": {
                "sc": "http://semantics.id/ns/semcon#",
                "xsd": "http://www.w3.org/2001/XMLSchema#",
                "spl": "https://www.specialprivacy.eu/langs/usage-policy#",
                "prov": "http://www.w3.org/ns/prov#",
                "foaf": "http://xmlns.com/foaf/0.1/",
                "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                "rdfs": "http://www.w3.org/2000/01/rdf-schema#"
            }.stringify_keys,
            "@graph": {
                "@type": "sc:Container",
                "sc:data": [
                    {
                        "@type": "sc:Contribution",
                        "sc:content": sc_content,
                        "sc:contentProof": {
                            "@type": "sc:DataContributionProof",
                            "sc:contentHash": sc_content_hash.to_s,
                            "sc:contentHashVerification": "https://seal.ownyourdata.eu/?hash=" + sc_content_hash.to_s
                        }.stringify_keys
                    }.stringify_keys
                ]
            }.stringify_keys
        }.stringify_keys
        return complete.stringify_keys.to_s.gsub("=>", ":")


# "@graph": enriched_input


        constraints_data = HTTParty.get(semcon).parsed_response

        # combine with semantic validation JSON
        combined_data = {
            "content": enriched_data,
            "constraints": constraints_data
        }

	end
end
