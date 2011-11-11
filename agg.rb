require 'net/http'
require 'json'

def get_sprints
sprints = [{
		:team => "Guided Search",
		:sprint => "Sprint.2011.09.28"
	},
	{
		:team => "Guided Search",
		:sprint => "Sprint.2011.10.12"
	},
	{
		:team => "Guided Search",
		:sprint => "Sprint.2011.10.26"
	},
	{
		:team => "Interactive Image",
		:sprint => "Sprint.2011.11.09"
	}
]
return sprints
end

def aggregate_scores(sprints)
	base_url = 'http://HOST/rest/scrumbuttsurvey'
	person_name = 'Scott Baldwin'

	category_scores_means = {}
	category_scores_devs = {}
	overall_scores = []

	sprints.each do |s|
		u = URI.parse(URI.encode("#{base_url}/#{person_name}/#{s[:team]}/#{s[:sprint]}"))
		puts "Querying #{u.to_s}"
		res = Net::HTTP.get_response(u)
		json = JSON.parse(res.body)
		overall_scores << json['teamScore']

		cs = json['categoryScores']
		cs.each do |c|
			category_scores_means[c[0]] = [] if category_scores_means[c[0]] == nil
			category_scores_means[c[0]] << c[1]['mean']

			category_scores_devs[c[0]] = [] if category_scores_devs[c[0]] == nil
			category_scores_devs[c[0]] << c[1]['standardDeviation']
		end
	end
	return category_scores_means, category_scores_devs, overall_scores
end

def avg_overall_score(overall_scores)
	overall_scores.inject(:+) / overall_scores.count rescue 0
end

def avg_category_score(category_scores)
	z = {}
	category_scores.each { |k,v| z[k] = (v.inject(:+)/v.count).round(1) rescue 0 }
	return z
end

sprints = get_sprints
means, stddevs, overall = aggregate_scores sprints
avg_overall = avg_overall_score(overall)
avg_means = avg_category_score(means)
avg_stddevs = avg_category_score(stddevs)

puts "Given the sprints:"
sprints.each do |s|
	puts "\t#{s[:team]}: #{s[:sprint]}"
end
puts "Average overall score: #{avg_overall}" 
puts "Per category averages:"
avg_means.each do |k,v|
	puts "\t#{k}: #{v} (stddev = #{avg_stddevs[k]})"
end
