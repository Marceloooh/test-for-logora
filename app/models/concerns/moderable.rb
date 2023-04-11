require 'open-uri'

module Moderable
  extend ActiveSupport::Concern

  included do
    validates :content, presence: true
    before_save :check_content
  end

  def check_content
    url_encoded_string = ERB::Util.url_encode(self.content)
    score_prediction = score_prediction(url_encoded_string)
    self.is_accepted = is_accepted?(score_prediction)
  end

  private

  def is_accepted?(score_prediction)
    score_prediction < 0.8
  end

  def score_prediction(text_content)
    response = URI.open("https://moderation.logora.fr/predict?text=#{text_content}")
    json = JSON.parse(response.read)
    json['prediction']['0']
  end

end
