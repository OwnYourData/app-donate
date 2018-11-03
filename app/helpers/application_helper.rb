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

        if dr.email.to_s == ""
            dr_email = "Anonymous"
        else
            dr_email = dr.email.to_s
        end
        if dr.privacy == 0
            contributionProvenance = {
                "@list": [
                    {
                        "@type": "prov:Activity",
                        "dc:description": "web site upload",
                        "prov:wasGeneratedBy": "https://donate.ownyourdata.eu"
                    }.stringify_keys
                ]
            }.stringify_keys
        else
            if dr.signature.to_s == ""
                contributionProvenance = {
                    "@list": [
                        {
                            "@type": "prov:Activity",
                            "dc:description": "web site upload",
                            "prov:wasAttributedTo":
                            {
                                "@type": "foaf:Person",
                                "rdfs:label": dr_email
                            }.stringify_keys,
                            "prov:wasGeneratedBy": "https://donate.ownyourdata.eu"
                        }.stringify_keys
                    ]
                }.stringify_keys
            else
                contributionProvenance = {
                    "@list": [
                        {
                            "@type": "prov:Activity",
                            "dc:description": "web site upload",
                            "prov:wasAttributedTo":
                            {
                                "@type": "foaf:Agent",
                                "email": dr.email.to_s,
                                "signature": dr.signature.to_s
                            }.stringify_keys,
                            "prov:wasGeneratedBy": "https://donate.ownyourdata.eu"
                        }.stringify_keys
                    ]
                }.stringify_keys
            end
        end
        sc_content = {
            "@type": "sc:ContributionContent",
            "sc:contributionData": {
                "@list": enriched_input
            }.stringify_keys, 
            "sc:contributionConsent":{
                "spl:hasData": "spl:anyData",
                "spl:hasDuration": svdu_duration,
                "spl:hasLocation": svl_location,
                "spl:hasProcessing": svpr_processing,
                "spl:hasPurpose": svpu_purpose,
                "spl:hasRecipient": spl_recipient,
                "spl:hasStorage": "spl:AnyStorage"
            }.stringify_keys,
            "sc:contributionProvenance": contributionProvenance
        }.stringify_keys
        sc_content_hash = Digest::SHA256.hexdigest(sc_content.to_s.gsub("=>", ":").gsub(/([ \r\n\t]+|(".*?"))/, "\\2"))
        contentHashVerification = ""
        api_url = "https://blockchain.ownyourdata.eu/api/doc"
        response = HTTParty.post(api_url,
            headers: { 'Content-Type' => 'application/json' },
            body: { hash: sc_content_hash.to_s }.to_json )
        if response.code == 200
            contentHashVerification = "https://seal.ownyourdata.eu/?hash=" + sc_content_hash.to_s
        end

        complete = {
            "@context": {
                "sc": "http://semantics.id/ns/semcon#",
                "spl": "https://www.specialprivacy.eu/langs/usage-policy#",
                "svd": "http://www.specialprivacy.eu/vocabs/data#",
                "svr": "http://www.specialprivacy.eu/vocabs/recipients#",
                "svl": "http://www.specialprivacy.eu/vocabs/locations#",
                "svpu": "http://www.specialprivacy.eu/vocabs/purposes#",
                "svpr": "http://www.specialprivacy.eu/vocabs/processing#",
                "svdu": "http://www.specialprivacy.eu/vocabs/duration#",
                "prov": "http://www.w3.org/ns/prov#",
                "foaf": "http://xmlns.com/foaf/0.1/",
                "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
                "xsd": "http://www.w3.org/2001/XMLSchema#",
                "dc": "http://purl.org/dc/elements/1.1/",
                "spl:hasData": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasDuration": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasLocation": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasProcessing": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasPurpose": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasRecipient": {
                    "@type": "@id"
                }.stringify_keys,
                "spl:hasStorage": {
                    "@type": "@id"
                }.stringify_keys,
                "date": {
                    "@id": "sc:date",
                    "@type": "xsd:dateTime"
                }.stringify_keys,
                "value": {
                    "@id": "sc:value",
                    "@type": "xsd:double"
                }.stringify_keys,
                "person": {
                    "@id": "sc:person",
                    "@type": "xsd:string"
                }.stringify_keys,
                "email": {
                    "@id": "sc:email",
                    "@type": "xsd:string"
                }.stringify_keys,
                "signature": {
                    "@id": "sc:signature",
                    "@type": "xsd:string"
                }.stringify_keys,
                "insulinType": {
                    "@id": "sc:insulinType",
                    "@type": "xsd:string"
                }.stringify_keys
            }.stringify_keys,
            "@graph": {
                "@type": "sc:Container",
                "sc:contribution": [
                    {
                        "@type": "sc:Contribution",
                        "sc:content": sc_content,
                        "sc:contentProof": {
                            "@type": "sc:ContributionContentProof", # "DataContributionProof", 
                            "sc:contentHash": sc_content_hash.to_s,
                            "sc:contentHashVerification": contentHashVerification.to_s
                        }.stringify_keys
                    }.stringify_keys
                ]
            }.stringify_keys
        }.stringify_keys

        return complete.stringify_keys.to_s.gsub("=>", ":")

	end
end
