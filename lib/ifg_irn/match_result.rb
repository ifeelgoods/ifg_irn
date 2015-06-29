class MatchResult
  attr_reader :data

  def initialize(match_data)
    @match = !! match_data
    if match_data && match_data.names.include?('wildcard')
      @data = match_data['wildcard']
    end
  end

  def matched?
    @match
  end
end
