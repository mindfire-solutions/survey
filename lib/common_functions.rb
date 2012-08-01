module CommonFunctions

	def add_version

		if self.class.name.index("SurveyQuestionSet")
			obj = Survey::SurveyQuestionSet.where( "title = ?", self.title ).order("version DESC").first
		else
			obj = Survey::SurveyQuestion.where( "text = ?", self.text ).order("version DESC").first
		end

		if obj.nil?
		 self.version = '1.0.0'
		else
			if obj.published
				current_version = obj.version
				vrm = current_version.split '.'

				if vrm[2].to_i < 9
					vrm[2] = (vrm[2].to_i + 1).to_s
				else
					if vrm[1].to_i < 9
						vrm[1] = (vrm[1].to_i + 1).to_s
						vrm[2] = "0"
					else
						vrm[0, 1, 2] = [(vrm[0].to_i + 1).to_s, "0", "0"]
					end
				end

				self.version = vrm[0]+'.'+vrm[1]+'.'+vrm[2]
			else
				self.version = self.version
			end
		end

	end

	def set_default_values
		self.published = false if self.published.nil?
		self.active = false if self.active.nil?
	end

end
